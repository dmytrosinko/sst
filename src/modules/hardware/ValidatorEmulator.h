#pragma once

#include "ValidatorInterface.h"

#include <QTimer>
#include <functional>

namespace hardware {

/// Software emulator for the MEI SCN83 bill validator.
///
/// Implements ValidatorInterface with a simulated state machine
/// that mirrors real EBDS behavior including realistic timing.
/// Exposes Q_INVOKABLE methods so testers / QML test UI can
/// trigger bill insertions, jams, and other conditions.
///
/// Registered as a QML_ELEMENT so it can be instantiated directly
/// in QML test panels when USE_DEVICE_EMULATOR is active.
class ValidatorEmulator : public ValidatorInterface
{
    Q_OBJECT

public:
    explicit ValidatorEmulator(QObject *parent = nullptr);
    ~ValidatorEmulator() override;

    // ── ValidatorInterface ──────────────────────────────────────
    void start() override;
    void stop() override;
    void acceptBill() override;
    void rejectBill() override;
    void setDenominationsEnabled(uint8_t mask) override;
    ValidatorState state() const override;
    bool isAccepting() const override;

    // ── Emulation controls (Q_INVOKABLE for QML) ────────────────

    /// Simulate inserting a bill with the given denomination (in minor units).
    /// Triggers the full flow: Accepting → Escrowed → wait for host decision.
    Q_INVOKABLE void insertBill(int denomination);

    /// Simulate a document being rejected (not recognized).
    Q_INVOKABLE void simulateReject();

    /// Simulate a transport jam.
    Q_INVOKABLE void simulateJam();

    /// Clear jam condition and return to idling.
    Q_INVOKABLE void clearJam();

    /// Simulate cashbox full condition.
    Q_INVOKABLE void simulateCashboxFull();

    /// Simulate cashbox removal.
    Q_INVOKABLE void simulateCashboxRemoved();

    /// Simulate inserting cashbox back.
    Q_INVOKABLE void simulateCashboxInserted();

    /// Simulate a full power-off / power-on cycle.
    Q_INVOKABLE void simulatePowerCycle();

    /// Simulate a cheat attempt detection.
    Q_INVOKABLE void simulateCheat();

private:
    void setState(ValidatorState newState);
    void transitionToIdle();

    // ── Simulated timing ────────────────────────────────────────
    static constexpr int ACCEPTING_DELAY_MS = 800;   // Realistic transport time
    static constexpr int STACKING_DELAY_MS  = 500;   // Stacker motor time
    static constexpr int RETURNING_DELAY_MS = 400;   // Return transport time
    static constexpr int POWERUP_DELAY_MS   = 2000;  // Power-up initialization

    ValidatorState m_state = ValidatorState::Disconnected;
    bool m_accepting = false;
    uint8_t m_denomMask = 0x7F;

    int m_pendingDenomination = 0;

    QTimer m_transitionTimer;
    std::function<void()> m_transitionAction;
};

} // namespace hardware
