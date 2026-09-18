import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Desktop containments use top-level geometry when creating a new
    // instance. The representation's implicit size alone is not sufficient.
    width: Kirigami.Units.gridUnit * 24
    height: Kirigami.Units.gridUnit * 12

    property string quoteText: "Loading a fortune…"
    property string activeCommand: ""
    readonly property string command: buildFortuneCommand(Plasmoid.configuration.fortuneArguments)
    readonly property color effectiveBackgroundColor: Plasmoid.configuration.followPlasmaColors
        ? Kirigami.Theme.backgroundColor : Plasmoid.configuration.backgroundColor
    readonly property color effectiveBorderColor: Plasmoid.configuration.followPlasmaColors
        ? Kirigami.Theme.separatorColor : Plasmoid.configuration.borderColor
    readonly property color effectiveTextColor: Plasmoid.configuration.followPlasmaColors
        ? Kirigami.Theme.textColor : Plasmoid.configuration.textColor
    readonly property color effectiveQuoteIconColor: Plasmoid.configuration.followPlasmaColors
        ? Kirigami.Theme.highlightColor : Plasmoid.configuration.quoteIconColor
    readonly property color effectiveHeaderColor: Plasmoid.configuration.followPlasmaColors
        ? Kirigami.Theme.textColor : Plasmoid.configuration.headerColor

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function parseFortuneArguments(input) {
        const tokens = []
        let current = ""
        let quote = ""
        const text = String(input || "")

        for (let i = 0; i < text.length; ++i) {
            const character = text[i]
            if (quote.length > 0) {
                if (character === quote)
                    quote = ""
                else if (character === "\\" && i + 1 < text.length)
                    current += text[++i]
                else
                    current += character
            } else if (character === "\"" || character === "'") {
                quote = character
            } else if (/\s/.test(character)) {
                if (current.length > 0) {
                    tokens.push(current)
                    current = ""
                }
            } else {
                current += character
            }
        }

        if (current.length > 0)
            tokens.push(current)
        return tokens
    }

    function shellQuote(argument) {
        return "'" + String(argument).replace(/'/g, "'\\''") + "'"
    }

    function buildFortuneCommand(argumentsText) {
        const argumentsList = parseFortuneArguments(argumentsText)
        return argumentsList.length > 0
            ? "fortune " + argumentsList.map(shellQuote).join(" ")
            : "fortune"
    }

    function refresh() {
        if (activeCommand.length > 0)
            executable.disconnectSource(activeCommand)
        activeCommand = command
        executable.connectSource(activeCommand)
    }

    Component.onCompleted: refresh()

    Connections {
        target: Plasmoid.configuration
        function onFortuneArgumentsChanged() { root.refresh() }
    }

    Timer {
        interval: Math.max(1, Plasmoid.configuration.refreshMinutes) * 60 * 1000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"

        onNewData: function(sourceName, data) {
            const output = String(data["stdout"] || "").trim()
            if (output.length > 0)
                root.quoteText = output
            else if (Number(data["exit code"]) !== 0)
                root.quoteText = "Install fortune-mod to show quotes."
            disconnectSource(sourceName)
        }
    }

    fullRepresentation: MouseArea {
        implicitWidth: Kirigami.Units.gridUnit * 24
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 5,
                                 contentLayout.implicitHeight + Kirigami.Units.gridUnit * 2)
        clip: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onDoubleClicked: root.refresh()

        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.cornerRadius * 2
            visible: Plasmoid.configuration.backgroundEnabled
            color: root.effectiveBackgroundColor
            border.width: 1
            border.color: root.effectiveBorderColor
        }

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing * 1.5
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                visible: Plasmoid.configuration.headerEnabled
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    visible: Plasmoid.configuration.headerIcon.length > 0
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    source: Plasmoid.configuration.headerIcon
                    color: root.effectiveHeaderColor
                }

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: Plasmoid.configuration.headerText
                    color: root.effectiveHeaderColor
                    font.pointSize: 9
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                PlasmaComponents3.ToolButton {
                    visible: Plasmoid.configuration.reloadButtonEnabled
                    icon.name: "view-refresh-symbolic"
                    onClicked: root.refresh()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                spacing: Kirigami.Units.largeSpacing

                PlasmaComponents3.Label {
                    visible: Plasmoid.configuration.quoteIconEnabled
                    Layout.alignment: Qt.AlignTop
                    text: "“"
                    color: root.effectiveQuoteIconColor
                    font.family: Plasmoid.configuration.fontFamily
                    font.pixelSize: 36
                }

                PlasmaComponents3.Label {
                    id: quoteLabel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 0
                    text: root.quoteText
                    color: root.effectiveTextColor
                    style: Plasmoid.configuration.textOutlineEnabled
                        ? Text.Outline : Text.Normal
                    styleColor: Plasmoid.configuration.textOutlineColor
                    wrapMode: Text.Wrap
                    font.family: Plasmoid.configuration.fontFamily
                    font.pointSize: Plasmoid.configuration.fontSize
                    font.letterSpacing: Plasmoid.configuration.letterSpacing
                    fontSizeMode: Plasmoid.configuration.adaptiveFontSize
                        ? Text.Fit : Text.FixedSize
                    minimumPointSize: Math.min(Plasmoid.configuration.minimumFontSize,
                                               Plasmoid.configuration.fontSize)
                    lineHeightMode: Text.ProportionalHeight
                    lineHeight: Plasmoid.configuration.lineSpacing / 100
                    verticalAlignment: Text.AlignVCenter
                    clip: true
                }

                PlasmaComponents3.ToolButton {
                    visible: !Plasmoid.configuration.headerEnabled
                        && Plasmoid.configuration.reloadButtonEnabled
                    Layout.alignment: Qt.AlignTop
                    icon.name: "view-refresh-symbolic"
                    onClicked: root.refresh()
                }
            }
        }
    }
}
