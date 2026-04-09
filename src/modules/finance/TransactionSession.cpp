#include "TransactionSession.h"

#include <QUuid>

namespace finance {

TransactionSession::TransactionSession(int serviceId, const QString &serviceName)
    : sessionId(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , serviceId(serviceId)
    , serviceName(serviceName)
    , status(TransactionStatus::Created)
    , createdAt(QDateTime::currentDateTime())
{
}

void TransactionSession::reset()
{
    sessionId.clear();
    serviceId   = 0;
    serviceName.clear();
    status      = TransactionStatus::None;
    serviceParams.clear();
    amount      = 0;
    commission  = 0;
    receiptData.clear();
    errorMessage.clear();
    createdAt   = QDateTime();
}

} // namespace finance
