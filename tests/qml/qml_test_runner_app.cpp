#include <QtQuickTest>
#include <QQmlEngine>

class QmlAppTests : public QObject
{
    Q_OBJECT
public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        engine->addImportPath(QML_MODULE_DIR);
    }
};

QUICK_TEST_MAIN_WITH_SETUP(qml_tst_app, QmlAppTests)
#include "qml_test_runner_app.moc"
