#include <QtQuickTest>
#include <QQmlEngine>

class Setup : public QObject {
    Q_OBJECT
public:
    Setup() {}
public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        engine->addImportPath(QML_MODULE_DIR);
    }
};

QUICK_TEST_MAIN_WITH_SETUP(QmlControlsTests, Setup)
#include "qml_test_runner_controls.moc"
