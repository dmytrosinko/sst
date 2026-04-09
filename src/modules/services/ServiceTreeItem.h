#pragma once

#include <QJsonArray>
#include <QList>
#include <QString>
#include <QByteArray>
#include <QVariant>

namespace services {

enum class InputType {
    Phone = 0,
    IBAN,
    Account,
    Default
};

class ServiceTreeItem
{
public:
    enum class NodeType {
        Category,
        Service
    };

    // Construct a category node
    explicit ServiceTreeItem(int categoryId, const QString &categoryName,
                             ServiceTreeItem *parent = nullptr);

    // Construct a service node
    explicit ServiceTreeItem(int serviceId, InputType inputType,
                             const QString &name, const QString &size,
                             const QJsonArray &fields = {},
                             ServiceTreeItem *parent = nullptr);

    ~ServiceTreeItem();

    void appendChild(ServiceTreeItem *child);

    ServiceTreeItem *child(int row) const;
    int childCount() const;
    int columnCount() const;

    int row() const;
    ServiceTreeItem *parentItem() const;

    NodeType nodeType() const;
    int id() const;
    QString name() const;
    const QByteArray &nameUtf8() const;
    InputType inputType() const;
    QString size() const;
    QJsonArray fields() const;

private:
    Q_DISABLE_COPY_MOVE(ServiceTreeItem)

    QList<ServiceTreeItem *> m_children;
    ServiceTreeItem *m_parent = nullptr;
    NodeType m_nodeType;

    int m_id = 0;
    int m_row = 0;
    QString m_name;
    QByteArray m_nameUtf8;
    InputType m_inputType = InputType::Default;
    QString m_size = QStringLiteral("1x1");
    QJsonArray m_fields;
};

} // namespace services
