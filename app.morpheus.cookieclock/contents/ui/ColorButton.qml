import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

RowLayout {
    id: control

    property color colorValue: "#ffffff"
    signal colorSelected(color value)

    spacing: Kirigami.Units.smallSpacing
    implicitWidth: swatchBox.implicitWidth + spacing + hexField.implicitWidth
    implicitHeight: Math.max(swatchBox.implicitHeight, hexField.implicitHeight)

    onColorValueChanged: {
        if (!hexField.activeFocus)
            hexField.text = colorValue.toString().toUpperCase()
    }

    Component.onCompleted: hexField.text = colorValue.toString().toUpperCase()

    Rectangle {
        id: swatchBox
        implicitWidth: hexField.implicitHeight
        implicitHeight: hexField.implicitHeight
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Kirigami.Theme.separatorColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            radius: Kirigami.Units.cornerRadius / 2
            color: control.colorValue
        }

        QQC2.ToolTip {
            visible: swatchMouse.containsMouse
            text: "Choose color"
        }

        MouseArea {
            id: swatchMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: colorDialog.open()
        }
    }

    QQC2.TextField {
        id: hexField
        implicitWidth: Kirigami.Units.gridUnit * 8
        selectByMouse: true
        placeholderText: "#RRGGBB or #AARRGGBB"
        validator: RegularExpressionValidator {
            regularExpression: /^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$/
        }
        onEditingFinished: {
            if (acceptableInput)
                control.colorSelected(text)
            else
                text = control.colorValue.toString().toUpperCase()
        }
    }

    ColorDialog {
        id: colorDialog
        title: "Choose a color"
        options: ColorDialog.ShowAlphaChannel
        selectedColor: control.colorValue
        onAccepted: {
            hexField.text = selectedColor.toString().toUpperCase()
            control.colorSelected(selectedColor)
        }
    }
}
