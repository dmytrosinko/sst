#include "ServiceModel.h"

using namespace test;

namespace test {

ServiceModel::ServiceModel(QObject *parent)
    : QObject(parent), m_currentScreen(0)
{
}

int ServiceModel::currentScreen() const
{
    return m_currentScreen;
}

void ServiceModel::goToScreen(int screenIndex)
{
    if (m_currentScreen != screenIndex) {
        m_currentScreen = screenIndex;
        emit currentScreenChanged();
    }
}

void ServiceModel::goToNextScreen()
{
    goToScreen(m_currentScreen + 1);
}

void ServiceModel::goToPreviouseScreen() // Note typo matches user request exactly
{
    if (m_currentScreen > 0) {
        goToScreen(m_currentScreen - 1);
    }
}

} // namespace test
