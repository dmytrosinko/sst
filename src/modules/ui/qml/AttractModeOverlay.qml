import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import modules.style

// ── AttractModeOverlay ───────────────────────────────────────────────────────
//
//  Phase machine:
//    IDLE → SETTLING  (tiles appear at their real grid position @ scale 0.6,
//                      fade-in over ~300ms, hold for settleDelay ms)
//         → ENTERING  (tiles fly from source pos to triangle @ scale 1.0
//                      = 250×250 px, 650ms OutCubic)
//         → PULSING   (border glow pulse + breathing scale 1.0↔1.05, 30 s)
//         → RETURNING (tiles fly back to source pos @ scale 0.6, 650ms)
//         → IDLE → cycleFinished() → host repicks → startAttract() again
//
//  Tile visual size at triangle = 250 × 250 px  (scale 1.0).
//
//  Non-overlap guarantee:
//    Circumradius R = _tileBase * 0.90 → vertex distance = R√3 ≈ 390px > 250px ✓
//
//  Glow = blurred outer ring + crisp inner border, both driven by _glowOpacity.
// ---------------------------------------------------------------------------

Item {
    id: overlay

    // ── Public API ───────────────────────────────────────────────────────────
    // Array[3] of: { itemId, name, iconSource, inputType, srcX, srcY, tileW, tileH }
    // srcX/srcY = centre of the source tile in overlay's coordinate system.
    property var items: []

    signal dismissed()
    signal dismissFinished()       // emitted after the dismiss return animation ends
    signal serviceClicked(int serviceId, string serviceName, int inputType)
    signal cycleFinished()

    // ── Phase ────────────────────────────────────────────────────────────────
    property string _phase: "IDLE"   // IDLE | SETTLING | ENTERING | PULSING | RETURNING

    // Delay (ms) between tiles appearing at their grid position and flying
    // to the triangle formation.  Gives the eye time to register origin.
    property int settleDelay: 500

    // Glow brightness: 0.0 → 1.0 → 0.0
    property real _glowOpacity: 0.0

    // Breathing multiplier (applied to each tile's scale during PULSING)
    property real _pulseScale:  1.0

    // Tile-level fade (0→1) used during SETTLING phase
    property real _tileOpacity: 0.0

    // Guard: false = position/scale changes snap instantly (no Behavior anim)
    property bool _behaviorsEnabled: false

    // True when we are returning tiles because the user dismissed attract mode
    // (as opposed to the 30 s cycle auto-return)
    property bool _dismissing: false

    // Clockwise rotation offset (0, 1, 2) — shifts tile positions in triangle
    property int _rotationOffset: 0

    // ── Triangle positions ────────────────────────────────────────────────────
    //
    //  Layout (fixed, matching the screen layout):
    //
    //            [1] top-center
    //
    //  [0] left-bottom          [2] right-bottom
    //
    // Tiles are confined to the area between headerHeight and footerHeight.
    // Passed in from Home.qml so the overlay knows where the chrome ends.

    property real headerHeight: 80
    property real footerHeight: 40
    readonly property real _tileBase:   250.0   // tile rendered size (scale 1.0)

    // Virtual square: 60% of overlay width (clamped to available height),
    // with tile padding so tiles never overflow the boundary.
    readonly property real _availH:     height - headerHeight - footerHeight
    readonly property real _squareSize: Math.min(width * 0.60, _availH) - _tileBase * 0.5
    readonly property real _squareLeft: (width - _squareSize) / 2
    readonly property real _squareTop:  headerHeight + (_availH - _squareSize) / 2

    // Top-left x/y for tile i  (tile is _tileBase × _tileBase)
    //
    //            [1] top-center
    //
    //  [0] left-bottom          [2] right-bottom
    //
    function _vx(i) {
        switch (i) {
            case 0: return _squareLeft                                          // left-bottom
            case 1: return _squareLeft + (_squareSize - _tileBase) / 2         // top-center
            case 2: return _squareLeft + _squareSize - _tileBase               // right-bottom
        }
        return 0
    }
    function _vy(i) {
        var topY    = _squareTop
        var bottomY = _squareTop + _squareSize - _tileBase
        switch (i) {
            case 0: return bottomY   // left-bottom
            case 1: return topY      // top-center
            case 2: return bottomY   // right-bottom
        }
        return 0
    }

    // ── Dim backdrop ─────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:   "black"
        opacity: _phase === "IDLE" ? 0.0
               : _phase === "SETTLING" ? 0.35
               : _phase === "RETURNING" ? 0.20
               : 0.62
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // ── Ambient central glow (behind the triangle) ───────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width:   _tileBase * 4.0
        height:  _tileBase * 4.0
        radius:  width / 2
        color:   Qt.rgba(0.455, 0.380, 0.820, _glowOpacity * 0.20)
        visible: _phase !== "IDLE"

        layer.enabled: visible
        layer.effect: MultiEffect {
            blurEnabled: true
            blur:        1.0
            blurMax:     72
        }
    }

    // ── Attract tiles ─────────────────────────────────────────────────────────
    Repeater {
        id: tileRepeater
        model: Math.min(overlay.items.length, 3)

        delegate: Item {
            id: att
            opacity: overlay._tileOpacity
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            required property int index

            readonly property var svc: overlay.items[att.index] ?? {}

            // Logical size = attract tile size (250 × 250 at scale 1.0)
            width:  overlay._tileBase
            height: overlay._tileBase

            // Initial defaults; overridden by startAttract before becoming visible
            x: 0
            y: 0
            scale: (att.svc.tileW ?? overlay._tileBase) / overlay._tileBase

            // Smooth animated transitions — only when _behaviorsEnabled is true
            Behavior on x     { enabled: overlay._behaviorsEnabled; NumberAnimation { duration: 650; easing.type: Easing.OutCubic } }
            Behavior on y     { enabled: overlay._behaviorsEnabled; NumberAnimation { duration: 650; easing.type: Easing.OutCubic } }
            Behavior on scale { enabled: overlay._behaviorsEnabled; NumberAnimation { duration: 650; easing.type: Easing.OutCubic } }

            // Breathing: push _pulseScale into att.scale while PULSING
            Connections {
                target: overlay
                function on_PulseScaleChanged() {
                    if (overlay._phase === "PULSING")
                        att.scale = overlay._pulseScale
                }
            }

            // ── Drop shadow ───────────────────────────────────────────────
            layer.enabled: _phase !== "IDLE"
            layer.effect: MultiEffect {
                shadowEnabled:          true
                shadowColor:            Qt.rgba(0, 0, 0, 0.65)
                shadowHorizontalOffset: 0
                shadowVerticalOffset:   8
                shadowBlur:             0.9
                shadowScale:            1.04
            }

            // ── Blurred outer glow ring ───────────────────────────────────
            // Sits behind the tile body; its blurred border bleeds outward.
            // Rectangle {
            //     anchors.centerIn: parent
            //     width:   att.width  + 28
            //     height:  att.height + 28
            //     radius:  att.width * 0.10
            //     color:   "transparent"
            //     border.color: Qt.rgba(0.608, 0.380, 1.0, overlay._glowOpacity)
            //     border.width: 7

            //     layer.enabled: overlay._phase !== "IDLE"
            //     layer.effect: MultiEffect {
            //         blurEnabled: true
            //         blur:        0.80
            //         blurMax:     36
            //     }
            // }

            // ── Crisp inner border ring ───────────────────────────────────
            Rectangle {
                anchors.fill: parent
                radius:       att.width * 0.08
                color:        "transparent"
                border.color: Qt.rgba(0.760, 0.560, 1.0, overlay._glowOpacity * 0.88)
                border.width: 3
                z: 5
            }

            // ── Tile body ─────────────────────────────────────────────────
            Rectangle {
                anchors.fill: parent
                radius:  att.width * 0.08
                color:   Style.currentStyle.tileColor
                clip:    true
                z: 2

                // Subtle inner luminance breath
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(0.455, 0.340, 0.900, overlay._glowOpacity * 0.10)
                    z: 1
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: att.height * 0.06
                    z: 2

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: att.svc.iconSource ?? ""
                        sourceSize.width:  att.height * 0.40
                        sourceSize.height: att.height * 0.40
                        onStatusChanged: if (status === Image.Error)
                            source = "qrc:/qt/qml/app/assets/icons/default.svg"
                    }

                    Text {
                        Layout.alignment:    Qt.AlignHCenter
                        Layout.maximumWidth: att.width * 0.82
                        text:   att.svc.name ?? ""
                        font.pixelSize:  att.height * 0.13
                        font.weight:     Font.Bold
                        font.family:     Style.currentStyle.fontFamily
                        color:           Style.currentStyle.tileTextColor
                        horizontalAlignment: Text.AlignHCenter
                        elide:    Text.ElideRight
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                    }
                }
            }

            // ── Tap handler ───────────────────────────────────────────────
            MouseArea {
                anchors.fill: parent
                enabled: overlay._phase === "PULSING"
                z: 10
                cursorShape: Qt.PointingHandCursor
                onClicked: overlay.serviceClicked(att.svc.itemId    ?? 0,
                                                   att.svc.name     ?? "",
                                                   att.svc.inputType ?? 0)
            }
        }
    }

    // ── "Tap anywhere to exit" hint ──────────────────────────────────────────
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:           parent.bottom
        anchors.bottomMargin:     24
        text:    qsTr("Tap anywhere to exit")
        color:   Qt.rgba(1, 1, 1, 0.50)
        font.pixelSize: 14
        font.family:    Style.currentStyle.fontFamily
        opacity: _phase === "PULSING" ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // ── Tap-outside-to-dismiss ───────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        z: -1
        enabled: _phase === "PULSING"
        onClicked: overlay.dismissed()
    }

    // ── Glow pulse animation ──────────────────────────────────────────────────
    // Drives _glowOpacity  0.20 ↔ 1.00
    // SequentialAnimation {
    //     id: glowAnim
    //     loops: Animation.Infinite
    //     NumberAnimation {
    //         target: overlay;  property: "_glowOpacity"
    //         from: 0.20;  to: 1.00;  duration: 850;  easing.type: Easing.InOutSine
    //     }
    //     NumberAnimation {
    //         target: overlay;  property: "_glowOpacity"
    //         from: 1.00;  to: 0.20;  duration: 850;  easing.type: Easing.InOutSine
    //     }
    // }

    // ── Breathing scale animation ─────────────────────────────────────────────
    // Drives _pulseScale  1.00 → 1.10 → 1.00  (+10% pulse)
    SequentialAnimation {
        id: breatheAnim
        loops: Animation.Infinite
        NumberAnimation {
            target: overlay;  property: "_pulseScale"
            from: 1.00;  to: 1.10;  duration: 950;  easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: overlay;  property: "_pulseScale"
            from: 1.10;  to: 1.00;  duration: 950;  easing.type: Easing.InOutSine
        }
    }

    // ── Timers ────────────────────────────────────────────────────────────────
    Timer { id: cycleTimer;   interval: 30000;              repeat: false; onTriggered: _beginReturn()    }
    Timer { id: settleTimer;  interval: overlay.settleDelay; repeat: false; onTriggered: _beginEntering() }
    Timer { id: flyInTimer;   interval: 700;                repeat: false; onTriggered: _beginPulse()     }
    Timer {
        id: returnTimer;  interval: 700;  repeat: false
        onTriggered: {
            _phase       = "IDLE"
            _glowOpacity = 0.0
            _pulseScale  = 1.0
            _tileOpacity = 0.0
            if (_dismissing) {
                _dismissing = false
                items       = []   // destroy delegates
                overlay.dismissFinished()
            } else {
                overlay.cycleFinished()
            }
        }
    }

    // Rotate tiles clockwise every 10 s during PULSING
    Timer {
        id: rotateTimer;  interval: 10000;  repeat: true
        onTriggered: _rotateTiles()
    }
    // Re-disable behaviors and restart breathing after rotation settles
    Timer {
        id: rotateSettleTimer;  interval: 700;  repeat: false
        onTriggered: {
            _behaviorsEnabled = false
            _pulseScale       = 1.0
            breatheAnim.restart()   // restart breathing from 1.0
        }
    }

    // After tiles have flown back (700ms), fade them out then finish cycle
    Timer {
        id: returnFadeTimer;  interval: 700;  repeat: false
        onTriggered: {
            _tileOpacity = 0.0   // fade out (300ms via Behavior)
            returnTimer.restart()
        }
    }

    // Clean up tile delegates after dismiss fade-out completes
    Timer {
        id: dismissTimer;  interval: 500;  repeat: false
        onTriggered: items = []
    }

    // ── Public functions ──────────────────────────────────────────────────────

    // Call with items[] already populated to begin the animation.
    function startAttract() {
        if (items.length < 3) return
        _stopAll()
        _phase            = "SETTLING"
        _glowOpacity      = 0.0
        _pulseScale       = 1.0
        _tileOpacity      = 0.0
        _behaviorsEnabled = false
        _rotationOffset   = 0   // disable so initial snap is instant

        // 1. Snap tiles instantly to their real on-screen source positions
        Qt.callLater(function() {
            for (var i = 0; i < tileRepeater.count; i++) {
                var t = tileRepeater.itemAt(i)
                if (!t) continue
                var s = overlay.items[i]
                t.x     = s.srcX - _tileBase / 2
                t.y     = s.srcY - _tileBase / 2
                t.scale = s.tileW / _tileBase   // real source size (e.g. 200/250 = 0.8)
            }

            // 2. Fade tiles in at their source grid position
            _tileOpacity = 1.0

            // 3. After settleDelay ms, enable behaviors and fly to triangle
            settleTimer.restart()
        })
    }

    function stopAttract() {
        if (_phase === "IDLE") return
        _dismissing = true
        _beginReturn()   // play return animation, then dismissFinished fires
    }

    // Instant cleanup with no animation (e.g. when launching a service)
    function killAttract() {
        _stopAll()
        _phase            = "IDLE"
        _glowOpacity      = 0.0
        _pulseScale       = 1.0
        _tileOpacity      = 0.0
        _behaviorsEnabled = false
        _rotationOffset   = 0
        _dismissing       = false
        items             = []
    }

    // ── Private ───────────────────────────────────────────────────────────────

    function _stopAll() {
        //glowAnim.stop()
        breatheAnim.stop()
        cycleTimer.stop()
        settleTimer.stop()
        flyInTimer.stop()
        returnFadeTimer.stop()
        returnTimer.stop()
        rotateTimer.stop()
        rotateSettleTimer.stop()
        dismissTimer.stop()
    }

    function _beginEntering() {
        _phase = "ENTERING"
        _behaviorsEnabled = true    // NOW animations are on
        for (var i = 0; i < tileRepeater.count; i++) {
            var t = tileRepeater.itemAt(i)
            if (!t) continue
            t.x     = overlay._vx(i)
            t.y     = overlay._vy(i)
            t.scale = 1.0    // 250 × 250 px
        }
        flyInTimer.restart()
    }

    function _beginPulse() {
        _phase            = "PULSING"
        _behaviorsEnabled = false   // let breatheAnim drive scale directly
        _glowOpacity      = 0.20
        _pulseScale       = 1.0
        _rotationOffset   = 0
        //glowAnim.restart()
        breatheAnim.restart()
        cycleTimer.restart()
        rotateTimer.restart()
    }

    // Rotate tiles one step clockwise within the triangle
    function _rotateTiles() {
        if (_phase !== "PULSING") return

        // 1. Stop breathing and reset scale to 1.0 before moving
        breatheAnim.stop()
        _pulseScale = 1.0
        for (var i = 0; i < tileRepeater.count; i++) {
            var t = tileRepeater.itemAt(i)
            if (t) t.scale = 1.0
        }

        // 2. Rotate positions clockwise
        _rotationOffset = (_rotationOffset + 1) % 3
        _behaviorsEnabled = true
        for (var j = 0; j < tileRepeater.count; j++) {
            var tile = tileRepeater.itemAt(j)
            if (!tile) continue
            var slot = (j + _rotationOffset) % 3
            tile.x = overlay._vx(slot)
            tile.y = overlay._vy(slot)
        }

        // 3. After settle, disable behaviors and restart breathing
        rotateSettleTimer.restart()
    }

    function _beginReturn() {
        _phase            = "RETURNING"
        _behaviorsEnabled = true    // re-enable for fly-back animation
        rotateTimer.stop()
        rotateSettleTimer.stop()
        //glowAnim.stop()
        breatheAnim.stop()
        _glowOpacity      = 0.0
        _pulseScale       = 1.0
        _rotationOffset   = 0

        // Fly tiles back to source positions, restoring original size
        // (keep tiles fully visible so user sees the flight)
        for (var i = 0; i < tileRepeater.count; i++) {
            var t = tileRepeater.itemAt(i)
            if (!t) continue
            var s = overlay.items[i]
            t.x     = s.srcX - _tileBase / 2
            t.y     = s.srcY - _tileBase / 2
            t.scale = s.tileW / _tileBase   // back to real source size
        }
        // After tiles land, fade them out then signal cycle finished
        returnFadeTimer.restart()
    }
}
