#pragma once

#include <QObject>
#include <QString>
#include <QFuture>
#include <atomic>

namespace hardware {

class ValidatorDriver;

/// Scans all available serial ports to auto-detect a MEI EBDS bill validator.
///
/// Runs the probe on a background thread (via QtConcurrent) so serial I/O
/// with blocking waitForReadyRead doesn't stall the GUI event loop.
///
/// For each available serial port, opens it with EBDS settings (9600/7/E/1),
/// sends a single omnibus poll, and checks for a valid EBDS reply.
///
/// Usage:
///   auto *scanner = new PortScanner(this);
///   connect(scanner, &PortScanner::validatorFound, this, &MyClass::onFound);
///   connect(scanner, &PortScanner::scanFinished, this, &MyClass::onDone);
///   scanner->startScan();
class PortScanner : public QObject
{
    Q_OBJECT

public:
    explicit PortScanner(QObject *parent = nullptr);
    ~PortScanner() override;

    /// Begin scanning all available serial ports. Non-blocking.
    void startScan();

    /// Whether a scan is currently in progress.
    bool isScanning() const;

signals:
    /// Emitted when a validator is found on a specific port.
    void validatorFound(const QString &portName);

    /// Emitted when scanning is complete, regardless of result.
    /// @param found  true if a validator was detected.
    /// @param portName  the port name (empty if not found).
    void scanFinished(bool found, const QString &portName);

private:
    void doScan();

    std::atomic<bool> m_scanning{false};
    QFuture<void> m_scanFuture;
};

} // namespace hardware
