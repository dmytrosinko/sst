#include "FinanceBackend.h"

#include <QTimer>
#include <QUuid>
#include <QDebug>

namespace finance {

FinanceBackend::FinanceBackend(QObject *parent)
    : QObject(parent)
    , m_commissionTimer(new QTimer(this))
    , m_sendTimer(new QTimer(this))
{
    m_commissionTimer->setSingleShot(true);
    m_sendTimer->setSingleShot(true);
}

void FinanceBackend::requestCommission(int serviceId, int amountMinorUnits)
{
    // Cancel any previous pending commission request
    m_commissionTimer->stop();
    m_commissionTimer->disconnect();

    if (amountMinorUnits <= 0) {
        emit commissionReceived(0);
        return;
    }

    // Simulate server delay (~300ms) and calculate commission (2.5%)
    const int commission = static_cast<int>(amountMinorUnits * 0.025);

    qDebug() << "FinanceBackend: requesting commission for service" << serviceId
             << "amount:" << amountMinorUnits << "-> estimated commission:" << commission;

    connect(m_commissionTimer, &QTimer::timeout, this, [this, commission]() {
        qDebug() << "FinanceBackend: commission received:" << commission;
        emit commissionReceived(commission);
    });

    m_commissionTimer->start(300);
}

void FinanceBackend::sendTransaction(const QString &sessionId, int serviceId,
                                     const QVariantMap &params, int amount,
                                     int commission)
{
    m_sendTimer->stop();
    m_sendTimer->disconnect();

    qDebug() << "FinanceBackend: sending transaction" << sessionId
             << "service:" << serviceId
             << "amount:" << amount
             << "commission:" << commission
             << "params:" << params;

    // Generate a mock transaction ID
    const QString txId = QStringLiteral("TX-")
                         + QUuid::createUuid().toString(QUuid::WithoutBraces).left(8).toUpper();

    // Simulate server processing delay (~800ms), always succeeds for now
    connect(m_sendTimer, &QTimer::timeout, this, [this, txId]() {
        qDebug() << "FinanceBackend: transaction completed, txId:" << txId;
        emit transactionResult(true, txId, QString());
    });

    m_sendTimer->start(800);
}

void FinanceBackend::cancelPending()
{
    m_commissionTimer->stop();
    m_commissionTimer->disconnect();
    m_sendTimer->stop();
    m_sendTimer->disconnect();
}

} // namespace finance
