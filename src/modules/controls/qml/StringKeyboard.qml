import QtQuick
import QtQuick.Layouts
import modules.style

// ──────────────────────────────────────────────────────────────────────────────
// StringKeyboard — full QWERTY keyboard with number row and language switch.
//
// Layout:
//   Row 1 : 1  2  3  4  5  6  7  8  9  0  -  =
//   Row 2 : Q  W  E  R  T  Y  U  I  O  P  {[
//   Row 3 : A  S  D  F  G  H  J  K  L  ;  "
//   Row 4 : Z  X  C  V  B  N  M  ,  .  ⌫
//   Row 5 : [  EN  ]  [    SPACE    ]  [  Shift  ]
// ──────────────────────────────────────────────────────────────────────────────
Item {
    id: root

    // ── Public signals ─────────────────────────────────────────────────────
    signal keyPressed(string key)
    signal backspace()
    signal spacePressed()
    signal languageSwitch()
    signal languageSelected(string lang)

    // ── Public properties ──────────────────────────────────────────────────
    property bool   uppercaseMode:      false
    property string language:           "en"

    // Set to true to hide the language-switcher key (e.g. for IBAN)
    property bool   hideLanguageButton: false
    // Set to true to hide the Shift key (e.g. when uppercase is locked)
    property bool   hideShiftButton:    false

    // Available languages shown in the popup
    property var availableLanguages: ["en", "ru", "ky"]

    implicitWidth:  960
    // Drive height from actual layout content so background always wraps it
    implicitHeight: keyboardColumn.implicitHeight + 28   // 14px margin top + bottom

    // ── Internal ───────────────────────────────────────────────────────────
    readonly property string _langLabel: language === "en" ? "EN"
                                       : language === "ky" ? "KY" : "RU"

    function _labelFor(lang) {
        if (lang === "en") return "EN — English"
        if (lang === "ru") return "RU — Русский"
        if (lang === "ky") return "KY — Кыргызча"
        return lang.toUpperCase()
    }

    // Keyboard layouts per language
    readonly property var _layouts: ({
        "en": {
            row2: ["q","w","e","r","t","y","u","i","o","p","{"],
            row2u:["Q","W","E","R","T","Y","U","I","O","P","{"],
            row3: ["a","s","d","f","g","h","j","k","l",";","\""],
            row3u:["A","S","D","F","G","H","J","K","L",";","\""],
            row4: ["z","x","c","v","b","n","m",",","."],
            row4u:["Z","X","C","V","B","N","M","<",">"]
        },
        "ru": {
            row2: ["й","ц","у","к","е","н","г","ш","щ","з","х"],
            row2u:["Й","Ц","У","К","Е","Н","Г","Ш","Щ","З","Х"],
            row3: ["ф","ы","в","а","п","р","о","л","д","ж","э"],
            row3u:["Ф","Ы","В","А","П","Р","О","Л","Д","Ж","Э"],
            row4: ["я","ч","с","м","и","т","ь","б","ю"],
            row4u:["Я","Ч","С","М","И","Т","Ь","Б","Ю"]
        },
        "ky": {
            row2: ["й","ц","у","к","е","н","г","ш","щ","з","х"],
            row2u:["Й","Ц","У","К","Е","Н","Г","Ш","Щ","З","Х"],
            row3: ["ф","ы","в","а","п","р","о","ө","л","д","ж"],
            row3u:["Ф","Ы","В","А","П","Р","О","Ө","Л","Д","Ж"],
            row4: ["я","ч","с","м","и","т","ь","б","ю"],
            row4u:["Я","Ч","С","М","И","Т","Ь","Б","Ю"]
        }
    })

    readonly property var _lang: _layouts[language] || _layouts["en"]

    // ── Reusable key component ──────────────────────────────────────────────
    component Key : Rectangle {
        id: _k

        property string label:      ""
        property color  labelColor: Style.currentStyle.textPrimary
        property bool   highlight:  false
        property real   labelSize:  16

        signal tapped()

        Layout.preferredWidth:  72
        Layout.preferredHeight: 64
        radius:                 10

        color: _ma.pressed       ? Style.currentStyle.surfacePressed
             : highlight         ? Style.currentStyle.accentSecondary
             : _ma.containsMouse ? Style.currentStyle.surfaceHover
             : Style.currentStyle.surfaceSecondary

        border.color: highlight
                      ? Style.currentStyle.borderAccent
                      : Qt.rgba(1, 1, 1, 0.07)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 80 } }
        scale: _ma.pressed ? 0.94 : 1.0
        Behavior on scale { NumberAnimation { duration: 55; easing.type: Easing.OutQuad } }

        Text {
            anchors.centerIn: parent
            text:             _k.label
            color:            _k.highlight ? Style.currentStyle.textOnAccent : _k.labelColor
            font.pixelSize:   _k.labelSize
            font.weight:      Font.Medium
            font.family:      "Segoe UI"
        }

        MouseArea {
            id:           _ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    _k.tapped()
        }
    }

    // ── Panel background ───────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Style.currentStyle.surfacePrimary
        radius:       14
        border.color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
    }

    // ── Main column ─────────────────────────────────────────────────────
    ColumnLayout {
        id: keyboardColumn
        // Anchor left/right/top with margin; let height be auto-computed by content
        anchors.left:    parent.left
        anchors.right:   parent.right
        anchors.top:     parent.top
        anchors.margins: 14
        spacing:         7

        // ── Row 1 : 1 2 3 4 5 6 7 8 9 0 - = ─────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 7
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","0","-","="]
                delegate: Key {
                    label:    modelData
                    onTapped: root.keyPressed(modelData)
                }
            }
        }

        // ── Row 2 : Q W E R T Y U I O P { ────────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 7
            Repeater {
                model: root.uppercaseMode ? root._lang.row2u : root._lang.row2
                delegate: Key {
                    label:    modelData
                    onTapped: root.keyPressed(modelData)
                }
            }
        }

        // ── Row 3 : A S D F G H J K L ; " ───────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 7
            Item { Layout.preferredWidth: 36 }
            Repeater {
                model: root.uppercaseMode ? root._lang.row3u : root._lang.row3
                delegate: Key {
                    label:    modelData
                    onTapped: root.keyPressed(modelData)
                }
            }
            Item { Layout.preferredWidth: 36 }
        }

        // ── Row 4 : Z X C V B N M , .  ⌫ ────────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 7
            Item { Layout.preferredWidth: 72 }
            Repeater {
                model: root.uppercaseMode ? root._lang.row4u : root._lang.row4
                delegate: Key {
                    label:    modelData
                    onTapped: root.keyPressed(modelData)
                }
            }
            Key {
                id: backspaceKey
                label:                  "⌫"
                Layout.preferredWidth:  100
                Layout.preferredHeight: 64
                labelColor:             Style.currentStyle.accentPrimary
                labelSize:              18
                onTapped:               root.backspace()
            }
            Item { Layout.preferredWidth: 72 }
        }

        // ── Row 5 : [EN]  ─────── SPACE ────────  [Shift] ────────────────
        RowLayout {
            id: bottomRow
            Layout.alignment: Qt.AlignHCenter
            spacing:          7

            // ── Language key (looks like a regular key) ──────────────
            Key {
                id:                     langKey
                visible:                !root.hideLanguageButton && root.availableLanguages.length > 1
                label:                  root._langLabel
                Layout.preferredWidth:  180
                Layout.preferredHeight: 64
                labelSize:              17
                labelColor:             Style.currentStyle.accentPrimary
                border.color:           Style.currentStyle.borderAccent
                border.width:           1
                onTapped:               langPopup.open()
            }

            // ── SPACE ──────────────────────────────────────────────
            Key {
                label:                  ""
                Layout.fillWidth:       true
                Layout.preferredHeight: 64
                onTapped:               root.spacePressed()
            }

            // ── Shift ──────────────────────────────────────────────
            Key {
                visible:                !root.hideShiftButton
                label:                  qsTr("Shift")
                Layout.preferredWidth:  180
                Layout.preferredHeight: 64
                highlight:              root.uppercaseMode
                labelSize:              16
                onTapped:               root.uppercaseMode = !root.uppercaseMode
            }
        }
    }

    // ──────────────────────────────────────────────────────────────────────
    // Language picker popup
    // Appears above the EN key, anchored to its position
    // ──────────────────────────────────────────────────────────────────────
    Item {
        id: langPopup

        // Popup state — position computed at open time, not as a binding
        property bool _visible: false
        property real _cardX:   0
        property real _cardY:   0

        function open() {
            // Compute at click time — layout is fully resolved at this point
            var pos = langKey.mapToItem(root, 0, 0)
            var cardW = Math.max(langKey.width, 240)
            var cardH = root.availableLanguages.length * 62 + 16
            _cardX = pos.x + (langKey.width - cardW) / 2   // center over button
            _cardY = pos.y - cardH - 8                      // bottom 8px above button top
            _visible = true
        }
        function close() { _visible = false }

        anchors.fill: parent
        visible:      _visible
        z:            100

        // ── Dim background — tap outside to close ─────────────────────────
        MouseArea {
            anchors.fill: parent
            onClicked:    langPopup.close()
        }

        // ── Popup card ────────────────────────────────────────────────────
        Rectangle {
            id: popupCard

            x: langPopup._cardX
            y: langPopup._cardY

            width:  Math.max(langKey.width, 240)
            height: root.availableLanguages.length * 62 + 16
            radius: 12

            color:        Style.currentStyle.surfaceSecondary
            border.color: Style.currentStyle.borderAccent
            border.width: 1

            // Animate in
            opacity: langPopup._visible ? 1.0 : 0.0
            scale:   langPopup._visible ? 1.0 : 0.92
            transformOrigin: Item.Bottom

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            // ── Language option list ──────────────────────────────────────
            Column {
                anchors {
                    fill:    parent
                    margins: 8
                }
                spacing: 6

                Repeater {
                    model: root.availableLanguages

                    delegate: Rectangle {
                        id: optionItem
                        property bool _hovered:  false
                        property bool _isActive: modelData === root.language

                        width:  popupCard.width - 16
                        height: 54
                        radius: 8

                        color: _optMa.pressed  ? Style.currentStyle.surfacePressed
                             : _isActive       ? Qt.rgba(0.608, 0.557, 0.769, 0.18)
                             : _optMa.containsMouse ? Style.currentStyle.surfaceHover
                             : "transparent"

                        border.color: _isActive ? Style.currentStyle.borderAccent
                                                : Qt.rgba(1, 1, 1, 0.0)
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 80 } }

                        // Active indicator bar on left
                        Rectangle {
                            visible:  optionItem._isActive
                            width:    3
                            height:   28
                            radius:   2
                            color:    Style.currentStyle.accentPrimary
                            anchors {
                                left:           parent.left
                                leftMargin:     6
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            anchors {
                                left:           parent.left
                                leftMargin:     20
                                verticalCenter: parent.verticalCenter
                            }
                            text:           root._labelFor(modelData)
                            color:          optionItem._isActive
                                            ? Style.currentStyle.accentPrimary
                                            : Style.currentStyle.textPrimary
                            font.pixelSize: 16
                            font.weight:    optionItem._isActive ? 600 : 400
                            font.family:    "Segoe UI"
                        }

                        MouseArea {
                            id:           _optMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                root.language = modelData   // only changes keyboard layout
                                langPopup.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
