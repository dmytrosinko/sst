import QtQuick
Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#060612" }
            GradientStop { position: 0.35; color: "#0b0b22" }
            GradientStop { position: 0.65; color: "#14103a" }
            GradientStop { position: 1.0; color: "#0c0c20" }
        }
    }
