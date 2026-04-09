#include "PortScanner.h"
#include "ValidatorDriver.h"

#include <QDebug>
#include <QSerialPortInfo>
#include <QtConcurrent/QtConcurrent>

using namespace hardware;

PortScanner::PortScanner(QObject *parent)
    : QObject(parent)
{
}

PortScanner::~PortScanner()
{
    m_scanFuture.waitForFinished();
}

void PortScanner::startScan()
{
    if (m_scanning) {
        qDebug() << "[PortScanner] Scan already in progress";
        return;
    }

    m_scanning = true;

    // Run scan on a background thread via QtConcurrent.
    // Serial I/O with blocking waits must not run on the main thread.
    m_scanFuture = QtConcurrent::run([this]() {
        doScan();
    });
}

bool PortScanner::isScanning() const
{
    return m_scanning;
}

void PortScanner::doScan()
{
    const QList<QSerialPortInfo> ports = QSerialPortInfo::availablePorts();

    qDebug() << "[PortScanner] Scanning" << ports.size() << "serial ports...";

    for (const QSerialPortInfo &info : ports) {
        qDebug() << "[PortScanner] Probing" << info.portName()
                 << "(" << info.description() << ")";

        // Skip obviously wrong ports (Bluetooth virtual ports, etc.)
        if (info.description().contains(QStringLiteral("Bluetooth"), Qt::CaseInsensitive))
            continue;

        // Create a temporary driver on this thread to probe the port.
        // ValidatorDriver::probeDevice() uses synchronous waitForReadyRead.
        ValidatorDriver probe;
        probe.setPortName(info.portName());

        if (probe.probeDevice()) {
            qDebug() << "[PortScanner] Validator FOUND on" << info.portName();

            // Deliver result on the main thread
            QMetaObject::invokeMethod(this, [this, portName = info.portName()]() {
                emit validatorFound(portName);
                emit scanFinished(true, portName);
                m_scanning = false;
            }, Qt::QueuedConnection);

            return;
        }

        qDebug() << "[PortScanner]   No EBDS response on" << info.portName();
    }

    // No validator found on any port
    QMetaObject::invokeMethod(this, [this]() {
        qDebug() << "[PortScanner] Scan complete - no validator found";
        emit scanFinished(false, QString());
        m_scanning = false;
    }, Qt::QueuedConnection);
}
