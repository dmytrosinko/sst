#include "ServiceModel.h"
#include "../../modules/services/ServiceTreeItem.h"

namespace test {

// Use the enum from ServiceTreeItem to avoid magic numbers
static constexpr int kDefaultInputType = static_cast<int>(services::InputType::Default);

ServiceModel::ServiceModel(QObject *parent)
    : QObject(parent)
{
}

int ServiceModel::serviceId() const
{
    return m_serviceId;
}

QString ServiceModel::serviceName() const
{
    return m_serviceName;
}

int ServiceModel::inputType() const
{
    return m_inputType;
}

void ServiceModel::startService(int id, const QString &name, int type)
{
    m_serviceId = id;
    m_serviceName = name;
    m_inputType = type;
    emit serviceChanged();
}

void ServiceModel::clearService()
{
    m_serviceId = 0;
    m_serviceName.clear();
    m_inputType = kDefaultInputType;
    emit serviceChanged();
}

} // namespace test
