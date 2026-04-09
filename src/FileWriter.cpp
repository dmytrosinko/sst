#include "FileWriter.h"

#include <QFile>
#include <QTextStream>
#include <QUrl>

FileWriter::FileWriter(QObject *parent)
    : QObject(parent)
{}

bool FileWriter::writeFile(const QUrl &fileUrl, const QString &content) const
{
    const QString path = fileUrl.isLocalFile() ? fileUrl.toLocalFile() : fileUrl.toString();

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        qWarning("FileWriter: cannot open '%s' for writing: %s",
                 qPrintable(path),
                 qPrintable(file.errorString()));
        return false;
    }

    QTextStream out(&file);
    out << content;
    return true;
}
