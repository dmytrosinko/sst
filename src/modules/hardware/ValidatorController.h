#pragma once

#include "ValidatorTypes.h"

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QString>

namespace hardware {

class ValidatorInterface;
class ValidatorEmulator;
class PortScanner;

/// Bridge between the validator backend (driver or emulator) and the
/// application / QML layer.
///
/// At compile time, selects the backend via USE_DEVICE_EMULATOR:
///   - ON:  instantiates ValidatorEmulator
///   - OFF: instantiates ValidatorDriver + auto-detects port via PortScanner
///
/// Exposes a clean, high-level API for QML:
///   - startAccepting / stopAccepting / acceptBill / rejectBill
///   - Properties: state, totalAmount, lastBillDenomination, connected, etc.
///   - Signal: cashInserted(denomination, totalAmount)
class ValidatorController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int state READ stateInt NOTIFY stateChanged)
    Q_PROPERTY(QString stateName READ stateName NOTIFY stateChanged)
    Q_PROPERTY(int totalAmount READ totalAmount NOTIFY totalAmountChanged)
    Q_PROPERTY(QString formattedAmount READ formattedAmount NOTIFY totalAmountChanged)
    Q_PROPERTY(QString currency READ currency WRITE setCurrency NOTIFY currencyChanged)
    Q_PROPERTY(int lastBillDenomination READ lastBillDenomination NOTIFY lastBillDenominationChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(bool accepting READ isAccepting NOTIFY acceptingChanged)

public:
    explicit ValidatorController(QObject *parent = nullptr);
    ~ValidatorController() override;

    // ── Q_PROPERTY getters ──────────────────────────────────────
    int stateInt() const;
    QString stateName() const;
    int totalAmount() const;
    QString formattedAmount() const;
    QString currency() const;
    void setCurrency(const QString &currency);
    int lastBillDenomination() const;
    QString lastError() const;
    bool isConnected() const;
    bool isAccepting() const;

    // ── Q_INVOKABLE ─────────────────────────────────────────────

    /// Activate the validator for a cash-accepting session.
    /// Resets the total, then enables acceptance.
    /// Call when ScreenInsertCash opens.
    Q_INVOKABLE void activate();

    /// Deactivate the validator — stop accepting bills.
    /// Call when ScreenInsertCash closes / navigates away.
    Q_INVOKABLE void deactivate();

    /// Accept (stack) the bill currently in escrow and add to total.
    Q_INVOKABLE void acceptBill();

    /// Reject (return) the bill currently in escrow.
    Q_INVOKABLE void rejectBill();

    /// Reset the session accumulator to zero.
    Q_INVOKABLE void resetTotal();

#ifdef USE_DEVICE_EMULATOR
    /// Direct access to the emulator for QML test panels.
    /// Only available in emulator builds.
    Q_INVOKABLE hardware::ValidatorEmulator *emulator() const;
#endif

signals:
    void stateChanged();
    void totalAmountChanged();
    void currencyChanged();
    void lastBillDenominationChanged();
    void lastErrorChanged();
    void connectedChanged();
    void acceptingChanged();

    /// Emitted after a bill is successfully stacked and credited.
    void cashInserted(int denomination, int totalAmount);

private slots:
    void onStateChanged(hardware::ValidatorState newState);
    void onBillEscrowed(int denomination, int noteIndex);
    void onBillStacked(int denomination);
    void onBillReturned();
    void onBillRejected();
    void onError(hardware::ValidatorError error, const QString &description);
    void onConnectedChanged(bool connected);

#ifndef USE_DEVICE_EMULATOR
    void onValidatorFound(const QString &portName);
    void onScanFinished(bool found, const QString &portName);
#endif

private:
    void connectValidatorSignals();

    ValidatorInterface *m_validator = nullptr;
    bool m_connected = false;
    bool m_accepting = false;

    int m_totalAmount = 0;
    int m_lastBillDenomination = 0;
    int m_escrowedDenomination = 0;
    QString m_lastError;
    QString m_currency = QStringLiteral("KGS");

#ifndef USE_DEVICE_EMULATOR
    PortScanner *m_portScanner = nullptr;
#endif
};

} // namespace hardware
