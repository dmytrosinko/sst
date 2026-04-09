#pragma once

#include "TransactionStatus.h"

#include <QDateTime>
#include <QString>
#include <QVariantMap>

namespace finance {

/// Data entity holding the full state of a single financial transaction.
/// Not exposed directly to QML — owned and managed by TransactionController.
class TransactionSession
{
public:
    TransactionSession() = default;

    /// Construct a new session for the given service.
    explicit TransactionSession(int serviceId, const QString &serviceName);

    // ── Identification ──────────────────────────────────────────────
    QString sessionId;
    int     serviceId   = 0;
    QString serviceName;

    // ── Status ──────────────────────────────────────────────────────
    TransactionStatus status = TransactionStatus::None;

    // ── Service-specific input params ───────────────────────────────
    QVariantMap serviceParams;

    // ── Amounts (minor units, e.g. tiyin) ───────────────────────────
    int amount     = 0;
    int commission = 0;

    // ── Receipt data (populated on Success) ─────────────────────────
    QVariantMap receiptData;

    // ── Error info ──────────────────────────────────────────────────
    QString errorMessage;

    // ── Timestamps ──────────────────────────────────────────────────
    QDateTime createdAt;

    // ── Helpers ─────────────────────────────────────────────────────
    bool isValid() const { return !sessionId.isEmpty(); }
    void reset();
};

} // namespace finance
