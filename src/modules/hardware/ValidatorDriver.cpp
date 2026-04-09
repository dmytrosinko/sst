#include "ValidatorDriver.h"

#include <QDebug>
#include <QSerialPortInfo>

using namespace hardware;

// ─────────────────────────────────────────────────────────────────────────────
// Construction
// ─────────────────────────────────────────────────────────────────────────────

ValidatorDriver::ValidatorDriver(QObject *parent)
    : ValidatorInterface(parent)
{
    // Serial port configuration per EBDS G7 §3.2.1
    m_serial.setBaudRate(QSerialPort::Baud9600);
    m_serial.setDataBits(QSerialPort::Data7);
    m_serial.setParity(QSerialPort::EvenParity);
    m_serial.setStopBits(QSerialPort::OneStop);
    m_serial.setFlowControl(QSerialPort::NoFlowControl);

    connect(&m_serial, &QSerialPort::readyRead,
            this, &ValidatorDriver::onReadyRead);
    connect(&m_serial, &QSerialPort::errorOccurred,
            this, &ValidatorDriver::onSerialError);

    m_pollTimer.setTimerType(Qt::PreciseTimer);
    connect(&m_pollTimer, &QTimer::timeout,
            this, &ValidatorDriver::onPollTimeout);
}

ValidatorDriver::~ValidatorDriver()
{
    stop();
}

// ─────────────────────────────────────────────────────────────────────────────
// ValidatorInterface implementation
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorDriver::start()
{
    if (m_pollTimer.isActive())
        return;

    if (!m_serial.isOpen()) {
        if (!openPort()) {
            emit error(ValidatorError::CommunicationLost,
                       QStringLiteral("Failed to open serial port: %1 — %2")
                           .arg(m_serial.portName(), m_serial.errorString()));
            return;
        }
    }

    m_accepting = true;
    m_ackBit = false;
    m_retryCount = 0;
    m_waitingForReply = false;
    m_stackCommand = false;
    m_returnCommand = false;
    m_powerUpSeen = false;

    m_pollTimer.start(POLL_INTERVAL_MS);
    qDebug() << "[ValidatorDriver] Polling started on" << m_serial.portName();
}

void ValidatorDriver::stop()
{
    m_pollTimer.stop();
    m_accepting = false;

    if (m_serial.isOpen()) {
        // Send one last poll with acceptance disabled (denom mask = 0)
        uint8_t savedMask = m_denomMask;
        m_denomMask = 0x00;
        sendPacket(buildOmnibusCommand());
        m_denomMask = savedMask;
    }

    closePort();
    setState(ValidatorState::Disabled);
    qDebug() << "[ValidatorDriver] Stopped";
}

void ValidatorDriver::acceptBill()
{
    if (m_state != ValidatorState::Escrowed) {
        qWarning() << "[ValidatorDriver] acceptBill() called but state is not Escrowed";
        return;
    }
    m_stackCommand = true;
    m_returnCommand = false;
    // Command will be sent on next poll cycle
}

void ValidatorDriver::rejectBill()
{
    if (m_state != ValidatorState::Escrowed) {
        qWarning() << "[ValidatorDriver] rejectBill() called but state is not Escrowed";
        return;
    }
    m_returnCommand = true;
    m_stackCommand = false;
}

void ValidatorDriver::setDenominationsEnabled(uint8_t mask)
{
    m_denomMask = mask & 0x7F;  // Only lower 7 bits valid
}

ValidatorState ValidatorDriver::state() const
{
    return m_state;
}

bool ValidatorDriver::isAccepting() const
{
    return m_accepting && m_pollTimer.isActive();
}

// ─────────────────────────────────────────────────────────────────────────────
// Driver-specific
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorDriver::setPortName(const QString &portName)
{
    m_serial.setPortName(portName);
}

QString ValidatorDriver::portName() const
{
    return m_serial.portName();
}

bool ValidatorDriver::probeDevice()
{
    if (!m_serial.isOpen()) {
        if (!openPort())
            return false;
    }

    // Send a single omnibus poll and wait for a reply
    m_ackBit = false;
    m_denomMask = 0x00;  // Don't accept any bills during probing
    sendPacket(buildOmnibusCommand());

    // Wait for response (up to 100ms — generous for detection)
    if (!m_serial.waitForReadyRead(100)) {
        closePort();
        return false;
    }

    QByteArray reply = m_serial.readAll();

    // Minimal validation: starts with STX, correct message type
    if (reply.size() >= 4
        && static_cast<uint8_t>(reply[0]) == STX
        && (static_cast<uint8_t>(reply[2]) & 0x70) == MSG_TYPE_OMNIBUS_REPLY) {
        m_denomMask = 0x7F;
        closePort();
        return true;
    }

    closePort();
    return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Polling
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorDriver::onPollTimeout()
{
    if (m_waitingForReply) {
        // Previous poll got no response — retry with same ACK (§5.4.1.1)
        m_retryCount++;

        if (!m_ackToggled && m_retryCount > MAX_RETRIES_SAME_ACK) {
            // Toggle ACK and try another round
            m_ackBit = !m_ackBit;
            m_ackToggled = true;
            m_retryCount = 0;
        } else if (m_ackToggled && m_retryCount > MAX_RETRIES_TOGGLED) {
            // Device is not responding at all
            if (m_deviceConnected) {
                m_deviceConnected = false;
                emit connectedChanged(false);
                emit error(ValidatorError::CommunicationLost,
                           QStringLiteral("Validator not responding after %1 retries")
                               .arg(MAX_RETRIES_SAME_ACK + MAX_RETRIES_TOGGLED));
                setState(ValidatorState::Disconnected);
            }
            m_retryCount = 0;
            m_ackBit = false;
            m_ackToggled = false;
        }
    }

    m_waitingForReply = true;
    sendPacket(buildOmnibusCommand());
}

void ValidatorDriver::onReadyRead()
{
    m_rxBuffer.append(m_serial.readAll());

    // Look for a complete packet: STX ... ETX CHK
    while (m_rxBuffer.size() >= 4) {
        // Find STX
        int stxPos = m_rxBuffer.indexOf(static_cast<char>(STX));
        if (stxPos < 0) {
            m_rxBuffer.clear();
            return;
        }
        if (stxPos > 0) {
            // Check for ENQ bytes before STX (§5.3 — deprecated but handle)
            m_rxBuffer.remove(0, stxPos);
        }

        if (m_rxBuffer.size() < 2)
            return;  // Need at least STX + LEN

        uint8_t length = static_cast<uint8_t>(m_rxBuffer[1]);

        // Sanity check length
        if (length < 5 || length > 127) {
            m_rxBuffer.remove(0, 1);  // Skip bad STX, try again
            continue;
        }

        // Full packet: LEN includes STX through CHK
        if (m_rxBuffer.size() < length)
            return;  // Incomplete, wait for more data

        QByteArray packet = m_rxBuffer.left(length);
        m_rxBuffer.remove(0, length);

        // Verify ETX in expected position
        if (static_cast<uint8_t>(packet[length - 2]) != ETX) {
            qWarning() << "[ValidatorDriver] Bad ETX in reply, discarding";
            continue;
        }

        // Verify checksum (XOR of all bytes from STX through ETX inclusive)
        uint8_t expectedChk = calculateChecksum(packet);
        uint8_t actualChk = static_cast<uint8_t>(packet[length - 1]);
        if (expectedChk != actualChk) {
            qWarning() << "[ValidatorDriver] Checksum mismatch:"
                        << Qt::hex << expectedChk << "!=" << actualChk;
            continue;
        }

        // Check ACK/NAK from device
        uint8_t ctrl = static_cast<uint8_t>(packet[2]);
        bool deviceAck = (ctrl & 0x01) == (m_ackBit ? 1 : 0);

        if (!deviceAck) {
            // NAK — device didn't accept our command (§6.3.1.3)
            // Clear command bits and retry on next poll
            m_stackCommand = false;
            m_returnCommand = false;
            qDebug() << "[ValidatorDriver] Device NAK, clearing commands";
            m_waitingForReply = false;
            return;
        }

        // Valid ACK — toggle for next message
        m_ackBit = !m_ackBit;
        m_retryCount = 0;
        m_waitingForReply = false;

        // Clear one-shot commands after they've been ACK'd
        m_stackCommand = false;
        m_returnCommand = false;

        // Mark connected on first valid reply
        if (!m_deviceConnected) {
            m_deviceConnected = true;
            emit connectedChanged(true);
            qDebug() << "[ValidatorDriver] Device connected";
        }

        // Parse by message type
        uint8_t msgType = ctrl & 0x70;
        if (msgType == MSG_TYPE_OMNIBUS_REPLY) {
            parseOmnibusReply(packet);
        }
    }
}

void ValidatorDriver::onSerialError(QSerialPort::SerialPortError err)
{
    if (err == QSerialPort::NoError)
        return;

    qWarning() << "[ValidatorDriver] Serial error:" << err << m_serial.errorString();

    if (err == QSerialPort::ResourceError) {
        // Device unplugged
        m_pollTimer.stop();
        m_deviceConnected = false;
        emit connectedChanged(false);
        emit error(ValidatorError::CommunicationLost, m_serial.errorString());
        setState(ValidatorState::Disconnected);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Packet building
// ─────────────────────────────────────────────────────────────────────────────

QByteArray ValidatorDriver::buildOmnibusCommand() const
{
    // Host Omnibus Command (§7.1.1): 8 bytes
    // STX | LEN=0x08 | CTRL | Data0 | Data1 | Data2 | ETX | CHK
    QByteArray pkt(OMNIBUS_CMD_LENGTH, 0x00);

    pkt[0] = static_cast<char>(STX);
    pkt[1] = static_cast<char>(OMNIBUS_CMD_LENGTH);  // LEN

    // CTRL: Message Type 1 (0x10) | ACK bit
    uint8_t ctrl = MSG_TYPE_OMNIBUS_CMD;
    if (m_ackBit) ctrl |= 0x01;
    pkt[2] = static_cast<char>(ctrl);

    // Data 0: Denomination enable bitmask (bits 0-6)
    pkt[3] = static_cast<char>(m_accepting ? m_denomMask : 0x00);

    // Data 1:
    //   bit 0: Special Interrupt Mode = 0 (recommended normal polling)
    //   bit 1: High Security = 0
    //   bit 2-3: Orientation = 0b10 (4-way, recommended)
    //   bit 4: Escrow Mode = 1 (recommended)
    //   bit 5: Stack command
    //   bit 6: Return command
    uint8_t data1 = 0;
    data1 |= (0x02 << 2);  // 4-way orientation (bit 3 = 1, bit 2 = 0)
    data1 |= (1 << 4);     // Escrow mode enabled
    if (m_stackCommand)  data1 |= (1 << 5);
    if (m_returnCommand) data1 |= (1 << 6);
    pkt[4] = static_cast<char>(data1);

    // Data 2:
    //   bit 0: No-push mode = 0 (recommended)
    //   bit 1: Barcode = 0 (not needed for retail)
    //   bit 2-3: PUP B,C = 0b00 (Policy A — return pre-escrow docs)
    //   bit 4: Extended note reporting = 1 (for SCN83)
    //   bit 5: Extended coupon = 0
    uint8_t data2 = 0;
    data2 |= (1 << 4);  // Extended note reporting enabled
    pkt[5] = static_cast<char>(data2);

    pkt[6] = static_cast<char>(ETX);

    // Checksum
    pkt[7] = static_cast<char>(calculateChecksum(pkt));

    return pkt;
}

QByteArray ValidatorDriver::buildExtendedNoteQuery(int noteIndex) const
{
    // Extended Note Specification (Type 7, Subtype 0x02, §7.5.2)
    // STX | LEN=0x0A | CTRL | Data0=0x02 | NoteIdx_Hi | NoteIdx_Lo | ETX | CHK
    QByteArray pkt(8, 0x00);

    pkt[0] = static_cast<char>(STX);
    pkt[1] = static_cast<char>(0x08);

    uint8_t ctrl = MSG_TYPE_EXTENDED_CMD;
    if (m_ackBit) ctrl |= 0x01;
    pkt[2] = static_cast<char>(ctrl);

    pkt[3] = static_cast<char>(0x02);  // Subtype: Extended Note Spec
    pkt[4] = static_cast<char>((noteIndex >> 4) & 0x0F);  // Note index hi nibble
    pkt[5] = static_cast<char>(noteIndex & 0x0F);          // Note index lo nibble

    pkt[6] = static_cast<char>(ETX);
    pkt[7] = static_cast<char>(calculateChecksum(pkt));

    return pkt;
}

uint8_t ValidatorDriver::calculateChecksum(const QByteArray &packet)
{
    // XOR of all bytes from STX through ETX (inclusive)
    // The checksum byte itself is excluded
    uint8_t chk = 0;
    int len = packet.size();
    // Checksum covers bytes 0 through len-2 (everything except last byte)
    for (int i = 0; i < len - 1; ++i) {
        chk ^= static_cast<uint8_t>(packet[i]);
    }
    return chk;
}

// ─────────────────────────────────────────────────────────────────────────────
// Reply parsing
// ─────────────────────────────────────────────────────────────────────────────

bool ValidatorDriver::parseOmnibusReply(const QByteArray &reply)
{
    // Standard Omnibus Reply (§7.1.2): 11 bytes
    // STX | LEN=0x0B | CTRL | Data0 | Data1 | Data2 | Data3 | Data4 | Data5 | ETX | CHK
    if (reply.size() < 11) {
        qWarning() << "[ValidatorDriver] Omnibus reply too short:" << reply.size();
        return false;
    }

    uint8_t data0 = static_cast<uint8_t>(reply[3]);
    uint8_t data1 = static_cast<uint8_t>(reply[4]);
    uint8_t data2 = static_cast<uint8_t>(reply[5]);
    uint8_t data3 = static_cast<uint8_t>(reply[6]);
    uint8_t data4 = static_cast<uint8_t>(reply[7]);
    uint8_t data5 = static_cast<uint8_t>(reply[8]);

    processDeviceState(data0, data1, data2, data3, data4, data5);
    return true;
}

void ValidatorDriver::processDeviceState(uint8_t data0, uint8_t data1,
                                          uint8_t data2, uint8_t data3,
                                          uint8_t data4, uint8_t data5)
{
    // Store device info
    m_modelNumber = data4;
    m_codeRevision = data5;

    // ── Data 2: Status bits ──────────────────────────────────────
    //   bit 0: Power Up
    //   bit 1: Invalid Command
    //   bit 2: Failure
    //   bits 3-5: Denomination value (non-extended mode)
    //   bit 6: Transport Open

    bool powerUp       = data2 & 0x01;
    bool invalidCmd    = data2 & 0x02;
    bool failure       = data2 & 0x04;
    uint8_t denomBits  = (data2 >> 3) & 0x07;

    // ── Data 3: Extension bits ───────────────────────────────────
    //   bit 0: No-push / stall
    //   bit 1: Flash download
    //   bit 5: Disabled

    bool deviceDisabled = data3 & 0x20;

    // Handle power-up first
    if (powerUp && !m_powerUpSeen) {
        m_powerUpSeen = true;
        emit error(ValidatorError::PowerUp,
                   QStringLiteral("Device power-up reset detected"));
    }

    if (failure) {
        setState(ValidatorState::Failure);
        emit error(ValidatorError::Failure, QStringLiteral("Device failure reported"));
        return;
    }

    if (invalidCmd) {
        emit error(ValidatorError::InvalidCommand,
                   QStringLiteral("Device reported invalid command"));
    }

    // ── Data 1: Exception bits ───────────────────────────────────
    //   bit 0: Cheated
    //   bit 1: Rejected
    //   bit 2: Jammed
    //   bit 3: Stacker Full
    //   bit 5: Paused
    //   bit 6: Calibration

    bool cheated     = data1 & 0x01;
    bool rejected    = data1 & 0x02;
    bool jammed      = data1 & 0x04;
    bool stackerFull = data1 & 0x08;
    bool calibrating = data1 & 0x40;

    if (cheated) {
        setState(ValidatorState::Cheated);
        emit error(ValidatorError::Cheated,
                   QStringLiteral("Cheat attempt detected — do not issue credit"));
        return;
    }

    if (jammed) {
        setState(ValidatorState::Jammed);
        emit error(ValidatorError::Jam, QStringLiteral("Document transport jam"));
        return;
    }

    if (stackerFull) {
        setState(ValidatorState::StackerFull);
        emit error(ValidatorError::CashboxFull, QStringLiteral("Stacker is full"));
        return;
    }

    if (calibrating) {
        setState(ValidatorState::Calibrating);
        return;
    }

    if (rejected) {
        setState(ValidatorState::Rejected);
        emit billRejected();
        return;
    }

    if (deviceDisabled) {
        setState(ValidatorState::Disabled);
        return;
    }

    // ── Data 0: State bits ───────────────────────────────────────
    //   bit 0: Idling
    //   bit 1: Accepting
    //   bit 2: Escrowed
    //   bit 3: Stacking
    //   bit 4: Stacked
    //   bit 5: Returning
    //   bit 6: Returned

    bool idling    = data0 & 0x01;
    bool accepting = data0 & 0x02;
    bool escrowed  = data0 & 0x04;
    bool stacking  = data0 & 0x08;
    bool stacked   = data0 & 0x10;
    bool returning = data0 & 0x20;
    bool returned  = data0 & 0x40;

    // Check for cashbox removed (transport open bit)
    bool transportOpen = data2 & 0x40;
    if (transportOpen) {
        setState(ValidatorState::CashboxRemoved);
        emit error(ValidatorError::CashboxRemoved,
                   QStringLiteral("Cashbox removed or not detected"));
        return;
    }

    if (stacked) {
        handleStackedState(denomBits);
    } else if (returned) {
        setState(ValidatorState::Returned);
        emit billReturned();
    } else if (escrowed) {
        handleEscrowedState(denomBits);
    } else if (stacking) {
        setState(ValidatorState::Stacking);
    } else if (returning) {
        setState(ValidatorState::Returning);
    } else if (accepting) {
        setState(ValidatorState::Accepting);
    } else if (idling) {
        setState(ValidatorState::Idling);
        m_powerUpSeen = false;  // Reset for next power cycle
    } else if (powerUp) {
        setState(ValidatorState::PowerUp);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// State helpers
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorDriver::setState(ValidatorState newState)
{
    if (m_state != newState) {
        m_state = newState;
        emit stateChanged(newState);
    }
}

// Denomination mapping for a typical configuration:
//   1=$1, 2=$5, 3=$10, 4=$20, 5=$50, 6=$100, 7=reserved
// These are device/variant specific, so we report the raw index.
static constexpr int kDenomValues[] = {0, 100, 500, 1000, 2000, 5000, 10000, 0};

void ValidatorDriver::handleEscrowedState(uint8_t denomBits)
{
    int denom = (denomBits < 8) ? kDenomValues[denomBits] : 0;

    if (m_state != ValidatorState::Escrowed) {
        m_escrowedDenomination = denom;
        m_escrowedNoteIndex = denomBits;
        setState(ValidatorState::Escrowed);
        emit billEscrowed(denom, denomBits);
    }
}

void ValidatorDriver::handleStackedState(uint8_t denomBits)
{
    int denom = (denomBits < 8) ? kDenomValues[denomBits] : 0;

    if (denom == 0 && m_escrowedDenomination > 0) {
        // Use the cached escrow value (§5.2.4 — value is cleared after stacked)
        denom = m_escrowedDenomination;
    }

    m_lastStackedDenomination = denom;
    setState(ValidatorState::Stacked);
    emit billStacked(denom);

    // Reset escrow cache
    m_escrowedDenomination = 0;
    m_escrowedNoteIndex = 0;
}

void ValidatorDriver::sendPacket(const QByteArray &packet)
{
    if (!m_serial.isOpen())
        return;
    m_serial.write(packet);
    m_serial.flush();
}

bool ValidatorDriver::openPort()
{
    if (m_serial.portName().isEmpty()) {
        qWarning() << "[ValidatorDriver] No port name set";
        return false;
    }

    if (m_serial.isOpen())
        return true;

    if (!m_serial.open(QIODevice::ReadWrite)) {
        qWarning() << "[ValidatorDriver] Failed to open" << m_serial.portName()
                    << ":" << m_serial.errorString();
        return false;
    }

    m_serial.clear();
    m_rxBuffer.clear();
    qDebug() << "[ValidatorDriver] Port opened:" << m_serial.portName();
    return true;
}

void ValidatorDriver::closePort()
{
    if (m_serial.isOpen()) {
        m_serial.close();
        qDebug() << "[ValidatorDriver] Port closed";
    }
    m_rxBuffer.clear();
    m_deviceConnected = false;
}
