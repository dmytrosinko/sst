#pragma once

#include "TransactionSession.h"
#include "TransactionStatus.h"

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

namespace finance {

class FinanceBackend;

/// QML-facing controller for managing financial transaction sessions.
///
/// Singleton accessible in QML as TransactionController.
/// Follows the same pattern as ValidatorController in the hardware module.
///
/// Typical QML usage:
///   TransactionController.startSession(serviceId, serviceName)
///   TransactionController.setParam("phone", "0555123456")
///   TransactionController.setAmount(ValidatorController.totalAmount)
///   TransactionController.send()
///   // ... wait for statusChanged → Success or Error
///   TransactionController.cancelSession()
class TransactionController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool hasActiveSession READ hasActiveSession NOTIFY sessionChanged)
    Q_PROPERTY(int status READ statusInt NOTIFY statusChanged)
    Q_PROPERTY(QString statusName READ statusName NOTIFY statusChanged)
    Q_PROPERTY(int serviceId READ serviceId NOTIFY sessionChanged)
    Q_PROPERTY(QString serviceName READ serviceName NOTIFY sessionChanged)
    Q_PROPERTY(int amount READ amount NOTIFY amountChanged)
    Q_PROPERTY(QString formattedAmount READ formattedAmount NOTIFY amountChanged)
    Q_PROPERTY(int commission READ commission NOTIFY commissionChanged)
    Q_PROPERTY(QString formattedCommission READ formattedCommission NOTIFY commissionChanged)
    Q_PROPERTY(QString currency READ currency WRITE setCurrency NOTIFY currencyChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY statusChanged)
    Q_PROPERTY(bool isCommissionLoading READ isCommissionLoading NOTIFY commissionLoadingChanged)

public:
    explicit TransactionController(QObject *parent = nullptr);
    ~TransactionController() override;

    // ── Q_PROPERTY getters ──────────────────────────────────────────
    bool    hasActiveSession() const;
    int     statusInt() const;
    QString statusName() const;
    int     serviceId() const;
    QString serviceName() const;
    int     amount() const;
    QString formattedAmount() const;
    int     commission() const;
    QString formattedCommission() const;
    QString currency() const;
    void    setCurrency(const QString &currency);
    QString errorMessage() const;
    bool    isCommissionLoading() const;

    // ── Q_INVOKABLE — called from QML ───────────────────────────────

    /// Create a new transaction session for a service.
    /// Resets any previous session. Status → Created.
    Q_INVOKABLE void startSession(int serviceId, const QString &serviceName);

    /// Set a service-specific input param (phone, card, IBAN, etc.).
    Q_INVOKABLE void setParam(const QString &key, const QString &value);

    /// Get a previously set param value.
    Q_INVOKABLE QString param(const QString &key) const;

    /// Set the inserted cash amount (minor units).
    /// Automatically triggers an async commission fetch from the backend.
    Q_INVOKABLE void setAmount(int amountMinorUnits);

    /// Check if all required conditions are met (amount > 0).
    /// If yes, status → Ready. Returns true on success.
    Q_INVOKABLE bool markReady();

    /// Send the transaction to the financial host.
    /// Status → Sent. Triggers async backend call.
    Q_INVOKABLE void send();

    /// Cancel and clear the current session.
    Q_INVOKABLE void cancelSession();

    /// Get the receipt data for display in the result screen.
    Q_INVOKABLE QVariantMap receiptData() const;

signals:
    void sessionChanged();
    void statusChanged();
    void amountChanged();
    void commissionChanged();
    void commissionLoadingChanged();
    void currencyChanged();
    void paramsChanged();

    /// Emitted when the transaction reaches a terminal state (Success or Error).
    void sessionCompleted(bool success);

private slots:
    void onCommissionReceived(int commissionMinorUnits);
    void onTransactionResult(bool success, const QString &transactionId,
                             const QString &errorMessage);

private:
    /// Format an amount in minor units to a display string, e.g. "1 500.00 KGS"
    QString formatAmount(int minorUnits) const;

    void setStatus(TransactionStatus newStatus);

    TransactionSession m_session;
    FinanceBackend    *m_backend = nullptr;
    QString            m_currency = QStringLiteral("KGS");
    bool               m_commissionLoading = false;
};

} // namespace finance
