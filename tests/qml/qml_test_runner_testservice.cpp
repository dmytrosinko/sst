#include <QtQuickTest>
#include <QQmlEngine>

class Setup : public QObject {
    Q_OBJECT
public:
    Setup() {}
public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        engine->addImportPath(QML_MODULE_DIR);
        // Add the discrete services path since URI matches 'testservice' folder
        engine->addImportPath(QString(QML_MODULE_DIR) + "/services");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(QmlTestServiceTests, Setup)
#include "qml_test_runner_testservice.moc"
