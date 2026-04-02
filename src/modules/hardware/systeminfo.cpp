#include "SystemInfo.h"
#include <QDateTime>
#include <QtConcurrent/QtConcurrent>

#ifdef Q_OS_WIN
#include <windows.h>
#elif defined(Q_OS_LINUX)
#include <QFile>
#include <QRegularExpression>
#include <QTextStream>
#include <sys/sysinfo.h>
#endif

using namespace hardware;

QString formatSize(quint64 bytes) {
  if (bytes < 1024)
    return QString::number(bytes) + " B";
  if (bytes < 1024 * 1024)
    return QString::number(bytes / 1024.0, 'f', 1) + " KB";
  if (bytes < 1024 * 1024 * 1024)
    return QString::number(bytes / (1024.0 * 1024.0), 'f', 1) + " MB";
  return QString::number(bytes / (1024.0 * 1024.0 * 1024.0), 'f', 2) + " GB";
}

SystemInfo::SystemInfo(QObject *parent)
    : QObject(parent), m_cpuUsage("0.0%"), m_totalRam("0 GB"),
      m_availableRam("0 GB"), m_fps("0") {
  m_lastFpsTime = QDateTime::currentMSecsSinceEpoch();

  // Initialize first reading
  updateStats();

  connect(&m_timer, &QTimer::timeout, this, &SystemInfo::updateStats);
  m_timer.start(2000); // Update every 2 seconds
}

QString SystemInfo::cpuUsage() const { return m_cpuUsage; }
QString SystemInfo::totalRam() const { return m_totalRam; }
QString SystemInfo::availableRam() const { return m_availableRam; }
QString SystemInfo::fps() const { return m_fps; }

void SystemInfo::registerFrame() {
  m_frameCount++;
  qint64 current = QDateTime::currentMSecsSinceEpoch();
  if (current - m_lastFpsTime >= 1000) {
    m_fps = QString::number(m_frameCount);
    emit statsChanged();
    m_frameCount = 0;
    m_lastFpsTime = current;
  }
}

void SystemInfo::updateStats() {
  if (m_isUpdating)
    return;
  m_isUpdating = true;

  // Snapshot variables for the concurrent lambda
  QString baseCpuUsage = m_cpuUsage;
  QString baseTotalRam = m_totalRam;
  QString baseAvailableRam = m_availableRam;

#ifdef Q_OS_WIN
  auto prevIdle = m_lastIdleTime;
  auto prevKernel = m_lastKernelTime;
  auto prevUser = m_lastUserTime;
#elif defined(Q_OS_LINUX)
  auto prevTotalUser = m_lastTotalUser;
  auto prevTotalUserLow = m_lastTotalUserLow;
  auto prevTotalSys = m_lastTotalSys;
  auto prevTotalIdle = m_lastTotalIdle;
#endif

  QtConcurrent::run([=]() mutable {
#ifdef Q_OS_WIN
    // RAM
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&memInfo)) {
      baseTotalRam = formatSize(memInfo.ullTotalPhys);
      baseAvailableRam = formatSize(memInfo.ullAvailPhys);
    }

    // CPU
    FILETIME idleTime, kernelTime, userTime;
    if (GetSystemTimes(&idleTime, &kernelTime, &userTime)) {
      unsigned long long idle =
          (reinterpret_cast<ULARGE_INTEGER *>(&idleTime))->QuadPart;
      unsigned long long kernel =
          (reinterpret_cast<ULARGE_INTEGER *>(&kernelTime))->QuadPart;
      unsigned long long user =
          (reinterpret_cast<ULARGE_INTEGER *>(&userTime))->QuadPart;

      if (prevIdle != 0) {
        unsigned long long idleDiff = idle - prevIdle;
        unsigned long long kernelDiff = kernel - prevKernel;
        unsigned long long userDiff = user - prevUser;
        unsigned long long sysDiff = kernelDiff + userDiff;

        if (sysDiff > 0) {
          double usage = (sysDiff - idleDiff) * 100.0 / sysDiff;
          if (usage < 0.0)
            usage = 0.0;
          baseCpuUsage = QString::number(usage, 'f', 1) + "%";
        }
      }

      prevIdle = idle;
      prevKernel = kernel;
      prevUser = user;
    }

    QMetaObject::invokeMethod(this, [this, baseCpuUsage, baseTotalRam,
                                     baseAvailableRam, prevIdle, prevKernel,
                                     prevUser]() {
      m_cpuUsage = baseCpuUsage;
      m_totalRam = baseTotalRam;
      m_availableRam = baseAvailableRam;
      m_lastIdleTime = prevIdle;
      m_lastKernelTime = prevKernel;
      m_lastUserTime = prevUser;
      m_isUpdating = false;
      emit statsChanged();
    });

#elif defined(Q_OS_LINUX)
    // RAM
    struct sysinfo memInfo;
    if (sysinfo(&memInfo) == 0) {
      quint64 totalPhysMem = memInfo.totalram;
      totalPhysMem *= memInfo.mem_unit;
      baseTotalRam = formatSize(totalPhysMem);

      QFile memFile("/proc/meminfo");
      if (memFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&memFile);
        QString line;
        quint64 memAvail = 0;
        bool foundAvail = false;
        while (in.readLineInto(&line)) {
          if (line.startsWith("MemAvailable:")) {
            QStringList parts =
                line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
            if (parts.size() >= 2) {
              memAvail = parts[1].toULongLong() * 1024;
              foundAvail = true;
            }
            break;
          }
        }
        if (foundAvail) {
          baseAvailableRam = formatSize(memAvail);
        } else {
          quint64 freePhysMem = memInfo.freeram;
          freePhysMem *= memInfo.mem_unit;
          baseAvailableRam = formatSize(freePhysMem);
        }
      } else {
        quint64 freePhysMem = memInfo.freeram;
        freePhysMem *= memInfo.mem_unit;
        baseAvailableRam = formatSize(freePhysMem);
      }
    }

    // CPU using /proc/stat
    QFile file("/proc/stat");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
      QTextStream in(&file);
      QString line = in.readLine();
      QStringList parts =
          line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

      if (parts.size() > 4 && parts[0] == "cpu") {
        unsigned long long user = parts[1].toULongLong();
        unsigned long long nice = parts[2].toULongLong();
        unsigned long long sys = parts[3].toULongLong();
        unsigned long long idle = parts[4].toULongLong();

        if (prevTotalUser != 0) {
          unsigned long long total =
              (user + nice + sys + idle) -
              (prevTotalUser + prevTotalUserLow + prevTotalSys + prevTotalIdle);
          unsigned long long idleDiff = idle - prevTotalIdle;

          if (total > 0) {
            double usage = (total - idleDiff) * 100.0 / total;
            if (usage < 0.0)
              usage = 0.0;
            baseCpuUsage = QString::number(usage, 'f', 1) + "%";
          }
        }

        prevTotalUser = user;
        prevTotalUserLow = nice;
        prevTotalSys = sys;
        prevTotalIdle = idle;
      }
    }

    QMetaObject::invokeMethod(
        this, [this, baseCpuUsage, baseTotalRam, baseAvailableRam,
               prevTotalUser, prevTotalUserLow, prevTotalSys, prevTotalIdle]() {
          m_cpuUsage = baseCpuUsage;
          m_totalRam = baseTotalRam;
          m_availableRam = baseAvailableRam;
          m_lastTotalUser = prevTotalUser;
          m_lastTotalUserLow = prevTotalUserLow;
          m_lastTotalSys = prevTotalSys;
          m_lastTotalIdle = prevTotalIdle;
          m_isUpdating = false;
          emit statsChanged();
        });
#endif
  });
}
