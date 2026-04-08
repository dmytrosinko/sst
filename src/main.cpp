#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QFontDatabase>

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);

  int fontId = QFontDatabase::addApplicationFont(":/qt/qml/app/assets/fonts/EuclidCircularB-Regular.ttf");
  if (fontId != -1) {
      QStringList families = QFontDatabase::applicationFontFamilies(fontId);
      if (!families.isEmpty()) {
          QGuiApplication::setFont(QFont(families.at(0)));
      }
  }

  QQmlApplicationEngine engine;
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("app", "Main");
  return app.exec();
}
