import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import modules.style

Rectangle {
    id: tile

    // ── Drop shadow ─────────────────────────────────────────────────
    layer.enabled: tile.visible
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.6)
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 4
        shadowBlur: 0.8
        shadowScale: 1.02
    }

    // ── Public API ──────────────────────────────────────────────────
    property string iconSource: ""
    property string label: ""

    readonly property bool hovered: tileMouseArea.containsMouse
    readonly property bool pressed: tileMouseArea.pressed

    signal clicked()

    // ── Tile styling ────────────────────────────────────────────────
    radius: Math.min(width, height) * 0.08
    color: SimbankPallete.currentTileColor
    clip: true
    border.color: tileMouseArea.containsMouse
                  ? Qt.rgba(0.6, 0.55, 0.77, 0.6)
                  : Qt.rgba(1, 1, 1, 0.20)
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

    scale: tileMouseArea.pressed ? 0.95 : 1.0



    // ── Icon + Label ────────────────────────────────────────────────
    ColumnLayout {
        anchors.centerIn: parent
        spacing: tile.height * 0.06
        z: 1

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: tile.iconSource
            sourceSize.width: tile.height * 0.40
            sourceSize.height: tile.height * 0.40
            onStatusChanged: if (status === Image.Error)
                source = "qrc:/qt/qml/app/assets/icons/default.svg"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: tile.width * 0.85
            text: tile.label
            font.pixelSize: tile.height * 0.14
            font.weight: Font.Bold
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }
    }

    // ── Mouse interaction ───────────────────────────────────────────
    MouseArea {
        id: tileMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 2
        onClicked: tile.clicked()
    }
}
