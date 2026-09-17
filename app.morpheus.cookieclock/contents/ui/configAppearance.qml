import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page
    property string cfg_clockStyle: "analog"
    property alias cfg_clockBackgroundEnabled: clockBackgroundEnabled.checked
    property alias cfg_clockFollowPlasmaColors: clockFollowPlasmaColors.checked
    property string cfg_clockBackgroundColor: "#202124"
    property string cfg_clockBorderColor: "#3f444d"
    property string cfg_analogDialColor: "#f5f7fa"
    property string cfg_analogHourHandColor: "#3daee9"
    property string cfg_analogMinuteHandColor: "#2980b9"
    property string cfg_analogSecondHandColor: "#9b59b6"
    property string cfg_analogAccentColor: "#3daee9"
    property string cfg_analogAccentTextColor: "#ffffff"
    property string cfg_digitalTextColor: "#f5f7fa"
    property alias cfg_digitalTextOutlineEnabled: digitalTextOutlineEnabled.checked
    property string cfg_digitalTextOutlineColor: "#000000"
    property alias cfg_digitalTextOutlineThickness: digitalTextOutlineThickness.value

    readonly property bool analog: cfg_clockStyle === "analog"
    readonly property bool digital: !analog

    QQC2.CheckBox {
        id: clockBackgroundEnabled
        Kirigami.FormData.label: "Background:"
        text: "Show clock background"
    }
    QQC2.CheckBox {
        id: clockFollowPlasmaColors
        Kirigami.FormData.label: "Color scheme:"
        text: "Follow Plasma color scheme"
    }
    ColorButton {
        visible: clockBackgroundEnabled.checked && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Background color:"
        colorValue: page.cfg_clockBackgroundColor
        onColorSelected: value => page.cfg_clockBackgroundColor = value.toString()
    }
    ColorButton {
        visible: clockBackgroundEnabled.checked && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Border color:"
        colorValue: page.cfg_clockBorderColor
        onColorSelected: value => page.cfg_clockBorderColor = value.toString()
    }

    Kirigami.Separator {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.isSection: true
    }

    ColorButton {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Dial marks/numbers:"
        colorValue: page.cfg_analogDialColor
        onColorSelected: value => page.cfg_analogDialColor = value.toString()
    }
    ColorButton {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Hour hand:"
        colorValue: page.cfg_analogHourHandColor
        onColorSelected: value => page.cfg_analogHourHandColor = value.toString()
    }
    ColorButton {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Minute hand:"
        colorValue: page.cfg_analogMinuteHandColor
        onColorSelected: value => page.cfg_analogMinuteHandColor = value.toString()
    }
    ColorButton {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Second hand:"
        colorValue: page.cfg_analogSecondHandColor
        onColorSelected: value => page.cfg_analogSecondHandColor = value.toString()
    }
    ColorButton {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Center/date accent:"
        colorValue: page.cfg_analogAccentColor
        onColorSelected: value => page.cfg_analogAccentColor = value.toString()
    }
    ColorButton {
        visible: page.analog && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Date badge text:"
        colorValue: page.cfg_analogAccentTextColor
        onColorSelected: value => page.cfg_analogAccentTextColor = value.toString()
    }

    ColorButton {
        visible: page.digital && !clockFollowPlasmaColors.checked
        Kirigami.FormData.label: "Text color:"
        colorValue: page.cfg_digitalTextColor
        onColorSelected: value => page.cfg_digitalTextColor = value.toString()
    }

    Kirigami.Separator {
        visible: page.digital
        Kirigami.FormData.isSection: true
    }

    QQC2.CheckBox {
        id: digitalTextOutlineEnabled
        visible: page.digital
        Kirigami.FormData.label: "Text outline:"
        text: "Outline text"
    }

    ColorButton {
        visible: page.digital && digitalTextOutlineEnabled.checked
        Kirigami.FormData.label: "Outline color:"
        colorValue: page.cfg_digitalTextOutlineColor
        onColorSelected: value => page.cfg_digitalTextOutlineColor = value.toString()
    }

    QQC2.SpinBox {
        id: digitalTextOutlineThickness
        visible: page.digital && digitalTextOutlineEnabled.checked
        Kirigami.FormData.label: "Outline thickness:"
        from: 1
        to: 8
        editable: true
        textFromValue: value => value + " px"
        valueFromText: text => parseInt(text)
    }
}
