#include "TranslationManager.h"
#include <QCoreApplication>
#include <QDebug>
#include <QQmlEngine>
#include <QtQml>

TranslationManager::TranslationManager(QObject *parent)
    : QObject(parent), m_currentLang(QStringLiteral("en"))
{
}

QString TranslationManager::currentLanguage() const
{
    return m_currentLang;
}

bool TranslationManager::isEnglish() const
{
    return m_currentLang == QLatin1String("en");
}

void TranslationManager::setLanguage(const QString &langCode)
{
    if (m_currentLang == langCode)
        return;

    applyLanguage(langCode);
}

void TranslationManager::toggleLanguage()
{
    // Cycle: en → ky → ru → en
    if (m_currentLang == QLatin1String("en"))
        applyLanguage(QStringLiteral("ky"));
    else if (m_currentLang == QLatin1String("ky"))
        applyLanguage(QStringLiteral("ru"));
    else
        applyLanguage(QStringLiteral("en"));
}

void TranslationManager::applyLanguage(const QString &langCode)
{
    // Remove any existing translator first
    QCoreApplication::removeTranslator(&m_translator);

    if (langCode != QLatin1String("en")) {
        const QString fileName = QStringLiteral("sst_") + langCode;
        bool loaded = false;

        if (m_translator.load(QStringLiteral(":/i18n/") + fileName + QStringLiteral(".qm"))) {
            loaded = true;
        } else if (m_translator.load(fileName + QStringLiteral(".qm"), QStringLiteral(":/i18n/"))) {
            loaded = true;
        } else if (m_translator.load(QStringLiteral("translations/") + fileName + QStringLiteral(".qm"))) {
            loaded = true;
        }

        if (loaded) {
            qDebug() << "Loaded translator for" << langCode;
            QCoreApplication::installTranslator(&m_translator);
        } else {
            qWarning() << "Failed to load translation for" << langCode;
        }
    } else {
        qDebug() << "Reverted to English (source).";
    }

    m_currentLang = langCode;
    emit languageChanged();

    QQmlEngine *engine = qmlEngine(this);
    if (engine) {
        engine->retranslate();
    }
}
