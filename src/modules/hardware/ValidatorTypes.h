#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

namespace hardware {

Q_NAMESPACE

/// Validator device states matching the EBDS protocol state machine.
/// Reference: EBDS G7 Spec — Section 5.2 (Transaction Flow), Appendix F.
enum class ValidatorState {
    Disconnected,     ///< No communication with device
    PowerUp,          ///< Device is initializing after power-on
    Idling,           ///< Waiting for a document
    Accepting,        ///< Transporting a document inward
    Escrowed,         ///< Document validated, waiting host decision (stack / return)
    Stacking,         ///< Stacker motor is moving the document to cashbox
    Stacked,          ///< Document stored — host should issue credit
    Returning,        ///< Returning document to customer
    Returned,         ///< Document returned successfully
    Rejected,         ///< Document not recognized or transport failure
    Jammed,           ///< Transport jam — device out of service
    StackerFull,      ///< Cashbox is full — cannot accept more
    CashboxRemoved,   ///< Cashbox not detected
    Failure,          ///< Device failure — out of service
    Disabled,         ///< Acceptance disabled by host
    Calibrating,      ///< Calibration in progress
    Cheated           ///< Cheat attempt detected
};
Q_ENUM_NS(ValidatorState)

/// Error conditions reported by the validator.
enum class ValidatorError {
    None,
    CommunicationLost,    ///< No response after maximum retries
    Jam,                  ///< Document transport jam
    CashboxFull,          ///< Stacker is full
    CashboxRemoved,       ///< Cashbox not detected
    Failure,              ///< General device failure
    Cheated,              ///< Cheat attempt detected
    InvalidCommand,       ///< Device reported invalid command from host
    PowerUp               ///< Device performed a power-on reset
};
Q_ENUM_NS(ValidatorError)

} // namespace hardware
