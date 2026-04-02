#pragma once

#include <QObject>
#include <QTranslator>
#include <QGuiApplication>
#include <QtQml/qqmlregistration.h>

class TranslationManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool isEnglish READ isEnglish NOTIFY languageChanged)

public:
    explicit TranslationManager(QObject *parent = nullptr);

    bool isEnglish() const;

    Q_INVOKABLE void toggleLanguage();

signals:
    void languageChanged();

private:
    QTranslator m_translator;
    bool m_isEn = true;
};
