#include "ServiceTreeItem.h"

namespace services {

// Category constructor
ServiceTreeItem::ServiceTreeItem(int categoryId, const QString &categoryName,
                                 ServiceTreeItem *parent)
    : m_parent(parent)
    , m_nodeType(NodeType::Category)
    , m_id(categoryId)
    , m_name(categoryName)
{
}

// Service constructor
ServiceTreeItem::ServiceTreeItem(int serviceId, InputType inputType,
                                 const QString &name,
                                 ServiceTreeItem *parent)
    : m_parent(parent)
    , m_nodeType(NodeType::Service)
    , m_id(serviceId)
    , m_name(name)
    , m_inputType(inputType)
{
}

ServiceTreeItem::~ServiceTreeItem()
{
    qDeleteAll(m_children);
}

void ServiceTreeItem::appendChild(ServiceTreeItem *child)
{
    child->m_row = m_children.size();
    m_children.append(child);
}

ServiceTreeItem *ServiceTreeItem::child(int row) const
{
    if (row < 0 || row >= m_children.size())
        return nullptr;
    return m_children.at(row);
}

int ServiceTreeItem::childCount() const
{
    return m_children.size();
}

int ServiceTreeItem::columnCount() const
{
    return 1; // single-column tree
}

int ServiceTreeItem::row() const
{
    return m_row;
}

ServiceTreeItem *ServiceTreeItem::parentItem() const
{
    return m_parent;
}

ServiceTreeItem::NodeType ServiceTreeItem::nodeType() const
{
    return m_nodeType;
}

int ServiceTreeItem::id() const
{
    return m_id;
}

QString ServiceTreeItem::name() const
{
    return m_name;
}

InputType ServiceTreeItem::inputType() const
{
    return m_inputType;
}

} // namespace services
