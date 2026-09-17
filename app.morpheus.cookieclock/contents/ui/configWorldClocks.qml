import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.clock
import org.kde.plasma.private.digitalclock

Kirigami.ScrollablePage {
    id: page

    property string cfg_worldClocksJson: "[]"
    property var clocks: []
    property bool loading: false
    property string selectedZone: ""
    property string selectedCity: ""

    title: "World Clock"

    function loadClocks() {
        loading = true
        try {
            const parsed = JSON.parse(cfg_worldClocksJson || "[]")
            clocks = Array.isArray(parsed) ? parsed : []
        } catch (error) {
            clocks = []
        }
        loading = false
    }

    function saveClocks() {
        if (!loading)
            cfg_worldClocksJson = JSON.stringify(clocks)
    }

    function addClock() {
        if (!selectedCity.length || !selectedZone.length)
            return
        for (let i = 0; i < clocks.length; ++i) {
            if (clocks[i].zone === selectedZone)
                return
        }
        const copy = clocks.slice()
        copy.push({ "label": selectedCity, "zone": selectedZone })
        clocks = copy
        saveClocks()
        selectedCity = ""
        selectedZone = ""
        zoneSearch.text = ""
    }

    function removeClock(index) {
        const copy = clocks.slice()
        copy.splice(index, 1)
        clocks = copy
        saveClocks()
    }

    onCfg_worldClocksJsonChanged: loadClocks()
    Component.onCompleted: loadClocks()

    ColumnLayout {
        width: page.availableWidth
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            RowLayout {
                Kirigami.FormData.label: "Add city:"

                QQC2.TextField {
                    id: zoneSearch
                    Layout.fillWidth: true
                    placeholderText: "Search cities and regions…"
                    selectByMouse: true
                    onTextEdited: {
                        page.selectedCity = ""
                        page.selectedZone = ""
                        zonePopup.open()
                    }
                }

                QQC2.ToolButton {
                    icon.name: zonePopup.opened ? "arrow-up" : "arrow-down"
                    onClicked: zonePopup.opened ? zonePopup.close() : zonePopup.open()
                    Accessible.name: "Show time zones"
                }

                QQC2.Popup {
                    id: zonePopup
                    parent: zoneSearch
                    x: 0
                    y: zoneSearch.height
                    width: Math.max(zoneSearch.width + Kirigami.Units.gridUnit * 3,
                                    Kirigami.Units.gridUnit * 18)
                    height: Kirigami.Units.gridUnit * 16
                    padding: Kirigami.Units.smallSpacing
                    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

                    contentItem: ListView {
                        id: zoneResults
                        clip: true
                        model: TimeZoneFilterProxy {
                            sourceModel: TimeZoneModel {}
                            filterString: zoneSearch.text
                        }

                        delegate: QQC2.ItemDelegate {
                            required property var model
                            width: ListView.view.width
                            text: model.city
                            highlighted: model.timeZoneId === page.selectedZone

                            contentItem: Kirigami.TitleSubtitle {
                                title: model.city
                                subtitle: model.region + "  •  " + model.timeZoneId
                            }

                            onClicked: {
                                page.selectedCity = model.city
                                page.selectedZone = model.timeZoneId
                                zoneSearch.text = model.city + " — " + model.timeZoneId
                                zonePopup.close()
                            }
                        }
                    }
                }
            }

            QQC2.Button {
                Kirigami.FormData.label: ""
                text: "Add city"
                icon.name: "list-add"
                enabled: page.selectedZone.length > 0
                onClicked: page.addClock()
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.Heading {
            text: "Saved cities"
            level: 2
        }

        Repeater {
            model: page.clocks

            delegate: Kirigami.AbstractCard {
                required property var modelData
                required property int index
                Layout.fillWidth: true

                Clock {
                    id: previewClock
                    timeZone: modelData.zone
                    trackSeconds: true
                }

                contentItem: RowLayout {
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: modelData.label
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: previewClock.valid ? modelData.zone : "Invalid time-zone ID"
                            color: previewClock.valid
                                ? Kirigami.Theme.disabledTextColor
                                : Kirigami.Theme.negativeTextColor
                            elide: Text.ElideRight
                        }
                    }

                    ColumnLayout {
                        spacing: 0

                        QQC2.Label {
                            Layout.alignment: Qt.AlignRight
                            text: previewClock.valid
                                ? Qt.formatTime(previewClock.dateTime, "h:mm:ss AP") : "--:--"
                            font.bold: true
                        }

                        QQC2.Label {
                            Layout.alignment: Qt.AlignRight
                            text: previewClock.valid
                                ? Qt.formatDate(previewClock.dateTime, "ddd, MMM d") : ""
                            opacity: 0.65
                        }
                    }

                    QQC2.ToolButton {
                        icon.name: "edit-delete-symbolic"
                        onClicked: page.removeClock(index)
                        QQC2.ToolTip.text: "Remove city"
                        QQC2.ToolTip.visible: hovered
                    }
                }
            }
        }

        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            visible: page.clocks.length === 0
            text: "No cities added yet"
            opacity: 0.65
        }
    }
}
