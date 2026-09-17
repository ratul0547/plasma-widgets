import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_refreshMinutes: refreshMinutes.value
    property alias cfg_reloadButtonEnabled: reloadButtonEnabled.checked
    property alias cfg_backgroundEnabled: backgroundEnabled.checked
    property alias cfg_quoteIconEnabled: quoteIconEnabled.checked
    property alias cfg_headerEnabled: headerEnabled.checked
    property alias cfg_headerText: headerText.text
    property alias cfg_headerIcon: headerIcon.text

    title: "General"

    ColumnLayout {
        width: page.availableWidth
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.SpinBox {
                id: refreshMinutes
                Kirigami.FormData.label: "Refresh interval:"
                from: 1
                to: 1440
                editable: true
                textFromValue: value => value + " min"
                valueFromText: text => Math.max(1, parseInt(text))
            }

            QQC2.CheckBox {
                id: reloadButtonEnabled
                Kirigami.FormData.label: "Reload control:"
                text: "Show reload button"
            }

            QQC2.Label {
                Kirigami.FormData.label: ""
                Layout.fillWidth: true
                text: "Double-clicking the widget always refreshes the fortune."
                wrapMode: Text.Wrap
                opacity: 0.65
            }

            QQC2.CheckBox {
                id: backgroundEnabled
                Kirigami.FormData.label: "Background:"
                text: "Show background"
            }

            QQC2.CheckBox {
                id: quoteIconEnabled
                Kirigami.FormData.label: "Quotation icon:"
                text: "Show quotation mark"
            }

            QQC2.CheckBox {
                id: headerEnabled
                Kirigami.FormData.label: "Constant header:"
                text: "Show header"
            }

            QQC2.TextField {
                id: headerText
                visible: headerEnabled.checked
                Kirigami.FormData.label: "Header text:"
                placeholderText: "Fortune Cookie"
            }

            RowLayout {
                visible: headerEnabled.checked
                Kirigami.FormData.label: "Header icon:"

                QQC2.TextField {
                    id: headerIcon
                    Layout.fillWidth: true
                    placeholderText: "Plasma icon name or local file"
                }

                QQC2.ToolButton {
                    icon.name: "document-open"
                    Accessible.name: "Choose icon file"
                    onClicked: iconFileDialog.open()
                }
            }

            QQC2.Label {
                visible: headerEnabled.checked
                Kirigami.FormData.label: ""
                Layout.fillWidth: true
                text: "The header always uses a 9 pt font. Plasma icon names and local image files are supported."
                wrapMode: Text.Wrap
                opacity: 0.65
            }
        }
    }

    FileDialog {
        id: iconFileDialog
        title: "Choose a header icon"
        nameFilters: ["Images (*.svg *.svgz *.png *.jpg *.jpeg *.webp)", "All files (*)"]
        onAccepted: headerIcon.text = selectedFile.toString()
    }
}
