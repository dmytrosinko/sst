#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>

class QTimer;

namespace finance {

/// Simulated financial backend.
///
/// Abstracts the remote API so it can later be swapped for real HTTP calls.
/// For now, uses QTimer delays to simulate network latency.
class FinanceBackend : public QObject
{
    Q_OBJECT

public:
    explicit FinanceBackend(QObject *parent = nullptr);

    /// Request commission for a given service + amount.
    /// Emits commissionReceived() after a simulated delay (~300ms).
    void requestCommission(int serviceId, int amountMinorUnits);

    /// Send the transaction to the "financial host".
    /// Emits transactionResult() after a simulated delay (~800ms).
    void sendTransaction(const QString &sessionId, int serviceId,
                         const QVariantMap &params, int amount, int commission);

    /// Cancel any in-flight requests (e.g. pending commission timer).
    void cancelPending();

signals:
    /// Commission response from the "server".
    /// @param commissionMinorUnits  the calculated commission in minor units.
    void commissionReceived(int commissionMinorUnits);

    /// Transaction result from the "server".
    /// @param success        true if the transaction was accepted.
    /// @param transactionId  server-assigned transaction ID (on success).
    /// @param errorMessage   error description (on failure).
    void transactionResult(bool success, const QString &transactionId,
                           const QString &errorMessage);

private:
    QTimer *m_commissionTimer = nullptr;
    QTimer *m_sendTimer       = nullptr;
};

} // namespace finance
