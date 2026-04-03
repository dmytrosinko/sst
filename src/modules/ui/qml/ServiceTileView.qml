import QtQuick
import QtQuick.Layouts
import QtQml.Models
import modules.services
import modules.style
import modules.controls

Item {
    id: root

    signal serviceSelected(int serviceId, string serviceName, int inputType)

    // ── Internal state ──────────────────────────────────────────────
    property int selectedCategoryId: -1
    property int selectedCategoryRow: -1  // row in the root model
    property var selectedCategoryIndex    // QModelIndex for DelegateModel rootIndex

    // Dynamically translated category name (re-evaluated on language change)
    readonly property string selectedCategoryName: {
        // Depend on translationRevision to re-evaluate when language changes
        void ServiceTreeModel.translationRevision
        return selectedCategoryRow >= 0
            ? ServiceTreeModel.translatedCategoryName(selectedCategoryRow)
            : ""
    }

    // Hoisted icon path – shared by all service tiles in a category (#6)
    readonly property string _serviceCategoryIconPath:
        root.selectedCategoryId >= 0
        ? "qrc:/qt/qml/app/assets/icons/" + root.selectedCategoryId + ".svg"
        : ""

    // ── Back button (visible only in services view) ─────────────────
    Item {
        id: backBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56
        visible: root.selectedCategoryId >= 0
        z: 10

        // Removed: transparent Rectangle that served no purpose (#3)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            BackButton {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    root.selectedCategoryId = -1
                    root.selectedCategoryRow = -1
                }
            }

            // Category name breadcrumb
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: root.selectedCategoryName
                font.pixelSize: Style.currentStyle.fontSizeXLarge
                font.weight: Font.DemiBold
                color: Style.currentStyle.textHeading
                elide: Text.ElideRight
            }
        }

        // Bottom separator glow
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: Style.currentStyle.borderAccent }
                GradientStop { position: 0.7; color: Style.currentStyle.borderAccent }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ── Tile grid container ─────────────────────────────────────────
    // NOTE: For large service catalogs (50+ items), consider migrating
    // Grid + Repeater → GridView for automatic delegate virtualization (#7).
    Item {
        id: gridContainer
        anchors.top: backBar.visible ? backBar.bottom : parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        readonly property int tileSpacing: 20
        readonly property int activeCount: root.selectedCategoryId < 0
                                           ? catRepeater.count
                                           : svcDelegateModel.count
        readonly property int cols: Math.max(1, Math.ceil(Math.sqrt(activeCount)))
        readonly property int rows: Math.max(1, Math.ceil(activeCount / cols))
        readonly property real _maxW: (width  * 0.8 - (cols - 1) * tileSpacing) / Math.max(1, cols)
        readonly property real _maxH: (height * 0.8 - (rows - 1) * tileSpacing) / Math.max(1, rows)
        // Merged tileWidth / tileHeight into single tileSize (#5)
        readonly property real tileSize: Math.min(_maxW, _maxH)

        // ── Categories view ─────────────────────────────────────────
        Grid {
            id: categoriesGrid
            anchors.centerIn: parent

            columns: gridContainer.cols
            spacing: gridContainer.tileSpacing

            // Proper fade-out then hide / show then fade-in (#8)
            states: State {
                name: "hidden"
                when: root.selectedCategoryId >= 0
                PropertyChanges {
                    categoriesGrid.opacity: 0
                    categoriesGrid.visible: false
                }
            }

            transitions: [
                Transition {
                    to: "hidden"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 250; easing.type: Easing.InOutQuad }
                        PropertyAction { property: "visible" }
                    }
                },
                Transition {
                    from: "hidden"
                    SequentialAnimation {
                        PropertyAction { property: "visible" }
                        NumberAnimation { property: "opacity"; duration: 250; easing.type: Easing.InOutQuad }
                    }
                }
            ]

            Repeater {
                id: catRepeater
                model: ServiceTreeModel

                // Root items are always categories – nodeType guard removed (#1)
                delegate: Tile {
                    id: categoryTile
                    required property int itemId
                    required property string name
                    required property var index

                    width: gridContainer.tileSize
                    height: gridContainer.tileSize

                    iconSource: "qrc:/qt/qml/app/assets/icons/" + categoryTile.itemId + ".svg"
                    label: categoryTile.name

                    onClicked: {
                        root.selectedCategoryId = categoryTile.itemId
                        root.selectedCategoryRow = categoryTile.index
                        root.selectedCategoryIndex = ServiceTreeModel.index(categoryTile.index, 0)
                    }
                }
            }
        }

        // ── Services view ───────────────────────────────────────────
        Grid {
            id: servicesGrid
            anchors.centerIn: parent
            visible: false
            opacity: 0

            columns: gridContainer.cols
            spacing: gridContainer.tileSpacing

            // Proper show then fade-in / fade-out then hide (#8)
            states: State {
                name: "shown"
                when: root.selectedCategoryId >= 0
                PropertyChanges {
                    servicesGrid.visible: true
                    servicesGrid.opacity: 1
                }
            }

            transitions: [
                Transition {
                    to: "shown"
                    SequentialAnimation {
                        PropertyAction { property: "visible" }
                        NumberAnimation { property: "opacity"; duration: 250; easing.type: Easing.InOutQuad }
                    }
                },
                Transition {
                    from: "shown"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 250; easing.type: Easing.InOutQuad }
                        PropertyAction { property: "visible" }
                    }
                }
            ]

            Repeater {
                id: svcRepeater

                // DelegateModel drives directly from the tree model –
                // no JS loop, no ListModel copy (#2)
                model: DelegateModel {
                    id: svcDelegateModel
                    model: ServiceTreeModel
                    rootIndex: root.selectedCategoryIndex !== undefined
                               ? root.selectedCategoryIndex
                               : ServiceTreeModel.index(0, 0)

                    delegate: Tile {
                        id: serviceTile
                        required property int itemId
                        required property string name
                        required property int inputType

                        width: gridContainer.tileSize
                        height: gridContainer.tileSize

                        iconSource: root._serviceCategoryIconPath
                        label: serviceTile.name

                        onClicked: {
                            root.serviceSelected(serviceTile.itemId,
                                                 serviceTile.name,
                                                 serviceTile.inputType)
                        }
                    }
                }
            }
        }
    }

}
