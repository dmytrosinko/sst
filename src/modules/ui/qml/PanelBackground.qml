import QtQuick

Item {
    id: root
    clip: true

    // ── Dark base ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#0c0818"
    }

    // ── Corner glows: single Canvas, painted once on resize ───────
    Canvas {
        id: glowCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width, h = height

            // Top-left horizontal glow
            var g1 = ctx.createLinearGradient(0, 0, w, 0)
            g1.addColorStop(0.0, Qt.rgba(0.28, 0.12, 0.50, 0.30))
            g1.addColorStop(0.5, Qt.rgba(0.18, 0.08, 0.38, 0.10))
            g1.addColorStop(1.0, "transparent")
            ctx.fillStyle = g1
            ctx.fillRect(0, 0, w, h)

            // Top-left vertical glow
            var g2 = ctx.createLinearGradient(0, 0, 0, h)
            g2.addColorStop(0.0, Qt.rgba(0.25, 0.10, 0.45, 0.25))
            g2.addColorStop(0.5, Qt.rgba(0.16, 0.06, 0.32, 0.08))
            g2.addColorStop(1.0, "transparent")
            ctx.fillStyle = g2
            ctx.fillRect(0, 0, w, h)

            // Bottom-right horizontal glow
            var g3 = ctx.createLinearGradient(0, 0, w, 0)
            g3.addColorStop(0.0, "transparent")
            g3.addColorStop(0.5, Qt.rgba(0.12, 0.05, 0.28, 0.08))
            g3.addColorStop(1.0, Qt.rgba(0.20, 0.08, 0.38, 0.20))
            ctx.fillStyle = g3
            ctx.fillRect(0, 0, w, h)

            // Bottom-right vertical glow
            var g4 = ctx.createLinearGradient(0, 0, 0, h)
            g4.addColorStop(0.0, "transparent")
            g4.addColorStop(0.5, Qt.rgba(0.14, 0.05, 0.28, 0.06))
            g4.addColorStop(1.0, Qt.rgba(0.20, 0.08, 0.36, 0.16))
            ctx.fillStyle = g4
            ctx.fillRect(0, 0, w, h)

            // Right edge darkening
            var g5 = ctx.createLinearGradient(w * 0.75, 0, w, 0)
            g5.addColorStop(0.0, "#00060410")
            g5.addColorStop(1.0, "#50060410")
            ctx.fillStyle = g5
            ctx.fillRect(w * 0.75, 0, w * 0.25, h)
        }
    }
}
