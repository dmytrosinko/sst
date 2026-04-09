#pragma once

#include <QObject>
#include <QUrl>
#include <QtQml/qqml.h>

// QML singleton that exposes a single method: writeFile(url, content).
// Use it from QML as:  FileWriter.writeFile(saveDialog.selectedFile, text)
class FileWriter : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit FileWriter(QObject *parent = nullptr);

    // Returns true on success. fileUrl may be a file:// URL or a local path string.
    Q_INVOKABLE bool writeFile(const QUrl &fileUrl, const QString &content) const;

    // QML_SINGLETON factory (required by Qt 6 singleton registration)
    static FileWriter *create(QQmlEngine *, QJSEngine *) {
        return new FileWriter();
    }
};
