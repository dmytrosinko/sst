import QtQuick
import QtQuick.Shapes
import modules.style

Shape {
   anchors.fill: parent
    ShapePath {
        strokeWidth: 0
        startX: 0; startY: 0

        // Draw the boundary of the rectangle
        PathLine { x: parent.width; y: 0 }
        PathLine { x: parent.width; y: parent.height }
        PathLine { x: 0; y: parent.height }
        PathLine { x: 0; y: 0 }
        fillGradient: LinearGradient {
            x1: 0; y1: parent.height
            x2: parent.width; y2: 0

            GradientStop { 
                position: 0.0 
                color: Style.currentStyle.backgroundGradient ? Style.currentStyle.backgroundGradient[0] : "transparent"
            }
            GradientStop { 
                position: Style.currentStyle.backgroundGradient && Style.currentStyle.backgroundGradient.length === 3 ? 0.5 : 1.0 
                color: Style.currentStyle.backgroundGradient ? Style.currentStyle.backgroundGradient[1] : "transparent"
            }
            GradientStop { 
                position: 1.0 
                color: Style.currentStyle.backgroundGradient ? (Style.currentStyle.backgroundGradient.length === 3 ? Style.currentStyle.backgroundGradient[2] : Style.currentStyle.backgroundGradient[1]) : "transparent"
            }
        }
    }
}
