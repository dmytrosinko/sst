import QtQuick
import QtQuick.Layouts
import app
import modules.hardware
import modules.controls
import modules.services
import service.testservice

Item {
    id: root

    PanelBackground { anchors.fill: parent }

    // ── Retranslate tree model names when language changes ──
    Connections {
        target: TranslationManager
        function onLanguageChanged() {
            ServiceTreeModel.retranslate()
        }
    }

    Header {
        id: headerBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 80
        z: 100
    }

    Footer {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 40
        z: 100
    }

    Item {
        id: viewport
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // ── Tile navigation for categories → services ──
        ServiceTileView {
            id: tileView
            anchors.fill: parent
            visible: !serviceView.visible

            onServiceSelected: function(serviceId, serviceName, inputType) {
                console.log("Selected service:", serviceId, serviceName, inputType)
                ServiceModel.startService(serviceId, serviceName, inputType)
                serviceView.visible = true
                serviceView.showInputScreen()
            }
        }

        // ── Active service view (StackView-based) ──
        Service {
            id: serviceView
            visible: false
            anchors.fill: parent

            onQuitService: {
                visible = false
                ServiceModel.clearService()
            }
        }
    }

    // ── Translation keys for lupdate (context: ServiceTreeModel) ──
    // These keys match the "name" fields in assets/services.json.
    // They are picked up by lupdate via QT_TRANSLATE_NOOP:
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Payments")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Transfers")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Mobile")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Utilities")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Mobile Top-Up")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Bank Transfer")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Account Payment")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "SWIFT Transfer")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Internal Transfer")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Mobile Balance")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Mobile Internet")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "SIM Registration")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Electricity")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Water")
    //   QT_TRANSLATE_NOOP("ServiceTreeModel", "Gas")

    // ── Load service catalog from JSON (async — off the main thread) ──
    Component.onCompleted: {
        ServiceTreeModel.loadFromJsonResourceAsync(":/qt/qml/app/assets/services.json")
    }

    Connections {
        target: ServiceTreeModel
        function onLoadingFinished(success) {
            if (!success)
                console.warn("ServiceTreeModel: failed to load service catalog")
        }
    }
}
