#include "ValidatorEmulator.h"

#include <QDebug>

using namespace hardware;

// Include the moc files in the correct order so that
// ValidatorInterface::staticMetaObject is defined first.
// AUTOMOC's mocs_compilation may include them in alphabetical order,
// causing C2737 on MSVC when the derived class moc references the
// base class's staticMetaObject before it's been defined.
#include "moc_ValidatorInterface.cpp"
#include "moc_ValidatorEmulator.cpp"

ValidatorEmulator::ValidatorEmulator(QObject *parent)
    : ValidatorInterface(parent)
{
    m_transitionTimer.setSingleShot(true);
    connect(&m_transitionTimer, &QTimer::timeout, this, [this]() {
        if (m_transitionAction) {
            auto action = std::move(m_transitionAction);
            m_transitionAction = nullptr;
            action();
        }
    });
}

ValidatorEmulator::~ValidatorEmulator() = default;

// ─────────────────────────────────────────────────────────────────────────────
// ValidatorInterface
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorEmulator::start()
{
    if (m_accepting)
        return;

    m_accepting = true;
    emit connectedChanged(true);

    // Simulate power-up → idle sequence
    setState(ValidatorState::PowerUp);

    m_transitionAction = [this]() { transitionToIdle(); };
    m_transitionTimer.start(POWERUP_DELAY_MS);

    qDebug() << "[ValidatorEmulator] Started — simulating power-up";
}

void ValidatorEmulator::stop()
{
    m_accepting = false;
    m_transitionTimer.stop();
    m_transitionAction = nullptr;
    setState(ValidatorState::Disabled);
    emit connectedChanged(false);
    qDebug() << "[ValidatorEmulator] Stopped";
}

void ValidatorEmulator::acceptBill()
{
    if (m_state != ValidatorState::Escrowed) {
        qWarning() << "[ValidatorEmulator] acceptBill() called but state is"
                    << static_cast<int>(m_state);
        return;
    }

    setState(ValidatorState::Stacking);
    int denom = m_pendingDenomination;

    m_transitionAction = [this, denom]() {
        setState(ValidatorState::Stacked);
        emit billStacked(denom);
        qDebug() << "[ValidatorEmulator] Bill stacked:" << denom;

        // After stacked, return to idle
        m_transitionAction = [this]() { transitionToIdle(); };
        m_transitionTimer.start(200);
    };
    m_transitionTimer.start(STACKING_DELAY_MS);
}

void ValidatorEmulator::rejectBill()
{
    if (m_state != ValidatorState::Escrowed) {
        qWarning() << "[ValidatorEmulator] rejectBill() called but state is"
                    << static_cast<int>(m_state);
        return;
    }

    setState(ValidatorState::Returning);

    m_transitionAction = [this]() {
        setState(ValidatorState::Returned);
        emit billReturned();
        qDebug() << "[ValidatorEmulator] Bill returned to customer";

        // After returned, back to idle
        m_transitionAction = [this]() { transitionToIdle(); };
        m_transitionTimer.start(200);
    };
    m_transitionTimer.start(RETURNING_DELAY_MS);
}

void ValidatorEmulator::setDenominationsEnabled(uint8_t mask)
{
    m_denomMask = mask & 0x7F;
}

ValidatorState ValidatorEmulator::state() const
{
    return m_state;
}

bool ValidatorEmulator::isAccepting() const
{
    return m_accepting && m_state == ValidatorState::Idling;
}

// ─────────────────────────────────────────────────────────────────────────────
// Emulation controls
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorEmulator::insertBill(int denomination)
{
    if (!m_accepting) {
        qWarning() << "[ValidatorEmulator] Cannot insert bill — not accepting";
        return;
    }

    if (m_state != ValidatorState::Idling) {
        qWarning() << "[ValidatorEmulator] Cannot insert bill — not idle, state:"
                    << static_cast<int>(m_state);
        return;
    }

    m_pendingDenomination = denomination;

    // Accepting phase: bill being transported in
    setState(ValidatorState::Accepting);

    m_transitionAction = [this, denomination]() {
        // Bill validated, now in escrow
        setState(ValidatorState::Escrowed);
        emit billEscrowed(denomination, 0);
        qDebug() << "[ValidatorEmulator] Bill escrowed:" << denomination
                 << "— waiting for host decision (acceptBill / rejectBill)";
    };
    m_transitionTimer.start(ACCEPTING_DELAY_MS);
}

void ValidatorEmulator::simulateReject()
{
    if (m_state != ValidatorState::Accepting && m_state != ValidatorState::Idling) {
        qWarning() << "[ValidatorEmulator] simulateReject() — invalid state";
        return;
    }

    setState(ValidatorState::Rejected);
    emit billRejected();

    m_transitionAction = [this]() { transitionToIdle(); };
    m_transitionTimer.start(300);
}

void ValidatorEmulator::simulateJam()
{
    setState(ValidatorState::Jammed);
    emit error(ValidatorError::Jam, QStringLiteral("Simulated document jam"));
    qDebug() << "[ValidatorEmulator] JAM simulated";
}

void ValidatorEmulator::clearJam()
{
    if (m_state != ValidatorState::Jammed) {
        qWarning() << "[ValidatorEmulator] clearJam() but not jammed";
        return;
    }

    transitionToIdle();
    qDebug() << "[ValidatorEmulator] Jam cleared";
}

void ValidatorEmulator::simulateCashboxFull()
{
    setState(ValidatorState::StackerFull);
    emit error(ValidatorError::CashboxFull, QStringLiteral("Simulated stacker full"));
    qDebug() << "[ValidatorEmulator] Stacker FULL simulated";
}

void ValidatorEmulator::simulateCashboxRemoved()
{
    setState(ValidatorState::CashboxRemoved);
    emit error(ValidatorError::CashboxRemoved, QStringLiteral("Simulated cashbox removal"));
    qDebug() << "[ValidatorEmulator] Cashbox REMOVED simulated";
}

void ValidatorEmulator::simulateCashboxInserted()
{
    if (m_state == ValidatorState::CashboxRemoved || m_state == ValidatorState::StackerFull) {
        transitionToIdle();
        qDebug() << "[ValidatorEmulator] Cashbox inserted — resuming";
    }
}

void ValidatorEmulator::simulatePowerCycle()
{
    m_transitionTimer.stop();
    m_transitionAction = nullptr;

    setState(ValidatorState::PowerUp);
    emit error(ValidatorError::PowerUp, QStringLiteral("Simulated power cycle"));

    m_transitionAction = [this]() { transitionToIdle(); };
    m_transitionTimer.start(POWERUP_DELAY_MS);

    qDebug() << "[ValidatorEmulator] Power cycle simulated";
}

void ValidatorEmulator::simulateCheat()
{
    setState(ValidatorState::Cheated);
    emit error(ValidatorError::Cheated, QStringLiteral("Simulated cheat attempt"));

    m_pendingDenomination = 0;

    m_transitionAction = [this]() { transitionToIdle(); };
    m_transitionTimer.start(1000);

    qDebug() << "[ValidatorEmulator] CHEAT simulated";
}

// ─────────────────────────────────────────────────────────────────────────────
// Internals
// ─────────────────────────────────────────────────────────────────────────────

void ValidatorEmulator::setState(ValidatorState newState)
{
    if (m_state != newState) {
        m_state = newState;
        emit stateChanged(newState);
    }
}

void ValidatorEmulator::transitionToIdle()
{
    m_transitionAction = nullptr;
    m_pendingDenomination = 0;
    if (m_accepting) {
        setState(ValidatorState::Idling);
    } else {
        setState(ValidatorState::Disabled);
    }
}
