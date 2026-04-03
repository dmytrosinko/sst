#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

namespace test {

class ServiceModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int serviceId READ serviceId NOTIFY serviceChanged)
    Q_PROPERTY(QString serviceName READ serviceName NOTIFY serviceChanged)
    Q_PROPERTY(int inputType READ inputType NOTIFY serviceChanged)

public:
    explicit ServiceModel(QObject *parent = nullptr);

    int serviceId() const;
    QString serviceName() const;
    int inputType() const;

    Q_INVOKABLE void startService(int id, const QString &name, int type);
    Q_INVOKABLE void clearService();

signals:
    void serviceChanged();

private:
    int m_serviceId = 0;
    QString m_serviceName;
    int m_inputType = 3; // services::InputType::Default
};

} // namespace test
