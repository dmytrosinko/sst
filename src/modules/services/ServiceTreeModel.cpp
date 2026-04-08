#include "ServiceTreeModel.h"
#include <QCoreApplication>
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
        return QCoreApplication::translate("ServiceTreeModel", item->name().toUtf8().constData());
    case IdRole:
        return item->id();
    case NodeTypeRole:
        return (item->nodeType() == ServiceTreeItem::NodeType::Category)
                   ? QStringLiteral("category")
                   : QStringLiteral("service");
    case InputTypeRole:
        if (item->nodeType() == ServiceTreeItem::NodeType::Service)
            return static_cast<int>(item->inputType());
        return QVariant();
    case SizeRole:
        if (item->nodeType() == ServiceTreeItem::NodeType::Service)
            return item->size();
        return QVariant();
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
        {SizeRole, "size"}
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
    endInsertRows();
}

void ServiceTreeModel::addService(int categoryId, int serviceId,
                                  const QString &inputType, const QString &name, const QString &size)
{
    ServiceTreeItem *category = findCategory(categoryId);
    if (!category)
        return;

    QModelIndex parentIndex = createIndex(category->row(), 0, category);
    const int row = category->childCount();

    beginInsertRows(parentIndex, row, row);
    auto *service = new ServiceTreeItem(serviceId,
                                        inputTypeFromString(inputType),
                                        name, size, category);
    category->appendChild(service);
    endInsertRows();
}

void ServiceTreeModel::clear()
{
    beginResetModel();
    delete m_rootItem;
    m_rootItem = new ServiceTreeItem(0, QStringLiteral("Root"));
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
                       svc.contains(QLatin1String("size")) ? svc[QLatin1String("size")].toString() : QStringLiteral("1x1"));
        }
    }

    qDebug() << "ServiceTreeModel: loaded" << categories.size() << "categories from" << resourcePath;
    return true;
}

void ServiceTreeModel::loadFromJsonResourceAsync(const QString &resourcePath)
{
    // ── Phase 1: read + parse JSON on a background thread ────────────────────
    QtConcurrent::run([this, resourcePath]() {
        QFile file(resourcePath);
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "ServiceTreeModel: cannot open" << resourcePath;
            QMetaObject::invokeMethod(this, [this]() { emit loadingFinished(false); });
            return;
        }

        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
        if (err.error != QJsonParseError::NoError) {
            qWarning() << "ServiceTreeModel: JSON parse error:" << err.errorString();
            QMetaObject::invokeMethod(this, [this]() { emit loadingFinished(false); });
            return;
        }

        // Capture parsed data by value — safe to pass across threads
        const QJsonArray categories = doc.array();

        // ── Phase 2: populate model on the main (UI) thread ──────────────────
        QMetaObject::invokeMethod(this, [this, categories]() {
            clear();
            for (const QJsonValue &catVal : categories) {
                const QJsonObject cat = catVal.toObject();
                const int catId        = cat[QLatin1String("id")].toInt();
                const QString catName  = cat[QLatin1String("name")].toString();
                addCategory(catId, catName);

                const QJsonArray services = cat[QLatin1String("services")].toArray();
                for (const QJsonValue &svcVal : services) {
                    const QJsonObject svc = svcVal.toObject();
                    addService(catId,
                               svc[QLatin1String("id")].toInt(),
                               svc[QLatin1String("inputType")].toString(),
                               svc[QLatin1String("name")].toString(),
                               svc.contains(QLatin1String("size")) ? svc[QLatin1String("size")].toString() : QStringLiteral("1x1"));
                }
            }
            qDebug() << "ServiceTreeModel: async loaded" << categories.size() << "categories";
            emit loadingFinished(true);
        });
    });
}

QString ServiceTreeModel::translatedCategoryName(int row) const
{
    if (row < 0 || row >= m_rootItem->childCount())
        return {};
    ServiceTreeItem *item = m_rootItem->child(row);
    return QCoreApplication::translate("ServiceTreeModel", item->name().toUtf8().constData());
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
    for (int i = 0; i < m_rootItem->childCount(); ++i) {
        ServiceTreeItem *item = m_rootItem->child(i);
        if (item->nodeType() == ServiceTreeItem::NodeType::Category
            && item->id() == categoryId) {
            return item;
        }
    }
    return nullptr;
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
