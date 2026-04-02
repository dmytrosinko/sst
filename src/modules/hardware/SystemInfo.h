#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QTimer>
#include <QString>

namespace hardware {

class SystemInfo : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString cpuUsage READ cpuUsage NOTIFY statsChanged)
    Q_PROPERTY(QString totalRam READ totalRam NOTIFY statsChanged)
    Q_PROPERTY(QString availableRam READ availableRam NOTIFY statsChanged)
    Q_PROPERTY(QString fps READ fps NOTIFY statsChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    QString cpuUsage() const;
    QString totalRam() const;
    QString availableRam() const;
    QString fps() const;

    Q_INVOKABLE void registerFrame();

signals:
    void statsChanged();

private slots:
    void updateStats();

private:
    QString m_cpuUsage;
    QString m_totalRam;
    QString m_availableRam;
    QString m_fps;
    QTimer m_timer;
    bool m_isUpdating = false;

    int m_frameCount = 0;
    qint64 m_lastFpsTime = 0;

#ifdef Q_OS_WIN
    unsigned long long m_lastIdleTime = 0;
    unsigned long long m_lastKernelTime = 0;
    unsigned long long m_lastUserTime = 0;
#elif defined(Q_OS_LINUX)
    unsigned long long m_lastTotalUser = 0;
    unsigned long long m_lastTotalUserLow = 0;
    unsigned long long m_lastTotalSys = 0;
    unsigned long long m_lastTotalIdle = 0;
#endif
};

} // namespace hardware
