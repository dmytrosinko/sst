#include "TranslationManager.h"
#include <QCoreApplication>
#include <QDebug>
#include <QQmlEngine>
#include <QtQml>

TranslationManager::TranslationManager(QObject *parent)
    : QObject(parent), m_isEn(true)
{
}

bool TranslationManager::isEnglish() const
{
    return m_isEn;
}

void TranslationManager::toggleLanguage()
{
    if (m_isEn) {
        // Switch to Kyrgyz
        bool loaded = false;
        if (m_translator.load(":/i18n/sst_ky.qm")) {
            loaded = true;
        } else if (m_translator.load("translations/sst_ky.qm")) {
            loaded = true;
        } else if (m_translator.load("sst_ky.qm", ":/i18n/")) {
            loaded = true;
        }

        if (loaded) {
            qDebug() << "Successfully loaded Kyrgyz translator.";
            QCoreApplication::installTranslator(&m_translator);
        } else {
            qWarning() << "Failed to load Kyrgyz translation dictionary!";
        }
    } else {
        // Revert to English (default source)
        qDebug() << "Removing translator (reverting to English).";
        QCoreApplication::removeTranslator(&m_translator);
    }
    
    m_isEn = !m_isEn;
    emit languageChanged();

    QQmlEngine *engine = qmlEngine(this);
    if (engine) {
        engine->retranslate();
    }
}
