#pragma once

#include <QObject>
#include <QTranslator>

#include <QtQml/qqmlregistration.h>

class TranslationManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
    // Keep backward compat for any code checking isEnglish
    Q_PROPERTY(bool isEnglish READ isEnglish NOTIFY languageChanged)

public:
    explicit TranslationManager(QObject *parent = nullptr);

    QString currentLanguage() const;
    bool isEnglish() const;

    Q_INVOKABLE void setLanguage(const QString &langCode);
    // Legacy toggle: cycles EN → KY → RU → EN
    Q_INVOKABLE void toggleLanguage();

signals:
    void languageChanged();

private:
    void applyLanguage(const QString &langCode);

    QTranslator m_translator;
    QString m_currentLang = QStringLiteral("en");
};
