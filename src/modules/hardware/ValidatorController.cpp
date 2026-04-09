#include "ValidatorController.h"
#include "ValidatorInterface.h"

#ifdef USE_DEVICE_EMULATOR
#include "ValidatorEmulator.h"
#else
#include "ValidatorDriver.h"
#include "PortScanner.h"
#endif

#include <QDebug>

// Include moc in this TU to guarantee definition order.
// AUTOMOC's mocs_compilation.cpp includes moc files alphabetically,
// which can fail with MSVC constexpr when derived-class moc references
// a base-class staticMetaObject not yet defined in the same TU.
#include "moc_ValidatorController.cpp"

using namespace hardware;

// ─────────────────────────────────────────────────────────────────────────────
// Construction
// ─────────────────────────────────────────────────────────────────────────────

ValidatorController::ValidatorController(QObject *parent)
    : QObject(parent)
{
#ifdef USE_DEVICE_EMULATOR
    qDebug() << "[ValidatorController] Using EMULATOR backend";
    m_validator = new ValidatorEmulator(this);
    connectValidatorSignals();
#else
    qDebug() << "[ValidatorController] Using DRIVER backend — scanning for device...";
    m_portScanner = new PortScanner(this);
    connect(m_portScanner, &PortScanner::validatorFound,
            this, &ValidatorController::onValidatorFound);
    connect(m_portScanner, &PortScanner::scanFinished,
            this, &ValidatorController::onScanFinished);
    m_portScanner->startScan();
#endif
}

ValidatorController::~ValidatorController() = default;

// ─────────────────────────────────────────────────────────────────────────────
// Properties
// ─────────────────────────────────────────────────────────────────────────────

int ValidatorController::stateInt() const
{
    if (!m_validator)
        return static_cast<int>(ValidatorState::Disconnected);
    return static_cast<int>(m_validator->state());
}

QString ValidatorController::stateName() const
{
    if (!m_validator)
        return QStringLiteral("Disconnected");

    switch (m_validator->state()) {
    case ValidatorState::Disconnected:   return QStringLiteral("Disconnected");
    case ValidatorState::PowerUp:        return QStringLiteral("Power Up");
    case ValidatorState::Idling:         return QStringLiteral("Idling");
    case ValidatorState::Accepting:      return QStringLiteral("Accepting");
    case ValidatorState::Escrowed:       return QStringLiteral("Escrowed");
    case ValidatorState::Stacking:       return QStringLiteral("Stacking");
    case ValidatorState::Stacked:        return QStringLiteral("Stacked");
    case ValidatorState::Returning:      return QStringLiteral("Returning");
    case ValidatorState::Returned:       return QStringLiteral("Returned");
    case ValidatorState::Rejected:       return QStringLiteral("Rejected");
    case ValidatorState::Jammed:         return QStringLiteral("Jammed");
    case ValidatorState::StackerFull:    return QStringLiteral("Stacker Full");
    case ValidatorState::CashboxRemoved: return QStringLiteral("Cashbox Removed");
    case ValidatorState::Failure:        return QStringLiteral("Failure");
    case ValidatorState::Disabled:       return QStringLiteral("Disabled");
    case ValidatorState::Calibrating:    return QStringLiteral("Calibrating");
    case ValidatorState::Cheated:        return QStringLiteral("Cheated");
    }
    return QStringLiteral("Unknown");
}

int ValidatorController::totalAmount() const
{
    return m_totalAmount;
}

QString ValidatorController::formattedAmount() const
{
    // totalAmount is in minor units (e.g. cents/tiyin).
    // Format as "X.XX CUR".
    double major = m_totalAmount / 100.0;
    return QStringLiteral("%1 %2")
        .arg(major, 0, 'f', 2)
        .arg(m_currency);
}

QString ValidatorController::currency() const
{
    return m_currency;
}

void ValidatorController::setCurrency(const QString &currency)
{
    if (m_currency != currency) {
        m_currency = currency;
        emit currencyChanged();
        emit totalAmountChanged(); // formattedAmount depends on currency
    }
}

int ValidatorController::lastBillDenomination() const
{
    return m_lastBillDenomination;
}

QString ValidatorController::lastError() const
{
    return m_lastError;
}

bool ValidatorController::isConnected() const
{
    return m_connected;
}

bool ValidatorController::isAccepting() const
{
    return m_accepting;
}

// ─────────────────────────────────────────────────────────────────────────────
// Q_INVOKABLE methods
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorController::activate()
{
    if (!m_validator) {
        qWarning() << "[ValidatorController] No backend available";
        return;
    }

    // Reset session accumulator on activation
    m_totalAmount = 0;
    m_lastBillDenomination = 0;
    m_escrowedDenomination = 0;
    m_lastError.clear();
    emit totalAmountChanged();
    emit lastBillDenominationChanged();
    emit lastErrorChanged();

    m_validator->start();
    m_accepting = true;
    emit acceptingChanged();
    qDebug() << "[ValidatorController] Activated — ready to accept cash";
}

void ValidatorController::deactivate()
{
    if (!m_validator)
        return;

    m_validator->stop();
    m_accepting = false;
    emit acceptingChanged();
    qDebug() << "[ValidatorController] Deactivated";
}

void ValidatorController::acceptBill()
{
    if (!m_validator)
        return;

    m_validator->acceptBill();
}

void ValidatorController::rejectBill()
{
    if (!m_validator)
        return;

    m_validator->rejectBill();
}

void ValidatorController::resetTotal()
{
    m_totalAmount = 0;
    emit totalAmountChanged();
}

#ifdef USE_DEVICE_EMULATOR
ValidatorEmulator *ValidatorController::emulator() const
{
    return qobject_cast<ValidatorEmulator *>(m_validator);
}
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Signal handlers from ValidatorInterface
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorController::onStateChanged(ValidatorState newState)
{
    Q_UNUSED(newState)
    emit stateChanged();
}

void ValidatorController::onBillEscrowed(int denomination, int noteIndex)
{
    Q_UNUSED(noteIndex)
    m_escrowedDenomination = denomination;
    qDebug() << "[ValidatorController] Bill escrowed:" << denomination;
}

void ValidatorController::onBillStacked(int denomination)
{
    m_lastBillDenomination = denomination;
    emit lastBillDenominationChanged();

    m_totalAmount += denomination;
    emit totalAmountChanged();

    emit cashInserted(denomination, m_totalAmount);

    qDebug() << "[ValidatorController] Bill stacked:" << denomination
             << "| Total:" << m_totalAmount;
}

void ValidatorController::onBillReturned()
{
    m_escrowedDenomination = 0;
    qDebug() << "[ValidatorController] Bill returned to customer";
}

void ValidatorController::onBillRejected()
{
    qDebug() << "[ValidatorController] Bill rejected";
}

void ValidatorController::onError(ValidatorError err, const QString &description)
{
    Q_UNUSED(err)
    m_lastError = description;
    emit lastErrorChanged();
    qWarning() << "[ValidatorController] Error:" << description;
}

void ValidatorController::onConnectedChanged(bool connected)
{
    if (m_connected != connected) {
        m_connected = connected;
        emit connectedChanged();
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// PortScanner callbacks (driver mode only)
// ─────────────────────────────────────────────────────────────────────────────

#ifndef USE_DEVICE_EMULATOR
void ValidatorController::onValidatorFound(const QString &portName)
{
    qDebug() << "[ValidatorController] Validator detected on" << portName;

    auto *driver = new ValidatorDriver(this);
    driver->setPortName(portName);

    m_validator = driver;
    connectValidatorSignals();
}

void ValidatorController::onScanFinished(bool found, const QString &portName)
{
    if (!found) {
        qWarning() << "[ValidatorController] No validator found on any serial port";
        m_lastError = QStringLiteral("No validator hardware detected");
        emit lastErrorChanged();
    } else {
        qDebug() << "[ValidatorController] Scan complete — validator on" << portName;
    }
}
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Internals
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorController::connectValidatorSignals()
{
    if (!m_validator)
        return;

    connect(m_validator, &ValidatorInterface::stateChanged,
            this, &ValidatorController::onStateChanged);
    connect(m_validator, &ValidatorInterface::billEscrowed,
            this, &ValidatorController::onBillEscrowed);
    connect(m_validator, &ValidatorInterface::billStacked,
            this, &ValidatorController::onBillStacked);
    connect(m_validator, &ValidatorInterface::billReturned,
            this, &ValidatorController::onBillReturned);
    connect(m_validator, &ValidatorInterface::billRejected,
            this, &ValidatorController::onBillRejected);
    connect(m_validator, &ValidatorInterface::error,
            this, &ValidatorController::onError);
    connect(m_validator, &ValidatorInterface::connectedChanged,
            this, &ValidatorController::onConnectedChanged);
}
