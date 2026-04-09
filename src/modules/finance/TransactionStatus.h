#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

namespace finance {

Q_NAMESPACE
QML_ELEMENT

enum class TransactionStatus {
    None    = -1, ///< No active session
    Created =  0, ///< Session just created
    Ready   =  1, ///< All params filled + amount > 0
    Sent    =  2, ///< Sent to financial host
    Success =  3, ///< Host confirmed
    Error   =  4  ///< Host error or local error
};
Q_ENUM_NS(TransactionStatus)

} // namespace finance
