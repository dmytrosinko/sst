import QtQuick
import QtQuick.Layouts
import QtQml.Models
import app
import modules.services
import modules.style
import modules.controls

Item {
    id: root

    signal serviceSelected(int serviceId, string serviceName, int inputType)

    // Emitted when 3 attract tiles are ready; positions are in tileView's
    // own coordinate space so the caller (Home.qml) can map them further.
    signal attractItemsReady(var attractItems)

    // ── Attract mode ─────────────────────────────────────────────────
    property bool attractMode: false

    onAttractModeChanged: {
        if (attractMode) {
            _launchAttract()
        }
        // Stopping is handled by the overlay in Home.qml via its own stopAttract()
    }

    // Use the currently visible page — no scrolling.  Pick 3 tiles from it
    // and fly them straight to the triangle from their on-screen positions.
    function _launchAttract() {
        if (topSection._pages.length === 0) return

        var currentPage = pageView.currentIndex
        if (currentPage < 0 || currentPage >= topSection._pages.length) return
        if (topSection._pages[currentPage].length < 3) return

        // Build attract items immediately from the visible page
        _buildAttractItems(currentPage)
    }

    // Repick after a 30 s cycle: scroll to a different page, wait for scroll
    // to settle, then pick 3 new tiles from that page.
    function _repickAttract() {
        if (!attractMode) return
        if (topSection._pages.length === 0) return

        // Gather pages with at least 3 tiles
        var candidates = []
        for (var p = 0; p < topSection._pages.length; p++) {
            if (topSection._pages[p].length >= 3) candidates.push(p)
        }
        if (candidates.length === 0) return

        // Prefer a different page from the current one
        var currentPage = pageView.currentIndex
        var otherPages  = candidates.filter(function(p) { return p !== currentPage })
        var chosenPage  = otherPages.length > 0
                          ? otherPages[Math.floor(Math.random() * otherPages.length)]
                          : candidates[Math.floor(Math.random() * candidates.length)]

        // Animated scroll to the chosen page
        pageScrollAnim.to = chosenPage * pageView.width
        pageScrollAnim.restart()

        // After scroll settles, snapshot positions and start overlay
        attractScrollTimer.chosenPage = chosenPage
        attractScrollTimer.restart()
    }

    // Public: called by Home.qml when the overlay cycle finishes
    function triggerRepick() { _repickAttract() }

    // Build the items[] array for AttractModeOverlay from a given page index
    function _buildAttractItems(pageIdx) {
        var pg = topSection._pages[pageIdx]
        if (!pg || pg.length < 3) return

        // Shuffle page items and take first 3
        var pool = pg.slice()
        for (var i = pool.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1))
            var tmp = pool[i]; pool[i] = pool[j]; pool[j] = tmp
        }
        var chosen = pool.slice(0, 3)

        var listItems = []
        for (var k = 0; k < chosen.length; k++) {
            var svc   = chosen[k]
            var tileW = svc.size === "2x2" ? 420 : 200
            var tileH = svc.size === "2x2" ? 420 : 200

            // Compute grid canvas offset (gridCanvas is centred inside each page delegate)
            var pageDelegate = pageView.itemAtIndex(pageIdx)
            var canvasX = 0; var canvasY = 0
            if (pageDelegate) {
                canvasX = (pageView.width  - (topSection._gridCols * topSection._stride - 20)) / 2
                canvasY = (pageView.height - (topSection._gridRows * topSection._stride - 20)) / 2
            }

            // Tile top-left in topSection's coordinate space
            var tsX = canvasX + svc.col * topSection._stride
            var tsY = pageView.y + canvasY + svc.row * topSection._stride

            // Map tile centre to tileView (root) coordinate space:
            //   topSection has anchors.margins = 20 → it is offset (20, 20) inside root
            var srcX = topSection.x + tsX + tileW / 2
            var srcY = topSection.y + tsY + tileH / 2

            listItems.push({
                itemId:    svc.itemId,
                name:      svc.name,
                iconSource: root._serviceCategoryIconPath,
                inputType: svc.inputType,
                srcX:      srcX,
                srcY:      srcY,
                tileW:     tileW,
                tileH:     tileH
            })
        }
        // Emit — Home.qml will convert coords and start the overlay
        root.attractItemsReady(listItems)
    }

    // ── Internal state ──────────────────────────────────────────────
    // By default, showing "Top Services" (ID 0).
    property int selectedCategoryId: 0
    property int selectedCategoryRow: 0
    property var selectedCategoryIndex: ServiceTreeModel.index(0, 0)

    // Dynamically translated category name (re-evaluated on language change)
    readonly property string selectedCategoryName: {
        void ServiceTreeModel.translationRevision
        return selectedCategoryRow >= 0
            ? ServiceTreeModel.translatedCategoryName(selectedCategoryRow)
            : ""
    }

    readonly property string _serviceCategoryIconPath:
        root.selectedCategoryId >= 0
        ? "qrc:/qt/qml/app/assets/icons/" + root.selectedCategoryId + ".svg"
        : ""

    // ── Saved initial state for "back to start" ─────────────────────
    property int _initCategoryId: 0
    property int _initCategoryRow: 0
    property var _initCategoryIndex

    // Animated page scroll for attract mode
    NumberAnimation {
        id: pageScrollAnim
        target: pageView
        property: "contentX"
        to: 0
        duration: 550
        easing.type: Easing.InOutCubic
    }

    // Delay after scroll before snapshotting tile positions
    Timer {
        id: attractScrollTimer
        interval: 600
        repeat: false
        property int chosenPage: 0
        onTriggered: root._buildAttractItems(chosenPage)
    }

    Component.onCompleted: {
        autoScroll.start()
    }

    Connections {
        target: ServiceTreeModel
        function onLoadingFinished(success) {
            if (success) {
                // Now the model has data — set a valid rootIndex for the DelegateModel
                root.selectedCategoryIndex = ServiceTreeModel.index(root.selectedCategoryRow, 0)

                // Also capture the real initial state for the back button
                root._initCategoryId    = root.selectedCategoryId
                root._initCategoryRow   = root.selectedCategoryRow
                root._initCategoryIndex = ServiceTreeModel.index(root.selectedCategoryRow, 0)
            }
        }
    }

    // ── Top Section: Services Flow ──────────────────────────────────
    Item {
        id: topSection
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomSection.top
        anchors.margins: 20

        BackButton {
            id: backBtn
            anchors.top: parent.top
            anchors.left: parent.left
            visible: root.selectedCategoryId !== 0

            onClicked: {
                // Restore exactly the view the user saw when the app launched
                root.selectedCategoryId    = root._initCategoryId
                root.selectedCategoryRow   = root._initCategoryRow
                root.selectedCategoryIndex = root._initCategoryIndex
            }
        }

        Text {
            id: categoryTitle
            anchors.top: parent.top
            anchors.left: backBtn.visible ? backBtn.right : parent.left
            anchors.leftMargin: backBtn.visible ? 12 : 0
            anchors.verticalCenter: backBtn.verticalCenter
            visible: root.selectedCategoryId !== 0
            text: root.selectedCategoryName
            font.pixelSize: Style.currentStyle.fontSizeXLarge
            font.weight: Font.DemiBold
            color: Style.currentStyle.textHeading
        }


        // Hidden DelegateModel — used only to read item data for page building
        DelegateModel {
            id: svcDelegateModel
            model: ServiceTreeModel
            rootIndex: root.selectedCategoryIndex !== undefined
                       ? root.selectedCategoryIndex
                       : ServiceTreeModel.index(0, 0)
            delegate: Item {} // dummy — real rendering is in pageView delegates

            onCountChanged: Qt.callLater(topSection._buildPages)
        }

        // ── Page building ────────────────────────────────────────────
        property var _pages: []
        property int _gridCols: Math.max(1, Math.floor((width + 20) / 220))
        readonly property int _gridRows: 2
        readonly property int _stride: 220  // 200px tile + 20px gap

        function _buildPages() {
            var cols = topSection._gridCols
            var rows = topSection._gridRows

            // Helper: make a fresh empty 2D grid
            function makeGrid() {
                var g = []
                for (var r = 0; r < rows; r++) {
                    g.push([])
                    for (var c = 0; c < cols; c++) g[r].push(false)
                }
                return g
            }

            // Find top-left [row, col] where a w×h block fits, or null if full
            function findPos(grid, w, h) {
                for (var r = 0; r <= rows - h; r++) {
                    for (var c = 0; c <= cols - w; c++) {
                        var ok = true
                        for (var dr = 0; dr < h && ok; dr++)
                            for (var dc = 0; dc < w && ok; dc++)
                                if (grid[r+dr][c+dc]) ok = false
                        if (ok) return { row: r, col: c }
                    }
                }
                return null
            }

            function markGrid(grid, r, c, w, h) {
                for (var dr = 0; dr < h; dr++)
                    for (var dc = 0; dc < w; dc++)
                        grid[r+dr][c+dc] = true
            }

            var allPages = []
            var page  = []
            var grid  = makeGrid()

            for (var i = 0; i < svcDelegateModel.count; i++) {
                var entry = svcDelegateModel.items.get(i)
                var sz  = entry.model.size || "1x1"
                var w   = sz === "2x2" ? 2 : 1
                var h   = sz === "2x2" ? 2 : 1
                var pos = findPos(grid, w, h)

                if (!pos) {
                    // Page full — flush and start fresh
                    allPages.push(page)
                    page = []
                    grid = makeGrid()
                    pos  = findPos(grid, w, h) || { row: 0, col: 0 }
                }

                markGrid(grid, pos.row, pos.col, w, h)
                page.push({
                    itemId:    entry.model.itemId,
                    name:      entry.model.name,
                    inputType: entry.model.inputType,
                    size:      sz,
                    col:       pos.col,
                    row:       pos.row
                })
            }
            if (page.length > 0) allPages.push(page)
            _pages = allPages
        }

        Connections {
            target: root
            function onSelectedCategoryIndexChanged() {
                Qt.callLater(topSection._buildPages)
            }
        }

        // ── Page indicator ───────────────────────────────────────────
        Row {
            id: indicatorRow
            anchors.top: categoryTitle.visible ? categoryTitle.bottom : parent.top
            anchors.topMargin: categoryTitle.visible ? 10 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            visible: topSection._pages.length > 1

            Repeater {
                model: topSection._pages.length
                delegate: Rectangle {
                    width:  pageView.currentIndex === index ? 20 : 8
                    height: 8
                    radius: 4
                    color: pageView.currentIndex === index
                           ? Style.currentStyle.accentPrimary
                           : Qt.rgba(1, 1, 1, 0.35)
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation   { duration: 200 } }
                }
            }
        }

        // ── Horizontal paged view ────────────────────────────────────
        ListView {
            id: pageView
            anchors.top: indicatorRow.bottom
            anchors.topMargin: indicatorRow.visible ? 10 : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true

            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            boundsBehavior: Flickable.StopAtBounds

            model: topSection._pages.length

            delegate: Item {
                id: pageDelegate
                width: pageView.width
                height: pageView.height

                property var pageItems: topSection._pages[index] ?? []

                // Grid canvas — exactly cols×rows tiles wide/tall, centered
                readonly property int gridW: topSection._gridCols * topSection._stride - 20
                readonly property int gridH: topSection._gridRows * topSection._stride - 20

                Item {
                    id: gridCanvas
                    width:  pageDelegate.gridW
                    height: pageDelegate.gridH
                    anchors.centerIn: parent

                    Repeater {
                        model: pageDelegate.pageItems.length
                        delegate: Item {
                            readonly property var svc: pageDelegate.pageItems[index]
                            readonly property bool is2x2: svc && svc.size === "2x2"

                            x: svc ? svc.col * topSection._stride : 0
                            y: svc ? svc.row * topSection._stride : 0
                            width:  is2x2 ? 420 : 200
                            height: is2x2 ? 420 : 200

                            Tile {
                                anchors.fill: parent
                                iconSource: root._serviceCategoryIconPath
                                label: svc ? svc.name : ""

                                onClicked: {
                                    if (svc) root.serviceSelected(svc.itemId, svc.name, svc.inputType)
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    // ── Bottom Section: Categories ListView ─────────────────────────
    Item {
        id: bottomSection
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 280 // 200 tile + 80 paddings

        // Top separator glow to divide Top Area from Bottom List
        Rectangle {
            anchors.top: parent.top
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

        Component {
            id: categoryDelegate
            Item {
                required property int itemId
                required property string name
                required property var index

                // Exclude "Top Services" (ID: 0) from the categories view by giving it 0 width
                width: itemId === 0 ? 0 : 200
                height: 200
                visible: itemId !== 0

                Tile {
                    anchors.fill: parent
                    tileColor: Style.currentStyle.categoryTileColor
                    
                    // Simple highlighting hint could be to fade slightly if currently selected
                    opacity: root.selectedCategoryId === parent.itemId ? 0.7 : 1.0
                    
                    iconSource: parent.itemId > 0 ? ("qrc:/qt/qml/app/assets/icons/" + parent.itemId + ".svg") : ""
                    label: parent.name

                    onClicked: {
                        root.selectedCategoryId = parent.itemId
                        root.selectedCategoryRow = parent.index
                        root.selectedCategoryIndex = ServiceTreeModel.index(parent.index, 0)
                        
                        autoScroll.stop()
                        idleTimer.restart()
                    }
                }
            }
        }

        Timer {
            id: idleTimer
            interval: 60000 // 1 minute after user interaction
            running: false
            repeat: false
            onTriggered: {
                if (categoriesList.singleSetWidth > 0) {
                    // Snap to beginning of middle set then animate infinitely
                    categoriesList.contentX = categoriesList.singleSetWidth
                    autoScroll.from = categoriesList.singleSetWidth
                    autoScroll.to = categoriesList.singleSetWidth * 2
                    autoScroll.restart()
                }
            }
        }

        NumberAnimation {
            id: autoScroll
            target: categoriesList
            property: "contentX"

            from: 0
            to: 0
            duration: 40000
            easing.type: Easing.Linear

            onFinished: {
                // Seamless infinite wrap: jump back one set, animate forward again
                if (categoriesList.singleSetWidth > 0) {
                    categoriesList.contentX = categoriesList.singleSetWidth
                    from = categoriesList.singleSetWidth
                    to = categoriesList.singleSetWidth * 2
                    restart()
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onPressed: function(mouse) {
                autoScroll.stop()
                idleTimer.restart() // restart 1-min countdown after interaction
                mouse.accepted = false
            }
        }

        Flickable {
            id: categoriesList
            anchors.fill: parent
            anchors.topMargin: 20
            clip: true
            
            contentWidth: rowLayout.width
            contentHeight: height

            property real singleSetWidth: 0
            property bool _hasCentered: false

            onMovementStarted: {
                autoScroll.stop()
                idleTimer.restart() // restart 1-min countdown after interaction
            }
            onFlickStarted: {
                autoScroll.stop()
                idleTimer.restart() // restart 1-min countdown after interaction
            }
            onMovementEnded: {
                // Invisible wrap-around when physics comes to rest 
                // Bounds the user perpetually in the middle Repeater instance
                if (singleSetWidth > 0) {
                    var cx = contentX
                    while (cx < singleSetWidth) cx += singleSetWidth
                    while (cx >= 2 * singleSetWidth) cx -= singleSetWidth
                    contentX = cx
                }
            }

            Row {
                id: rowLayout
                spacing: 20

                onWidthChanged: {
                    if (rep1.count > 0 && width > 0 && categoriesList.singleSetWidth === 0) {
                        var w = 0
                        for (var i = 0; i < rep1.count; ++i) {
                            var item = rep1.itemAt(i)
                            if (item && item.width > 0) {
                                w += item.width + rowLayout.spacing
                            }
                        }
                        categoriesList.singleSetWidth = w

                        if (!categoriesList._hasCentered && categoriesList.singleSetWidth > 0) {
                            categoriesList._hasCentered = true
                            // Start at the beginning of the middle set
                            categoriesList.contentX = categoriesList.singleSetWidth

                            // Immediately kick off infinite auto-scroll from element 0
                            autoScroll.from = categoriesList.singleSetWidth
                            autoScroll.to = categoriesList.singleSetWidth * 2
                            autoScroll.restart()
                        }
                    }
                }

                Repeater { id: rep1; model: ServiceTreeModel; delegate: categoryDelegate }
                Repeater { id: rep2; model: ServiceTreeModel; delegate: categoryDelegate }
                Repeater { id: rep3; model: ServiceTreeModel; delegate: categoryDelegate }
            }
        }
    }
}
