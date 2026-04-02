#include <QtTest>
#include <QCoreApplication>
#include "../../src/TranslationManager.h"

class Tst_TranslationManager : public QObject
{
    Q_OBJECT

private slots:
    void testBasicInstance() {
        TranslationManager tm;
        
        // Assert initial language defaults correctly
        QCOMPARE(tm.isEnglish(), true);

        // Toggle language
        tm.toggleLanguage();
        QCOMPARE(tm.isEnglish(), false);
    }
};

QTEST_GUILESS_MAIN(Tst_TranslationManager)
#include "tst_TranslationManager.moc"
