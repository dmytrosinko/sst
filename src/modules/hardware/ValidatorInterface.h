#pragma once

#include "ValidatorTypes.h"

#include <QObject>
#include <cstdint>

namespace hardware {

/// Abstract interface for cash bill validators.
///
/// Both the real EBDS serial driver and the software emulator implement
/// this interface. The ValidatorController selects the concrete backend
/// at compile time via the USE_DEVICE_EMULATOR flag.
///
/// Transaction flow (EBDS G7 §5.2):
///   Idle → Accepting → Escrowed → [acceptBill / rejectBill] → Stacked / Returned → Idle
class ValidatorInterface : public QObject
{
    Q_OBJECT

public:
    explicit ValidatorInterface(QObject *parent = nullptr)
        : QObject(parent) {}

    virtual ~ValidatorInterface() = default;

    // ── Commands ────────────────────────────────────────────────

    /// Start polling / enable acceptance.
    virtual void start() = 0;

    /// Stop polling / disable acceptance.
    virtual void stop() = 0;

    /// Accept (stack) the document currently in escrow.
    virtual void acceptBill() = 0;

    /// Return (reject) the document currently in escrow.
    virtual void rejectBill() = 0;

    /// Enable/disable denominations via a 7-bit mask (EBDS Data Byte 0, bits 0-6).
    /// Bit 0 = denom 1, bit 6 = denom 7.
    virtual void setDenominationsEnabled(uint8_t mask) = 0;

    // ── Queries ─────────────────────────────────────────────────

    /// Current device state.
    virtual ValidatorState state() const = 0;

    /// Whether the device is actively accepting bills.
    virtual bool isAccepting() const = 0;

signals:
    // ── Signals ─────────────────────────────────────────────────

    /// Emitted on any state transition.
    void stateChanged(hardware::ValidatorState newState);

    /// Document validated, in escrow — host must decide stack or return.
    /// @param denomination  Bill value in minor currency units (e.g. cents).
    /// @param noteIndex     EBDS note table index (useful for extended reporting).
    void billEscrowed(int denomination, int noteIndex);

    /// Document permanently stacked in cashbox — safe to issue credit.
    void billStacked(int denomination);

    /// Document returned to customer.
    void billReturned();

    /// Document not recognized or could not be transported.
    void billRejected();

    /// Hardware or communication error.
    void error(hardware::ValidatorError error, const QString &description);

    /// Connection status changed.
    void connectedChanged(bool connected);
};

} // namespace hardware
