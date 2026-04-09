#include "ServiceTreeModel.h"
#include <QCoreApplication>
#include <QPointer>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QtConcurrent/QtConcurrent>

namespace services {

ServiceTreeModel::ServiceTreeModel(QObject *parent)
    : QAbstractItemModel(parent)
    , m_rootItem(new ServiceTreeItem(0, QStringLiteral("Root")))
{
}

ServiceTreeModel::~ServiceTreeModel()
{
    delete m_rootItem;
}

QModelIndex ServiceTreeModel::index(int row, int column,
                                    const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent))
        return {};

    ServiceTreeItem *parentItem = itemFromIndex(parent);
    ServiceTreeItem *childItem = parentItem->child(row);
    if (childItem)
        return createIndex(row, column, childItem);
    return {};
}

QModelIndex ServiceTreeModel::parent(const QModelIndex &child) const
{
    if (!child.isValid())
        return {};

    auto *childItem = static_cast<ServiceTreeItem *>(child.internalPointer());
    ServiceTreeItem *parentItem = childItem->parentItem();

    if (parentItem == m_rootItem || !parentItem)
        return {};

    return createIndex(parentItem->row(), 0, parentItem);
}

int ServiceTreeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.column() > 0)
        return 0;

    ServiceTreeItem *parentItem = itemFromIndex(parent);
    return parentItem->childCount();
}

int ServiceTreeModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 1;
}

QVariant ServiceTreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    auto *item = static_cast<ServiceTreeItem *>(index.internalPointer());

    switch (role) {
    case NameRole:
    case Qt::DisplayRole:
        return QCoreApplication::translate("ServiceTreeModel", item->nameUtf8().constData());
    case IdRole:
        return item->id();
    case NodeTypeRole:
        return (item->nodeType() == ServiceTreeItem::NodeType::Category)
                   ? QStringLiteral("category")
                   : QStringLiteral("service");
    case InputTypeRole:
        if (item->nodeType() == ServiceTreeItem::NodeType::Service)
            return static_cast<int>(item->inputType());
        return {};
    case SizeRole:
        if (item->nodeType() == ServiceTreeItem::NodeType::Service)
            return item->size();
        return {};
    case FieldsRole:
        if (item->nodeType() == ServiceTreeItem::NodeType::Service)
            return QVariant::fromValue(item->fields());
        return {};
    default:
        break;
    }

    return {};
}

QHash<int, QByteArray> ServiceTreeModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {IdRole, "itemId"},
        {NodeTypeRole, "nodeType"},
        {InputTypeRole, "inputType"},
        {SizeRole, "size"},
        {FieldsRole, "fields"}
    };
}

void ServiceTreeModel::addCategory(int categoryId, const QString &name)
{
    if (findCategory(categoryId))
        return; // already exists

    const int row = m_rootItem->childCount();
    beginInsertRows(QModelIndex(), row, row);
    auto *category = new ServiceTreeItem(categoryId, name, m_rootItem);
    m_rootItem->appendChild(category);
    m_categoryMap.insert(categoryId, category);
    endInsertRows();
}

void ServiceTreeModel::addService(int categoryId, int serviceId,
                                  const QString &inputType, const QString &name,
                                  const QString &size, const QJsonArray &fields)
{
    ServiceTreeItem *category = findCategory(categoryId);
    if (!category)
        return;

    QModelIndex parentIndex = createIndex(category->row(), 0, category);
    const int row = category->childCount();

    beginInsertRows(parentIndex, row, row);
    auto *service = new ServiceTreeItem(serviceId,
                                        inputTypeFromString(inputType),
                                        name, size, fields, category);
    category->appendChild(service);
    endInsertRows();
}

void ServiceTreeModel::clear()
{
    beginResetModel();
    delete m_rootItem;
    m_rootItem = new ServiceTreeItem(0, QStringLiteral("Root"));
    m_categoryMap.clear();
    endResetModel();
}

void ServiceTreeModel::retranslate()
{
    ++m_translationRevision;
    emit translationRevisionChanged();
    emitAllNamesChanged();
}

bool ServiceTreeModel::loadFromJsonResource(const QString &resourcePath)
{
    QFile file(resourcePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "ServiceTreeModel: cannot open" << resourcePath;
        return false;
    }

    QJsonParseError err;
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "ServiceTreeModel: JSON parse error:" << err.errorString();
        return false;
    }

    clear();

    const QJsonArray categories = doc.array();
    for (const QJsonValue &catVal : categories) {
        const QJsonObject cat = catVal.toObject();
        const int catId = cat[QLatin1String("id")].toInt();
        const QString catName = cat[QLatin1String("name")].toString();

        // Register translation key so lupdate finds it via QT_TRANSLATE_NOOP
        // (the actual string is stored, translated dynamically in data())
        addCategory(catId, catName);

        const QJsonArray services = cat[QLatin1String("services")].toArray();
        for (const QJsonValue &svcVal : services) {
            const QJsonObject svc = svcVal.toObject();
            addService(catId,
                       svc[QLatin1String("id")].toInt(),
                       svc[QLatin1String("inputType")].toString(),
                       svc[QLatin1String("name")].toString(),
                       svc.contains(QLatin1String("size")) ? svc[QLatin1String("size")].toString() : QStringLiteral("1x1"),
                       svc[QLatin1String("fields")].toArray());
        }
    }

    qDebug() << "ServiceTreeModel: loaded" << categories.size() << "categories from" << resourcePath;
    return true;
}

void ServiceTreeModel::loadFromJsonResourceAsync(const QString &resourcePath)
{
    // ── Phase 1: read + parse JSON on a background thread ────────────────────
    QPointer<ServiceTreeModel> self = this;
    QtConcurrent::run([self, resourcePath]() {
        if (!self) return;

        QFile file(resourcePath);
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "ServiceTreeModel: cannot open" << resourcePath;
            if (self)
                QMetaObject::invokeMethod(self.data(), [self]() {
                    if (self) emit self->loadingFinished(false);
                });
            return;
        }

        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
        if (err.error != QJsonParseError::NoError) {
            qWarning() << "ServiceTreeModel: JSON parse error:" << err.errorString();
            if (self)
                QMetaObject::invokeMethod(self.data(), [self]() {
                    if (self) emit self->loadingFinished(false);
                });
            return;
        }

        // Capture parsed data by value — safe to pass across threads
        const QJsonArray categories = doc.array();

        // ── Phase 2: populate model on the main (UI) thread ──────────────────
        if (!self) return;
        QMetaObject::invokeMethod(self.data(), [self, categories]() {
            if (!self) return;
            self->clear();
            for (const QJsonValue &catVal : categories) {
                const QJsonObject cat = catVal.toObject();
                const int catId        = cat[QLatin1String("id")].toInt();
                const QString catName  = cat[QLatin1String("name")].toString();
                self->addCategory(catId, catName);

                const QJsonArray services = cat[QLatin1String("services")].toArray();
                for (const QJsonValue &svcVal : services) {
                    const QJsonObject svc = svcVal.toObject();
                    self->addService(catId,
                               svc[QLatin1String("id")].toInt(),
                               svc[QLatin1String("inputType")].toString(),
                               svc[QLatin1String("name")].toString(),
                               svc.contains(QLatin1String("size")) ? svc[QLatin1String("size")].toString() : QStringLiteral("1x1"),
                               svc[QLatin1String("fields")].toArray());
                }
            }
            qDebug() << "ServiceTreeModel: async loaded" << categories.size() << "categories";
            emit self->loadingFinished(true);
        });
    });
}

QString ServiceTreeModel::translatedCategoryName(int row) const
{
    if (row < 0 || row >= m_rootItem->childCount())
        return {};
    ServiceTreeItem *item = m_rootItem->child(row);
    return QCoreApplication::translate("ServiceTreeModel", item->nameUtf8().constData());
}

void ServiceTreeModel::emitAllNamesChanged(const QModelIndex &parent)
{
    const int rows = rowCount(parent);
    if (rows == 0)
        return;

    // Notify that NameRole changed for all rows at this level
    emit dataChanged(index(0, 0, parent),
                     index(rows - 1, 0, parent),
                     {NameRole, Qt::DisplayRole});

    // Recurse into children (categories → services)
    for (int r = 0; r < rows; ++r) {
        emitAllNamesChanged(index(r, 0, parent));
    }
}

ServiceTreeItem *ServiceTreeModel::itemFromIndex(const QModelIndex &index) const
{
    if (index.isValid())
        return static_cast<ServiceTreeItem *>(index.internalPointer());
    return m_rootItem;
}

ServiceTreeItem *ServiceTreeModel::findCategory(int categoryId) const
{
    return m_categoryMap.value(categoryId, nullptr);
}

InputType ServiceTreeModel::inputTypeFromString(const QString &str) const
{
    const QString lower = str.toLower();
    if (lower == QLatin1String("phone"))
        return InputType::Phone;
    if (lower == QLatin1String("iban"))
        return InputType::IBAN;
    if (lower == QLatin1String("account"))
        return InputType::Account;
    return InputType::Default;
}

} // namespace services
