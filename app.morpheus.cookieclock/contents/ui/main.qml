import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.clock

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property date now: new Date()
    property date shownMonth: new Date(now.getFullYear(), now.getMonth(), 1)
    property int currentTab: 0
    property bool organizerPinned: false
    property bool organizerEnabled: true
    property bool organizerWasOpen: false
    property bool clockBackgroundEnabled: true
    property bool clockFollowPlasmaColors: true
    property color clockBackgroundColor: "#202124"
    property color clockBorderColor: "#3f444d"
    property color analogDialColor: "#f5f7fa"
    property color analogHourHandColor: "#3daee9"
    property color analogMinuteHandColor: "#2980b9"
    property color analogSecondHandColor: "#9b59b6"
    property color analogAccentColor: "#3daee9"
    property color analogAccentTextColor: "#ffffff"
    property color digitalTextColor: "#f5f7fa"
    readonly property color effectiveClockBackgroundColor: clockFollowPlasmaColors
        ? Kirigami.Theme.alternateBackgroundColor : clockBackgroundColor
    readonly property color effectiveClockBorderColor: clockFollowPlasmaColors
        ? Kirigami.Theme.separatorColor : clockBorderColor
    readonly property color effectiveAnalogDialColor: clockFollowPlasmaColors
        ? Kirigami.Theme.textColor : analogDialColor
    readonly property color effectiveAnalogHourHandColor: clockFollowPlasmaColors
        ? Kirigami.Theme.highlightColor : analogHourHandColor
    readonly property color effectiveAnalogMinuteHandColor: clockFollowPlasmaColors
        ? Kirigami.Theme.linkColor : analogMinuteHandColor
    readonly property color effectiveAnalogSecondHandColor: clockFollowPlasmaColors
        ? Kirigami.Theme.visitedLinkColor : analogSecondHandColor
    readonly property color effectiveAnalogAccentColor: clockFollowPlasmaColors
        ? Kirigami.Theme.highlightColor : analogAccentColor
    readonly property color effectiveAnalogAccentTextColor: clockFollowPlasmaColors
        ? Kirigami.Theme.highlightedTextColor : analogAccentTextColor
    readonly property color effectiveDigitalTextColor: clockFollowPlasmaColors
        ? Kirigami.Theme.textColor : digitalTextColor
    property var tasks: []
    property var worldClocks: []
    property int timerDurationMinutes: 25
    property int pomodoroSeconds: 25 * 60
    property bool pomodoroRunning: false
    property real clockScale: 1.0
    property int cookieSides: 14
    property string dialStyle: "full"
    property string hourHandStyle: "fill"
    property string minuteHandStyle: "medium"
    property string secondHandStyle: "dot"
    property string dateStyle: "bubble"
    property bool timeIndicators: true
    property bool hourMarks: false
    property bool constantlyRotate: false
    property int rotationSpeed: 61
    property bool useSineCookie: false
    property string clockStyle: "analog"
    property bool digitalShowDate: true
    property int digitalDatePosition: 0
    property int digitalShowSeconds: 1
    property int digitalUse24h: 1
    property string digitalDateFormat: "shortDate"
    property string digitalCustomDateFormat: "ddd d"
    property bool digitalShowTimezone: false
    property int digitalTimezoneFormat: 0
    property string digitalTimezone: "Local"
    property bool digitalAutoFont: true
    property string digitalFontFamily: ""
    property int digitalFontSize: 10
    property int digitalFontWeight: Font.Normal
    property bool digitalItalic: false

    preferredRepresentation: compactRepresentation
    hideOnWindowDeactivate: !organizerPinned
    toolTipMainText: Qt.formatDate(digitalClock.dateTime, "dddd, MMMM d, yyyy")
    toolTipSubText: {
        const zone = root.clockStyle === "digital" && root.digitalShowTimezone
            ? root.digitalTimezoneText() + ": " : ""
        const time = root.clockStyle === "digital"
            ? root.digitalTimeText(digitalClock.dateTime, true)
            : Qt.formatTime(root.now, "h:mm:ss AP")
        const action = root.organizerEnabled
            ? "\nClick to open Calendar, To-Do, Timer & World Clock" : ""
        return zone + time + action
    }
    // A desktop containment is large enough to select the full representation
    // automatically. Keep this applet in clock mode there; the organizer is
    // shown only when expanded by clicking the clock.
    switchWidth: 100000
    switchHeight: 100000

    function loadTasks() {
        try {
            const parsed = JSON.parse(Plasmoid.configuration.tasksJson || "[]")
            tasks = Array.isArray(parsed) ? parsed : []
        } catch (error) {
            tasks = []
        }
    }

    function loadWorldClocks() {
        try {
            const parsed = JSON.parse(Plasmoid.configuration.worldClocksJson || "[]")
            worldClocks = Array.isArray(parsed) ? parsed : []
        } catch (error) {
            worldClocks = []
        }
    }

    function refreshConfiguration() {
        clockBackgroundEnabled = Boolean(Plasmoid.configuration.clockBackgroundEnabled)
        clockFollowPlasmaColors = Boolean(Plasmoid.configuration.clockFollowPlasmaColors)
        clockBackgroundColor = Plasmoid.configuration.clockBackgroundColor
        clockBorderColor = Plasmoid.configuration.clockBorderColor
        analogDialColor = Plasmoid.configuration.analogDialColor
        analogHourHandColor = Plasmoid.configuration.analogHourHandColor
        analogMinuteHandColor = Plasmoid.configuration.analogMinuteHandColor
        analogSecondHandColor = Plasmoid.configuration.analogSecondHandColor
        analogAccentColor = Plasmoid.configuration.analogAccentColor
        analogAccentTextColor = Plasmoid.configuration.analogAccentTextColor
        digitalTextColor = Plasmoid.configuration.digitalTextColor
        clockScale = Number(Plasmoid.configuration.clockScale)
        cookieSides = Number(Plasmoid.configuration.cookieSides)
        dialStyle = String(Plasmoid.configuration.dialStyle)
        hourHandStyle = String(Plasmoid.configuration.hourHandStyle)
        minuteHandStyle = String(Plasmoid.configuration.minuteHandStyle)
        secondHandStyle = String(Plasmoid.configuration.secondHandStyle)
        dateStyle = String(Plasmoid.configuration.dateStyle)
        timeIndicators = Boolean(Plasmoid.configuration.timeIndicators)
        hourMarks = Boolean(Plasmoid.configuration.hourMarks)
        constantlyRotate = Boolean(Plasmoid.configuration.constantlyRotate)
        rotationSpeed = Math.max(1, Math.min(120, Number(Plasmoid.configuration.rotationSpeed)))
        useSineCookie = Boolean(Plasmoid.configuration.useSineCookie)
        organizerEnabled = Boolean(Plasmoid.configuration.organizerEnabled)
        clockStyle = String(Plasmoid.configuration.clockStyle)
        digitalShowDate = Boolean(Plasmoid.configuration.digitalShowDate)
        digitalDatePosition = Number(Plasmoid.configuration.digitalDatePosition)
        digitalShowSeconds = Number(Plasmoid.configuration.digitalShowSeconds)
        digitalUse24h = Number(Plasmoid.configuration.digitalUse24h)
        digitalDateFormat = String(Plasmoid.configuration.digitalDateFormat)
        digitalCustomDateFormat = String(Plasmoid.configuration.digitalCustomDateFormat)
        digitalShowTimezone = Boolean(Plasmoid.configuration.digitalShowTimezone)
        digitalTimezoneFormat = Number(Plasmoid.configuration.digitalTimezoneFormat)
        digitalTimezone = String(Plasmoid.configuration.digitalTimezone)
        digitalAutoFont = Boolean(Plasmoid.configuration.digitalAutoFont)
        digitalFontFamily = String(Plasmoid.configuration.digitalFontFamily)
        digitalFontSize = Number(Plasmoid.configuration.digitalFontSize)
        digitalFontWeight = Number(Plasmoid.configuration.digitalFontWeight)
        digitalItalic = Boolean(Plasmoid.configuration.digitalItalic)
        if (!organizerEnabled)
            expanded = false
    }

    function digitalTimeText(dateTime, forceSeconds) {
        const includeSeconds = forceSeconds || digitalShowSeconds === 2
        let format
        if (digitalUse24h === 0)
            format = includeSeconds ? "h:mm:ss AP" : "h:mm AP"
        else if (digitalUse24h === 2)
            format = includeSeconds ? "HH:mm:ss" : "HH:mm"
        else if (includeSeconds) {
            const localeFormat = Qt.locale().timeFormat(Locale.ShortFormat)
            const match = /(hh*)(.+)(mm)/i.exec(localeFormat)
            format = match ? match[1] + match[2] + match[3] + match[2] + "ss"
                + (localeFormat.toLowerCase().indexOf("ap") >= 0 ? " AP" : "") : "HH:mm:ss"
        } else
            format = Qt.locale().timeFormat(Locale.ShortFormat)
        return Qt.formatTime(dateTime, format)
    }

    function digitalDateText(dateTime) {
        if (digitalDateFormat === "custom")
            return Qt.locale().toString(dateTime, digitalCustomDateFormat)
        if (digitalDateFormat === "isoDate")
            return Qt.formatDate(dateTime, Qt.ISODate)
        if (digitalDateFormat === "longDate")
            return Qt.formatDate(dateTime, Qt.locale(), Locale.LongFormat)
        return Qt.formatDate(dateTime, Qt.locale(), Locale.ShortFormat)
    }

    function digitalTimezoneText() {
        if (!digitalShowTimezone)
            return ""
        if (digitalTimezoneFormat === 1) {
            const parts = digitalClock.timeZone.split("/")
            return parts[parts.length - 1].replace(/_/g, " ")
        }
        if (digitalTimezoneFormat === 2)
            return digitalClock.timeZoneOffset
        return digitalClock.timeZoneCode
    }

    function saveTasks() {
        Plasmoid.configuration.tasksJson = JSON.stringify(tasks)
    }

    function toggleOrganizer() {
        organizerCloseStateTimer.stop()
        if (!organizerEnabled)
            return
        if (organizerWasOpen) {
            organizerWasOpen = false
            expanded = false
        } else {
            organizerWasOpen = true
            expanded = true
        }
    }

    onExpandedChanged: {
        if (expanded) {
            organizerCloseStateTimer.stop()
            organizerWasOpen = true
        } else if (organizerWasOpen) {
            organizerCloseStateTimer.restart()
        }
    }

    Timer {
        id: organizerCloseStateTimer
        interval: 100
        repeat: false
        onTriggered: root.organizerWasOpen = false
    }

    function addTask(text) {
        const clean = text.trim()
        if (!clean.length)
            return
        const copy = tasks.slice()
        copy.push({ "content": clean, "done": false })
        tasks = copy
        saveTasks()
    }

    function toggleTask(index) {
        const copy = tasks.slice()
        copy[index] = { "content": copy[index].content, "done": !copy[index].done }
        tasks = copy
        saveTasks()
    }

    function deleteTask(index) {
        const copy = tasks.slice()
        copy.splice(index, 1)
        tasks = copy
        saveTasks()
    }

    Component.onCompleted: {
        refreshConfiguration()
        loadTasks()
        loadWorldClocks()
    }

    Connections {
        target: Plasmoid.configuration

        function onValueChanged(key, value) {
            root.refreshConfiguration()
            if (key === "tasksJson")
                root.loadTasks()
            else if (key === "worldClocksJson")
                root.loadWorldClocks()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }

    Clock {
        id: digitalClock
        timeZone: root.digitalTimezone
        trackSeconds: true
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.pomodoroRunning
        onTriggered: {
            if (root.pomodoroSeconds > 0)
                root.pomodoroSeconds--
            else
                root.pomodoroRunning = false
        }
    }

    component CookieRepresentation: MouseArea {
        id: cookieMouse
        implicitWidth: 236 * root.clockScale
        implicitHeight: 236 * root.clockScale
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.toggleOrganizer()
        }

        Item {
            id: cookie
            width: 224
            height: 224
            anchors.centerIn: parent
            scale: root.clockScale * (cookieMouse.containsMouse ? 1.025 : 1)

            Behavior on scale {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            Canvas {
                id: cookieFace
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    const ctx = getContext("2d")
                    const cx = width / 2
                    const cy = height / 2
                    const sides = Math.max(4, root.cookieSides)
                    const vertices = []
                    const rounding = 0.24
                    ctx.clearRect(0, 0, width, height)
                    if (root.useSineCookie) {
                        for (let i = 0; i < 180; ++i) {
                            const angle = Math.PI * 2 * i / 180
                            const radius = 98 + 8 * Math.sin(sides * angle + Math.PI / 2)
                            vertices.push({
                                "x": cx + radius * Math.cos(angle),
                                "y": cy + radius * Math.sin(angle)
                            })
                        }
                    } else {
                        for (let i = 0; i < sides * 2; ++i) {
                            const angle = Math.PI * 2 * i / (sides * 2) - Math.PI / 2 + Math.PI / 6
                            const radius = i % 2 === 0 ? 107 : 86
                            vertices.push({
                                "x": cx + radius * Math.cos(angle),
                                "y": cy + radius * Math.sin(angle)
                            })
                        }
                    }
                    ctx.beginPath()
                    for (let i = 0; i < vertices.length; ++i) {
                        const previous = vertices[(i + vertices.length - 1) % vertices.length]
                        const point = vertices[i]
                        const next = vertices[(i + 1) % vertices.length]
                        const beforeX = point.x + (previous.x - point.x) * rounding
                        const beforeY = point.y + (previous.y - point.y) * rounding
                        const afterX = point.x + (next.x - point.x) * rounding
                        const afterY = point.y + (next.y - point.y) * rounding
                        if (i === 0)
                            ctx.moveTo(beforeX, beforeY)
                        else
                            ctx.lineTo(beforeX, beforeY)
                        ctx.quadraticCurveTo(point.x, point.y, afterX, afterY)
                    }
                    ctx.closePath()
                    if (root.clockBackgroundEnabled) {
                        ctx.fillStyle = String(root.effectiveClockBackgroundColor)
                        ctx.fill()
                        ctx.lineWidth = 2
                        ctx.strokeStyle = String(root.effectiveClockBorderColor)
                        ctx.stroke()
                    }

                }

                rotation: 0

                RotationAnimation {
                    id: cookieRotation
                    target: cookieFace
                    property: "rotation"
                    from: 0
                    to: 360
                    duration: (121 - root.rotationSpeed) * 1000
                    loops: Animation.Infinite
                    direction: RotationAnimation.Clockwise
                    running: root.constantlyRotate
                    onRunningChanged: {
                        if (!running)
                            cookieFace.rotation = 0
                    }
                }
            }

            Canvas {
                id: dialMarks
                anchors.fill: parent
                z: 0.5
                visible: root.dialStyle === "full" || root.dialStyle === "dots"
                antialiasing: true
                onVisibleChanged: {
                    if (visible)
                        requestPaint()
                }

                onPaint: {
                    const ctx = getContext("2d")
                    const cx = width / 2
                    const cy = height / 2
                    ctx.clearRect(0, 0, width, height)

                    if (root.dialStyle === "full") {
                        for (let minute = 0; minute < 60; ++minute) {
                            const angle = Math.PI * 2 * minute / 60 - Math.PI / 2
                            const inner = minute % 5 === 0 ? 76 : 86
                            ctx.beginPath()
                            ctx.moveTo(cx + inner * Math.cos(angle), cy + inner * Math.sin(angle))
                            ctx.lineTo(cx + 94 * Math.cos(angle), cy + 94 * Math.sin(angle))
                            ctx.lineWidth = minute % 5 === 0 ? 4 : 2
                            ctx.lineCap = "round"
                            ctx.strokeStyle = String(root.effectiveAnalogDialColor)
                            ctx.stroke()
                        }
                    } else if (root.dialStyle === "dots") {
                        for (let hour = 0; hour < 12; ++hour) {
                            const angle = Math.PI * 2 * hour / 12 - Math.PI / 2
                            ctx.beginPath()
                            ctx.arc(cx + 86 * Math.cos(angle), cy + 86 * Math.sin(angle), 5, 0, Math.PI * 2)
                            ctx.fillStyle = String(root.effectiveAnalogDialColor)
                            ctx.fill()
                        }
                    }
                }
            }

            Connections {
                target: root
                function onCookieSidesChanged() { cookieFace.requestPaint() }
                function onDialStyleChanged() { dialMarks.requestPaint() }
                function onUseSineCookieChanged() { cookieFace.requestPaint() }
                function onRotationSpeedChanged() {
                    if (cookieRotation.running)
                        cookieRotation.restart()
                }
                function onClockBackgroundEnabledChanged() { cookieFace.requestPaint() }
                function onEffectiveClockBackgroundColorChanged() { cookieFace.requestPaint() }
                function onEffectiveClockBorderColorChanged() { cookieFace.requestPaint() }
                function onEffectiveAnalogDialColorChanged() { dialMarks.requestPaint() }
                function onEffectiveAnalogAccentColorChanged() { dateBubble.requestPaint() }
            }

            Repeater {
                model: root.dialStyle === "numbers" ? [3, 6, 9, 12] : []
                delegate: PlasmaComponents3.Label {
                    required property int modelData
                    property real angle: Math.PI * 2 * modelData / 12 - Math.PI / 2
                    x: parent.width / 2 + 82 * Math.cos(angle) - width / 2
                    y: parent.height / 2 + 82 * Math.sin(angle) - height / 2
                    text: modelData
                    color: root.effectiveAnalogDialColor
                    font.pixelSize: 22
                    font.weight: Font.Black
                }
            }

            Rectangle {
                visible: root.hourMarks
                width: 135
                height: 135
                radius: width / 2
                anchors.centerIn: parent
                color: root.effectiveAnalogDialColor
                opacity: 0.22

                Repeater {
                    model: 12
                    delegate: Item {
                        required property int index
                        anchors.fill: parent
                        rotation: 30 * index
                        Rectangle {
                            x: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 12
                            height: 4
                            radius: 2
                            color: root.effectiveClockBackgroundColor
                        }
                    }
                }

            }

            Rectangle {
                id: hourHand
                z: 2
                visible: root.hourHandStyle !== "hide"
                width: root.hourHandStyle === "classic" ? 8 : 20
                height: 72
                radius: root.hourHandStyle === "classic" ? 2 : 10
                color: root.hourHandStyle === "hollow" ? "transparent" : root.effectiveAnalogHourHandColor
                border.width: root.hourHandStyle === "hollow" ? 4 : 0
                border.color: root.effectiveAnalogHourHandColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom
                rotation: (root.now.getHours() % 12) * 30 + root.now.getMinutes() * 0.5

                Behavior on rotation { RotationAnimation { duration: 250; direction: RotationAnimation.Shortest } }
            }

            Rectangle {
                id: minuteHand
                z: 3
                visible: root.minuteHandStyle !== "hide"
                width: root.minuteHandStyle === "bold" ? 20
                    : root.minuteHandStyle === "medium" ? 12
                    : root.minuteHandStyle === "classic" ? 5 : 3
                height: 95
                radius: root.minuteHandStyle === "classic" ? 2 : width / 2
                color: root.effectiveAnalogMinuteHandColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom
                rotation: root.now.getMinutes() * 6 + root.now.getSeconds() * 0.1

                Behavior on rotation { RotationAnimation { duration: 250; direction: RotationAnimation.Shortest } }
            }

            Item {
                z: 4
                visible: root.secondHandStyle !== "hide"
                anchors.fill: parent
                rotation: root.now.getSeconds() * 6 + 90

                Rectangle {
                    width: root.secondHandStyle === "dot" ? 20 : 95
                    height: root.secondHandStyle === "dot" ? 20 : 2
                    radius: Math.min(width, height) / 2
                    x: root.secondHandStyle === "dot" ? 12 : 10
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.effectiveAnalogSecondHandColor
                }

                Rectangle {
                    visible: root.secondHandStyle === "classic"
                    width: 14
                    height: 14
                    radius: 7
                    x: 40
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.effectiveAnalogSecondHandColor
                }
            }

            Rectangle {
                z: 5
                width: 12
                height: 12
                radius: 6
                anchors.centerIn: parent
                color: root.effectiveAnalogAccentColor
                border.width: 2
                border.color: root.effectiveClockBackgroundColor
            }

            Column {
                z: 1
                visible: root.timeIndicators
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: -18
                opacity: 0.55

                Repeater {
                    model: [
                        Qt.formatTime(root.now, "hh"),
                        Qt.formatTime(root.now, "mm"),
                        Qt.formatTime(root.now, "AP")
                    ]
                    delegate: PlasmaComponents3.Label {
                        required property string modelData
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData
                        color: root.effectiveAnalogAccentColor
                        font.pixelSize: modelData.length > 2 ? 20 : 52
                        font.weight: Font.Black
                    }
                }

            }

            Canvas {
                id: dateBubble
                visible: root.dateStyle === "bubble"
                width: 64
                height: 64
                x: 4
                y: 4
                z: 6
                onVisibleChanged: {
                    if (visible)
                        requestPaint()
                }
                onPaint: {
                    const ctx = getContext("2d")
                    const cx = width / 2
                    const cy = height / 2
                    ctx.clearRect(0, 0, width, height)
                    ctx.beginPath()
                    for (let i = 0; i < 5; ++i) {
                        const angle = Math.PI * 2 * i / 5 - Math.PI / 2
                        const x = cx + 30 * Math.cos(angle)
                        const y = cy + 30 * Math.sin(angle)
                        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                    }
                    ctx.closePath()
                    ctx.fillStyle = String(root.effectiveAnalogAccentColor)
                    ctx.fill()
                }

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: Qt.formatDate(root.now, "d")
                    color: root.effectiveAnalogAccentTextColor
                    font.pixelSize: 28
                    font.weight: Font.Black
                }
            }

            Rectangle {
                visible: root.dateStyle === "bubble"
                width: 64
                height: 54
                radius: 27
                x: parent.width - width - 4
                y: parent.height - height - 4
                z: 6
                color: root.effectiveAnalogAccentColor

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: Qt.formatDate(root.now, "MM")
                    color: root.effectiveAnalogAccentTextColor
                    font.pixelSize: 27
                    font.weight: Font.Black
                }
            }

            Rectangle {
                visible: root.dateStyle === "rect"
                width: 48
                height: 32
                radius: Kirigami.Units.cornerRadius
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                color: root.effectiveAnalogAccentColor
                z: 6

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: Qt.formatDate(root.now, "dd")
                    color: root.effectiveAnalogAccentTextColor
                    font.weight: Font.Black
                }
            }

            PlasmaComponents3.Label {
                visible: root.dateStyle === "border"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                text: Qt.formatDate(root.now, "ddd dd")
                color: root.effectiveAnalogDialColor
                font.pixelSize: 18
                font.weight: Font.DemiBold
                z: 6
            }
        }

        PlasmaComponents3.ToolTip {
            text: root.organizerEnabled ? "Open Calendar, To-Do & Timer"
                : Qt.formatDateTime(root.now, "dddd, MMMM d, yyyy • h:mm:ss AP")
        }
    }

    component OrganizerView: Item {
        id: organizerView
        implicitWidth: 380
        implicitHeight: 460
        Layout.minimumWidth: 380
        Layout.minimumHeight: 460
        Layout.preferredWidth: 380
        Layout.preferredHeight: 460
        opacity: 1

        onVisibleChanged: {
            if (visible)
                fadeIn.restart()
        }

        Component.onCompleted: fadeIn.start()

        NumberAnimation {
            id: fadeIn
            target: organizerView
            property: "opacity"
            from: 0
            to: 1
            duration: 180
            easing.type: Easing.OutCubic
        }

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.cornerRadius * 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: [
                        { "label": "Calendar", "icon": "office-calendar" },
                        { "label": "To Do", "icon": "view-task" },
                        { "label": "Timer", "icon": "chronometer" },
                        { "label": "World", "icon": "globe" }
                    ]

                    delegate: PlasmaComponents3.ToolButton {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        text: modelData.label
                        icon.name: modelData.icon
                        checkable: true
                        checked: root.currentTab === index
                        onClicked: root.currentTab = index
                    }
                }

                PlasmaComponents3.ToolButton {
                    id: pinButton
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    icon.name: root.organizerPinned ? "window-unpin" : "window-pin"
                    display: QQC2.AbstractButton.IconOnly
                    checkable: true
                    checked: root.organizerPinned
                    onClicked: root.organizerPinned = checked

                    PlasmaComponents3.ToolTip {
                        text: root.organizerPinned
                            ? "Unpin and close when clicking elsewhere"
                            : "Keep organizer open"
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.currentTab === 0 ? calendarPage
                    : root.currentTab === 1 ? todoPage
                    : root.currentTab === 2 ? timerPage : worldClockPage
            }
        }
    }

    Component {
        id: calendarPage

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.shownMonth, "MMMM yyyy")
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.25
                    font.weight: Font.Medium
                }

                PlasmaComponents3.ToolButton {
                    icon.name: "go-previous-symbolic"
                    onClicked: root.shownMonth = new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth() - 1, 1)
                }
                PlasmaComponents3.ToolButton {
                    icon.name: "go-next-symbolic"
                    onClicked: root.shownMonth = new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth() + 1, 1)
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: Kirigami.Units.smallSpacing
                rowSpacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    delegate: PlasmaComponents3.Label {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 0.65
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                }

                Repeater {
                    model: 42
                    delegate: Rectangle {
                        required property int index
                        property int firstWeekday: {
                            const day = new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth(), 1).getDay()
                            return day === 0 ? 6 : day - 1
                        }
                        property int number: index - firstWeekday + 1
                        property int monthDays: new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth() + 1, 0).getDate()
                        property bool valid: number > 0 && number <= monthDays
                        property bool isToday: valid
                            && number === root.now.getDate()
                            && root.shownMonth.getMonth() === root.now.getMonth()
                            && root.shownMonth.getFullYear() === root.now.getFullYear()

                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.8
                        radius: height / 2
                        color: isToday ? Kirigami.Theme.highlightColor : "transparent"

                        PlasmaComponents3.Label {
                            anchors.centerIn: parent
                            text: parent.valid ? parent.number : ""
                            color: parent.isToday ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.weight: parent.isToday ? Font.DemiBold : Font.Normal
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(root.now, "dddd • MMMM d, yyyy • hh:mm:ss AP")
                opacity: 0.65
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            }
        }
    }

    Component {
        id: todoPage

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents3.TextField {
                    id: taskInput
                    Layout.fillWidth: true
                    placeholderText: "Add a task"
                    onAccepted: {
                        root.addTask(text)
                        text = ""
                    }
                }

                PlasmaComponents3.Button {
                    text: "Add"
                    enabled: taskInput.text.trim().length > 0
                    onClicked: {
                        root.addTask(taskInput.text)
                        taskInput.text = ""
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Kirigami.Units.smallSpacing
                model: root.tasks

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: taskRow.implicitHeight + Kirigami.Units.largeSpacing
                    radius: Kirigami.Units.cornerRadius
                    color: Kirigami.Theme.alternateBackgroundColor

                    RowLayout {
                        id: taskRow
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing

                        PlasmaComponents3.CheckBox {
                            checked: modelData.done
                            onClicked: root.toggleTask(index)
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: modelData.content
                            wrapMode: Text.Wrap
                            font.strikeout: modelData.done
                            opacity: modelData.done ? 0.55 : 1
                        }

                        PlasmaComponents3.ToolButton {
                            icon.name: "edit-delete-symbolic"
                            onClicked: root.deleteTask(index)
                        }
                    }
                }

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    visible: root.tasks.length === 0
                    text: "No pending tasks"
                    opacity: 0.65
                }
            }
        }
    }

    Component {
        id: timerPage

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    text: "Duration:"
                }

                QQC2.SpinBox {
                    id: durationSpin
                    from: 1
                    to: 240
                    value: root.timerDurationMinutes
                    editable: true
                    textFromValue: function(value) { return value + " min" }
                    valueFromText: function(text) {
                        const parsed = parseInt(text)
                        return isNaN(parsed) ? 25 : parsed
                    }
                    onValueModified: root.timerDurationMinutes = value
                }

                PlasmaComponents3.Button {
                    text: "Set"
                    onClicked: {
                        root.timerDurationMinutes = durationSpin.value
                        root.pomodoroRunning = false
                        root.pomodoroSeconds = durationSpin.value * 60
                    }
                }
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: {
                    const minutes = Math.floor(root.pomodoroSeconds / 60).toString().padStart(2, "0")
                    const seconds = (root.pomodoroSeconds % 60).toString().padStart(2, "0")
                    return minutes + ":" + seconds
                }
                font.pixelSize: 52
                font.weight: Font.Light
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.pomodoroSeconds === 0 ? "Session complete" : "Focus"
                opacity: 0.7
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                PlasmaComponents3.Button {
                    text: root.pomodoroRunning ? "Pause" : "Start"
                    enabled: root.pomodoroSeconds > 0
                    onClicked: root.pomodoroRunning = !root.pomodoroRunning
                }

                PlasmaComponents3.Button {
                    text: "Reset"
                    onClicked: {
                        root.pomodoroRunning = false
                        root.pomodoroSeconds = root.timerDurationMinutes * 60
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Component {
        id: worldClockPage

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            GridView {
                id: worldGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.worldClocks
                cellWidth: width / 2
                cellHeight: Kirigami.Units.gridUnit * 6.2

                delegate: Item {
                    required property var modelData
                    width: worldGrid.cellWidth
                    height: worldGrid.cellHeight

                    Clock {
                        id: cityClock
                        timeZone: modelData.zone
                        trackSeconds: false
                    }

                    Rectangle {
                        id: cityCard
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing / 2
                        radius: Kirigami.Units.cornerRadius * 1.5

                        readonly property bool isDarkTheme:
                            Kirigami.Theme.backgroundColor.hslLightness < 0.5
                        readonly property int localHour: cityClock.valid
                            ? cityClock.dateTime.getHours() : 12
                        readonly property bool isDay: localHour >= 6 && localHour < 18
                        readonly property color cardTextColor: isDay
                            ? (isDarkTheme ? "#f5f7fa" : "#20242a")
                            : "#f5f7fa"
                        readonly property color secondaryTextColor: isDay
                            ? (isDarkTheme ? "#c5cbd3" : "#5f6875")
                            : "#aeb7c4"

                        color: isDay
                            ? (isDarkTheme ? "#3a3f47" : "#f4f5f7")
                            : (isDarkTheme ? "#090b0f" : "#1b2028")
                        border.width: 1
                        border.color: isDay
                            ? (isDarkTheme ? "#505762" : "#d8dce2")
                            : (isDarkTheme ? "#1d222a" : "#303845")

                        Behavior on color {
                            ColorAnimation { duration: 250 }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.largeSpacing
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing / 2

                            RowLayout {
                                Layout.fillWidth: true

                                PlasmaComponents3.Label {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    color: cityCard.cardTextColor
                                    font.weight: Font.DemiBold
                                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.05
                                    elide: Text.ElideRight
                                }

                                Kirigami.Icon {
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                    source: cityCard.isDay ? "weather-clear" : "weather-clear-night"
                                    color: cityCard.isDay ? "#e7a928" : "#aeb9e8"
                                }
                            }

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: cityClock.valid
                                    ? Qt.formatTime(cityClock.dateTime, "h:mm AP") : "--:--"
                                color: cityCard.cardTextColor
                                font.weight: Font.Medium
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.45
                                elide: Text.ElideRight
                            }

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: cityClock.valid
                                    ? Qt.formatDate(cityClock.dateTime, "dddd, MMM d")
                                    : "Invalid time zone"
                                color: cityCard.secondaryTextColor
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    visible: root.worldClocks.length === 0
                    text: "Add a city to watch its local time"
                    opacity: 0.65
                }
            }
        }
    }

    compactRepresentation: Loader {
        sourceComponent: root.clockStyle === "digital" ? digitalRepresentationComponent : analogRepresentationComponent
        Layout.minimumWidth: item ? item.Layout.minimumWidth : 0
        Layout.minimumHeight: item ? item.Layout.minimumHeight : 0
        Layout.preferredWidth: item ? item.implicitWidth : 0
        Layout.preferredHeight: item ? item.implicitHeight : 0
        Layout.fillWidth: item ? item.Layout.fillWidth : false
        Layout.fillHeight: item ? item.Layout.fillHeight : false
    }

    Component {
        id: analogRepresentationComponent
        CookieRepresentation {}
    }

    Component {
        id: digitalRepresentationComponent
        StockDigitalClock {
            appletRoot: root
        }
    }

    fullRepresentation: OrganizerView {}
}
