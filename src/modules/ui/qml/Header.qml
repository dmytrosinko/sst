import QtQuick
import QtQuick.Layouts
import app
import modules.controls

Item {
    id: header
    implicitHeight: 56

    // ── Black background ──
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#000000"
    }

    // ── Content row: logo + text + language toggle ──
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 10

        Image {
            id: logoImage
            source: "qrc:/qt/qml/app/assets/logo.svg"
            Layout.preferredWidth: 75
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(75, 50)
        }

        Text {
            id: titleText
            text: "SIMBANK"
            color: "#FFFFFF"
            font.pixelSize: 50
            font.weight: Font.DemiBold
            font.letterSpacing: 1.2
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        // ── Language toggle group ──
        LanguageToggle {
            id: langToggle
            Layout.preferredWidth: 120
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter
            currentIndex: {
                switch (TranslationManager.currentLanguage) {
                    case "ky": return 1
                    case "ru": return 2
                    default:   return 0
                }
            }
            languages: [
                { label: "EN", value: "en" },
                { label: "KY", value: "ky" },
                { label: "RU", value: "ru" }
            ]
            onLanguageSelected: function(index, language) {
                TranslationManager.setLanguage(language.value)
            }
        }
    }
}
