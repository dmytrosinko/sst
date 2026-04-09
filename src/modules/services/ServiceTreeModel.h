#pragma once

#include <QAbstractItemModel>
#include <QHash>
#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "ServiceTreeItem.h"

namespace services {

class ServiceTreeModel : public QAbstractItemModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(int translationRevision READ translationRevision NOTIFY translationRevisionChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IdRole,
        NodeTypeRole,
        InputTypeRole,
        SizeRole,
        FieldsRole
    };
    Q_ENUM(Roles)

    enum InputTypeEnum {
        Phone = static_cast<int>(InputType::Phone),
        IBAN = static_cast<int>(InputType::IBAN),
        Account = static_cast<int>(InputType::Account),
        Default = static_cast<int>(InputType::Default)
    };
    Q_ENUM(InputTypeEnum)

    explicit ServiceTreeModel(QObject *parent = nullptr);
    ~ServiceTreeModel() override;

    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex &parent = {}) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // API to populate the model
    Q_INVOKABLE void addCategory(int categoryId, const QString &name);
    Q_INVOKABLE void addService(int categoryId, int serviceId,
                                const QString &inputType, const QString &name,
                                const QString &size = QStringLiteral("1x1"),
                                const QJsonArray &fields = {});

    Q_INVOKABLE void clear();
    Q_INVOKABLE bool loadFromJsonResource(const QString &resourcePath);
    Q_INVOKABLE void loadFromJsonResourceAsync(const QString &resourcePath);
    Q_INVOKABLE QString translatedCategoryName(int row) const;

    int translationRevision() const { return m_translationRevision; }

public slots:
    void retranslate();

signals:
    void translationRevisionChanged();
    void loadingFinished(bool success);   ///< emitted on main thread after async load

private:
    ServiceTreeItem *itemFromIndex(const QModelIndex &index) const;
    ServiceTreeItem *findCategory(int categoryId) const;
    InputType inputTypeFromString(const QString &str) const;

    // Emit dataChanged for every item in the tree (NameRole)
    void emitAllNamesChanged(const QModelIndex &parent = {});

    ServiceTreeItem *m_rootItem = nullptr;
    QHash<int, ServiceTreeItem*> m_categoryMap;
    int m_translationRevision = 0;
};

} // namespace services
