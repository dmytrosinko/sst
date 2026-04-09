#include "TransactionController.h"
#include "FinanceBackend.h"

#include <QDateTime>
#include <QDebug>

namespace finance {

TransactionController::TransactionController(QObject *parent)
    : QObject(parent)
    , m_backend(new FinanceBackend(this))
{
    connect(m_backend, &FinanceBackend::commissionReceived,
            this, &TransactionController::onCommissionReceived);
    connect(m_backend, &FinanceBackend::transactionResult,
            this, &TransactionController::onTransactionResult);
}

TransactionController::~TransactionController() = default;

// ── Q_PROPERTY getters ──────────────────────────────────────────────────────

bool TransactionController::hasActiveSession() const
{
    return m_session.isValid();
}

int TransactionController::statusInt() const
{
    return static_cast<int>(m_session.status);
}

QString TransactionController::statusName() const
{
    switch (m_session.status) {
    case TransactionStatus::None:    return QStringLiteral("None");
    case TransactionStatus::Created: return QStringLiteral("Created");
    case TransactionStatus::Ready:   return QStringLiteral("Ready");
    case TransactionStatus::Sent:    return QStringLiteral("Sent");
    case TransactionStatus::Success: return QStringLiteral("Success");
    case TransactionStatus::Error:   return QStringLiteral("Error");
    }
    return QStringLiteral("Unknown");
}

int TransactionController::serviceId() const
{
    return m_session.serviceId;
}

QString TransactionController::serviceName() const
{
    return m_session.serviceName;
}

int TransactionController::amount() const
{
    return m_session.amount;
}

QString TransactionController::formattedAmount() const
{
    return formatAmount(m_session.amount);
}

int TransactionController::commission() const
{
    return m_session.commission;
}

QString TransactionController::formattedCommission() const
{
    return formatAmount(m_session.commission);
}

QString TransactionController::currency() const
{
    return m_currency;
}

void TransactionController::setCurrency(const QString &currency)
{
    if (m_currency != currency) {
        m_currency = currency;
        emit currencyChanged();
        // Re-emit formatted amounts since currency suffix changed
        emit amountChanged();
        emit commissionChanged();
    }
}

QString TransactionController::errorMessage() const
{
    return m_session.errorMessage;
}

bool TransactionController::isCommissionLoading() const
{
    return m_commissionLoading;
}

// ── Q_INVOKABLE ─────────────────────────────────────────────────────────────

void TransactionController::startSession(int serviceId, const QString &serviceName)
{
    // Cancel any previous session
    if (m_session.isValid()) {
        m_backend->cancelPending();
    }

    m_session = TransactionSession(serviceId, serviceName);

    qDebug() << "TransactionController: started session" << m_session.sessionId
             << "for service" << serviceId << serviceName;

    emit sessionChanged();
    emit statusChanged();
    emit amountChanged();
    emit commissionChanged();
}

void TransactionController::setParam(const QString &key, const QString &value)
{
    if (!m_session.isValid()) {
        qWarning() << "TransactionController::setParam: no active session";
        return;
    }

    m_session.serviceParams[key] = value;
    qDebug() << "TransactionController: setParam" << key << "=" << value;
    emit paramsChanged();
}

QString TransactionController::param(const QString &key) const
{
    return m_session.serviceParams.value(key).toString();
}

void TransactionController::setAmount(int amountMinorUnits)
{
    if (!m_session.isValid()) {
        qWarning() << "TransactionController::setAmount: no active session";
        return;
    }

    if (m_session.amount == amountMinorUnits)
        return;

    m_session.amount = amountMinorUnits;
    emit amountChanged();

    // Trigger async commission fetch from backend
    m_commissionLoading = true;
    emit commissionLoadingChanged();
    m_backend->requestCommission(m_session.serviceId, amountMinorUnits);
}

bool TransactionController::markReady()
{
    if (!m_session.isValid()) {
        qWarning() << "TransactionController::markReady: no active session";
        return false;
    }

    if (m_session.amount <= 0) {
        qWarning() << "TransactionController::markReady: amount must be > 0";
        return false;
    }

    setStatus(TransactionStatus::Ready);
    qDebug() << "TransactionController: session marked as Ready";
    return true;
}

void TransactionController::send()
{
    if (!m_session.isValid()) {
        qWarning() << "TransactionController::send: no active session";
        return;
    }

    // Auto-mark as ready if conditions are met
    if (m_session.status == TransactionStatus::Created) {
        if (!markReady())
            return;
    }

    if (m_session.status != TransactionStatus::Ready) {
        qWarning() << "TransactionController::send: session not in Ready state, current:"
                    << statusName();
        return;
    }

    setStatus(TransactionStatus::Sent);

    qDebug() << "TransactionController: sending transaction" << m_session.sessionId;

    m_backend->sendTransaction(m_session.sessionId,
                               m_session.serviceId,
                               m_session.serviceParams,
                               m_session.amount,
                               m_session.commission);
}

void TransactionController::cancelSession()
{
    if (!m_session.isValid()) {
        return;
    }

    qDebug() << "TransactionController: cancelling session" << m_session.sessionId;

    m_backend->cancelPending();
    m_session.reset();

    m_commissionLoading = false;
    emit commissionLoadingChanged();
    emit sessionChanged();
    emit statusChanged();
    emit amountChanged();
    emit commissionChanged();
}

QVariantMap TransactionController::receiptData() const
{
    return m_session.receiptData;
}

// ── Private slots ───────────────────────────────────────────────────────────

void TransactionController::onCommissionReceived(int commissionMinorUnits)
{
    if (!m_session.isValid())
        return;

    m_session.commission = commissionMinorUnits;
    m_commissionLoading = false;

    qDebug() << "TransactionController: commission updated to" << commissionMinorUnits;

    emit commissionChanged();
    emit commissionLoadingChanged();
}

void TransactionController::onTransactionResult(bool success, const QString &transactionId,
                                                 const QString &errorMessage)
{
    if (!m_session.isValid())
        return;

    if (success) {
        m_session.receiptData = {
            {QStringLiteral("transactionId"), transactionId},
            {QStringLiteral("serviceId"),     m_session.serviceId},
            {QStringLiteral("serviceName"),   m_session.serviceName},
            {QStringLiteral("amount"),        m_session.amount},
            {QStringLiteral("commission"),    m_session.commission},
            {QStringLiteral("currency"),      m_currency},
            {QStringLiteral("date"),          QDateTime::currentDateTime().toString(QStringLiteral("dd.MM.yyyy  HH:mm"))},
            {QStringLiteral("params"),        m_session.serviceParams}
        };
        setStatus(TransactionStatus::Success);
        qDebug() << "TransactionController: transaction SUCCESS, txId:" << transactionId;
    } else {
        m_session.errorMessage = errorMessage;
        setStatus(TransactionStatus::Error);
        qDebug() << "TransactionController: transaction ERROR:" << errorMessage;
    }

    emit sessionCompleted(success);
}

// ── Private helpers ─────────────────────────────────────────────────────────

QString TransactionController::formatAmount(int minorUnits) const
{
    // Convert minor units to major.minor string with thousands separator.
    // e.g. 150000 → "1 500.00 KGS"
    const int    major   = minorUnits / 100;
    const int    minor   = minorUnits % 100;
    const QString base   = QString::number(major);

    // Insert thousands separator (space)
    QString formatted;
    formatted.reserve(base.size() + base.size() / 3);
    int count = 0;
    for (int i = base.size() - 1; i >= 0; --i) {
        if (count > 0 && count % 3 == 0)
            formatted.prepend(QLatin1Char(' '));
        formatted.prepend(base[i]);
        ++count;
    }

    return QStringLiteral("%1.%2 %3")
        .arg(formatted)
        .arg(minor, 2, 10, QLatin1Char('0'))
        .arg(m_currency);
}

void TransactionController::setStatus(TransactionStatus newStatus)
{
    if (m_session.status != newStatus) {
        m_session.status = newStatus;
        emit statusChanged();
    }
}

} // namespace finance
