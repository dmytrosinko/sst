#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

namespace test {

class ServiceModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int currentScreen READ currentScreen NOTIFY currentScreenChanged)

public:
    enum Screen {
        Screen1 = 0,
        Screen2,
        Screen3
    };
    Q_ENUM(Screen)

    explicit ServiceModel(QObject *parent = nullptr);

    int currentScreen() const;

    Q_INVOKABLE void goToScreen(int screenIndex);
    Q_INVOKABLE void goToNextScreen();
    Q_INVOKABLE void goToPreviouseScreen();

signals:
    void currentScreenChanged();

private:
    int m_currentScreen = 0;
};

} // namespace test
