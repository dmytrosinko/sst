#pragma once

#include "ValidatorInterface.h"

#include <QSerialPort>
#include <QTimer>
#include <QByteArray>
#include <QVector>

namespace hardware {

/// EBDS protocol driver for MEI SC Advance (SCN83) bill validators.
///
/// Implements the full EBDS G7 polling protocol over RS-232:
///   - 9600 baud, 7 data bits, even parity, 1 stop bit
///   - 200ms polling interval (Normal/Polled mode)
///   - ACK/NAK toggle handshake (§6.3)
///   - Omnibus command/reply (Type 1/2, §7.1)
///   - Extended note reporting (Type 7, §7.5.2)
///   - Escrow mode with stack/return commands
///
/// This class is NOT a QML_ELEMENT — it is created internally by
/// ValidatorController (or PortScanner for detection).
class ValidatorDriver : public ValidatorInterface
{
    Q_OBJECT

public:
    explicit ValidatorDriver(QObject *parent = nullptr);
    ~ValidatorDriver() override;

    // ── ValidatorInterface ──────────────────────────────────────
    void start() override;
    void stop() override;
    void acceptBill() override;
    void rejectBill() override;
    void setDenominationsEnabled(uint8_t mask) override;
    ValidatorState state() const override;
    bool isAccepting() const override;

    // ── Driver-specific ─────────────────────────────────────────

    /// Set the serial port name (e.g. "COM3" or "/dev/ttyUSB0").
    /// Must be called before start().
    void setPortName(const QString &portName);
    QString portName() const;

    /// Attempt to open the port and verify an EBDS device responds.
    /// Returns true if the device replied to a probe poll.
    bool probeDevice();

private slots:
    void onPollTimeout();
    void onReadyRead();
    void onSerialError(QSerialPort::SerialPortError error);

private:
    // ── EBDS protocol constants ─────────────────────────────────
    static constexpr uint8_t STX = 0x02;
    static constexpr uint8_t ETX = 0x03;
    static constexpr uint8_t ENQ = 0x05;

    // Message types (bits 4-6 of CTRL byte)
    static constexpr uint8_t MSG_TYPE_OMNIBUS_CMD     = 0x10;  // Type 1
    static constexpr uint8_t MSG_TYPE_OMNIBUS_REPLY    = 0x20;  // Type 2
    static constexpr uint8_t MSG_TYPE_AUX_CMD          = 0x60;  // Type 6
    static constexpr uint8_t MSG_TYPE_EXTENDED_CMD     = 0x70;  // Type 7

    // Timing (§3.3.1)
    static constexpr int POLL_INTERVAL_MS     = 200;   // Recommended
    static constexpr int RESPONSE_TIMEOUT_MS  = 35;    // Max peripheral response time
    static constexpr int INTER_CHAR_TIMEOUT_MS = 20;   // Max inter-character gap

    // Retry limits (§5.4.1.1)
    static constexpr int MAX_RETRIES_SAME_ACK  = 10;
    static constexpr int MAX_RETRIES_TOGGLED   = 10;

    // Omnibus command size
    static constexpr int OMNIBUS_CMD_LENGTH = 8;

    // ── Packet building ─────────────────────────────────────────
    QByteArray buildOmnibusCommand() const;
    QByteArray buildExtendedNoteQuery(int noteIndex) const;
    static uint8_t calculateChecksum(const QByteArray &packet);

    // ── Reply parsing ───────────────────────────────────────────
    bool parseOmnibusReply(const QByteArray &reply);
    void processDeviceState(uint8_t data0, uint8_t data1, uint8_t data2,
                            uint8_t data3, uint8_t data4, uint8_t data5);

    // ── State management ────────────────────────────────────────
    void setState(ValidatorState newState);
    void handleEscrowedState(uint8_t denomBits);
    void handleStackedState(uint8_t denomBits);
    void sendPacket(const QByteArray &packet);
    bool openPort();
    void closePort();

    // ── Members ─────────────────────────────────────────────────
    QSerialPort m_serial;
    QTimer m_pollTimer;
    QByteArray m_rxBuffer;

    ValidatorState m_state = ValidatorState::Disconnected;
    bool m_accepting = false;

    // ACK/NAK toggle (§6.3)
    bool m_ackBit = false;
    bool m_ackToggled = false;
    int m_retryCount = 0;
    bool m_waitingForReply = false;

    // Command state
    bool m_stackCommand = false;     // Data 1, bit 5
    bool m_returnCommand = false;    // Data 1, bit 6
    uint8_t m_denomMask = 0x7F;      // All 7 denominations enabled

    // Note tracking
    int m_escrowedDenomination = 0;
    int m_escrowedNoteIndex = 0;
    int m_lastStackedDenomination = 0;

    // Device info (from omnibus reply bytes 4-5)
    uint8_t m_modelNumber = 0;
    uint8_t m_codeRevision = 0;

    // Power-up flag: first valid reply sets this
    bool m_deviceConnected = false;
    bool m_powerUpSeen = false;
};

} // namespace hardware
