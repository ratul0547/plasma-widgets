import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt.labs.platform as Platform
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_followPlasmaColors: followPlasmaColors.checked
    property string cfg_backgroundColor: "#202124"
    property string cfg_borderColor: "#3f444d"
    property string cfg_textColor: "#f5f7fa"
    property alias cfg_textOutlineEnabled: textOutlineEnabled.checked
    property string cfg_textOutlineColor: "#000000"
    property string cfg_quoteIconColor: "#3daee9"
    property string cfg_headerColor: "#f5f7fa"
    property string cfg_fontFamily: "Noto Serif"
    property alias cfg_fontSize: maximumFontSize.value
    property alias cfg_adaptiveFontSize: adaptiveFontSize.checked
    property alias cfg_minimumFontSize: minimumFontSize.value
    property alias cfg_lineSpacing: lineSpacing.value
    property real cfg_letterSpacing: 0.0

    title: "Appearance"

    ColumnLayout {
        width: page.availableWidth
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.CheckBox {
                id: followPlasmaColors
                Kirigami.FormData.label: "Color scheme:"
                text: "Follow Plasma color scheme"
            }

            ColorButton {
                visible: !followPlasmaColors.checked
                Kirigami.FormData.label: "Background color:"
                colorValue: page.cfg_backgroundColor
                onColorSelected: value => page.cfg_backgroundColor = value.toString()
            }

            ColorButton {
                visible: !followPlasmaColors.checked
                Kirigami.FormData.label: "Border color:"
                colorValue: page.cfg_borderColor
                onColorSelected: value => page.cfg_borderColor = value.toString()
            }

            ColorButton {
                visible: !followPlasmaColors.checked
                Kirigami.FormData.label: "Text color:"
                colorValue: page.cfg_textColor
                onColorSelected: value => page.cfg_textColor = value.toString()
            }

            ColorButton {
                visible: !followPlasmaColors.checked
                Kirigami.FormData.label: "Quotation color:"
                colorValue: page.cfg_quoteIconColor
                onColorSelected: value => page.cfg_quoteIconColor = value.toString()
            }

            ColorButton {
                visible: !followPlasmaColors.checked
                Kirigami.FormData.label: "Header color:"
                colorValue: page.cfg_headerColor
                onColorSelected: value => page.cfg_headerColor = value.toString()
            }

            QQC2.CheckBox {
                id: textOutlineEnabled
                Kirigami.FormData.label: "Text outline:"
                text: "Outline quote text"
            }

            ColorButton {
                visible: textOutlineEnabled.checked
                Kirigami.FormData.label: "Outline color:"
                colorValue: page.cfg_textOutlineColor
                onColorSelected: value => page.cfg_textOutlineColor = value.toString()
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            RowLayout {
                Kirigami.FormData.label: "Quote font:"

                QQC2.Button {
                    text: "Choose Font…"
                    icon.name: "preferences-desktop-font"
                    onClicked: {
                        fontDialog.currentFont = fontPreview.font
                        fontDialog.open()
                    }
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: page.cfg_fontFamily
                    font.family: page.cfg_fontFamily
                    elide: Text.ElideRight
                }
            }

            QQC2.CheckBox {
                id: adaptiveFontSize
                Kirigami.FormData.label: "Long fortunes:"
                text: "Shrink text to fit the widget"
            }

            RowLayout {
                Kirigami.FormData.label: adaptiveFontSize.checked
                    ? "Maximum font size:" : "Font size:"

                QQC2.SpinBox {
                    id: maximumFontSize
                    from: 5
                    to: 72
                    editable: true
                    textFromValue: value => value + " pt"
                    valueFromText: text => parseInt(text)
                    onValueModified: {
                        if (adaptiveFontSize.checked && value < minimumFontSize.value)
                            minimumFontSize.value = value
                    }
                }
            }

            QQC2.SpinBox {
                id: minimumFontSize
                visible: adaptiveFontSize.checked
                Kirigami.FormData.label: "Minimum font size:"
                from: 5
                to: 72
                editable: true
                textFromValue: value => value + " pt"
                valueFromText: text => parseInt(text)
                onValueModified: {
                    if (value > maximumFontSize.value)
                        maximumFontSize.value = value
                }
            }

            QQC2.SpinBox {
                id: lineSpacing
                Kirigami.FormData.label: "Line spacing:"
                from: 75
                to: 250
                stepSize: 5
                editable: true
                textFromValue: value => value + "%"
                valueFromText: text => parseInt(text)
            }

            QQC2.SpinBox {
                id: letterSpacing
                Kirigami.FormData.label: "Letter spacing:"
                from: -20
                to: 100
                stepSize: 5
                value: Math.round(page.cfg_letterSpacing * 10)
                editable: true
                textFromValue: value => (value / 10).toFixed(1) + " px"
                valueFromText: text => Math.round(parseFloat(text) * 10)
                onValueModified: page.cfg_letterSpacing = value / 10
            }

        }
    }

    Text {
        id: fontPreview
        visible: false
        font.family: page.cfg_fontFamily
        font.pointSize: page.cfg_fontSize
    }

    Platform.FontDialog {
        id: fontDialog
        title: "Choose Quote Font"
        modality: Qt.WindowModal
        parentWindow: page.Window.window
        onAccepted: page.cfg_fontFamily = font.family
    }
}
