import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string validatorSource: "assets/cash_slot.svg"

    property var sequences: [
        "assets/banknote_500.svg",
        "assets/banknote_1000.svg",
        "assets/banknote_5000.svg"
    ]
    property int currentIndex: 0
    property string banknoteSource: sequences[currentIndex]
    
    property int animationDuration: 1800
    property bool autoCycle: true

    // Component intrinsic sizing based on the slot SVG and fully displayed note
    implicitWidth: 600
    implicitHeight: 900 

    signal insertionFinished()

    onInsertionFinished: {
        if (root.autoCycle) {
            cycleTimer.start()
        }
    }

    Timer {
        id: cycleTimer
        interval: 100
        onTriggered: {
            // Change note while it's hidden inside the machine
            root.currentIndex = (root.currentIndex + 1) % root.sequences.length
            root.reset()
            nextInsertTimer.start()
        }
    }

    Timer {
        id: nextInsertTimer
        interval: 1200 // Time user gets to see the new note hovering
        onTriggered: {
            root.insertCash()
        }
    }

    Image {
        id: validatorBg
        source: root.validatorSource
        x: 0
        y: 0
        width: 600
        height: 200
        fillMode: Image.PreserveAspectFit
    }

    // The clipping area represents the lower half of the world, starting EXACTLY at the lip of the slot hole.
    Item {
        id: slotClippingArea
        x: 100 
        y: 85  
        width: 400
        height: root.implicitHeight - y
        clip: true

        Image {
            id: noteImage
            source: root.banknoteSource
            width: 400
            height: 850
            x: 0
            
            state: "idle"

            states: [
                State {
                    name: "idle"
                    // Visible just below the top lip, slightly hovering over the bottom rim
                    PropertyChanges { target: noteImage; y: 40 }
                },
                State {
                    name: "inserted"
                    // Rolls all the way into the machine until it's completely swallowed
                    PropertyChanges { target: noteImage; y: -noteImage.height }
                }
            ]
            
            transitions: [
                Transition {
                    from: "idle"
                    to: "inserted"
                    SequentialAnimation {
                        NumberAnimation { target: noteImage; property: "y"; duration: root.animationDuration; easing.type: Easing.InOutCubic }
                        ScriptAction { script: root.insertionFinished() }
                    }
                },
                Transition {
                    from: "inserted"
                    to: "idle"
                    SequentialAnimation {
                        // Magically reset position instantly without animation, fade it in smoothly as a "new stack"
                        PropertyAction { target: noteImage; property: "y" }
                        NumberAnimation { target: noteImage; property: "opacity"; from: 0; to: 1; duration: 500 }
                    }
                }
            ]
        }
    }

    // Expose control methods
    function insertCash() {
        noteImage.state = "inserted"
    }

    function reset() {
        noteImage.state = "idle"
    }
}
