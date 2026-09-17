import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt.labs.platform as Platform
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property string cfg_clockStyle: "analog"
    property alias cfg_organizerEnabled: organizerEnabled.checked
    property real cfg_clockScale: 1.0
    property alias cfg_cookieSides: sidesSpin.value
    property string cfg_dialStyle: "full"
    property string cfg_hourHandStyle: "fill"
    property string cfg_minuteHandStyle: "medium"
    property string cfg_secondHandStyle: "dot"
    property string cfg_dateStyle: "bubble"
    property alias cfg_timeIndicators: timeIndicators.checked
    property alias cfg_hourMarks: hourMarks.checked
    property alias cfg_constantlyRotate: constantlyRotate.checked
    property alias cfg_rotationSpeed: rotationSpeed.value
    property alias cfg_useSineCookie: sineCookie.checked

    property alias cfg_digitalShowDate: digitalShowDate.checked
    property alias cfg_digitalDatePosition: digitalDatePosition.currentIndex
    property alias cfg_digitalShowSeconds: digitalShowSeconds.currentIndex
    property alias cfg_digitalUse24h: digitalUse24h.currentIndex
    property string cfg_digitalDateFormat: "shortDate"
    property alias cfg_digitalCustomDateFormat: digitalCustomDateFormat.text
    property alias cfg_digitalShowTimezone: digitalShowTimezone.checked
    property alias cfg_digitalTimezoneFormat: digitalTimezoneFormat.currentIndex
    property alias cfg_digitalTimezone: digitalTimezone.text
    property alias cfg_digitalAutoFont: digitalAutoFont.checked
    property string cfg_digitalFontFamily: ""
    property int cfg_digitalFontSize: 10
    property int cfg_digitalFontWeight: 400
    property bool cfg_digitalItalic: false

    readonly property bool analog: cfg_clockStyle === "analog"
    readonly property bool digital: !analog

    QQC2.ComboBox {
        Kirigami.FormData.label: "Clock style:"
        model: ["Analog", "Digital"]
        currentIndex: page.analog ? 0 : 1
        onActivated: page.cfg_clockStyle = currentIndex === 0 ? "analog" : "digital"
    }

    QQC2.CheckBox {
        id: organizerEnabled
        Kirigami.FormData.label: "Organizer:"
        text: "Open Calendar, To-Do, Timer & World Clock when clicked"
    }
    Kirigami.Separator { Kirigami.FormData.isSection: true }

    QQC2.SpinBox {
        id: scaleSpin
        visible: page.analog
        Kirigami.FormData.label: "Scale:"
        from: 50; to: 200; stepSize: 5; editable: true
        textFromValue: value => value + "%"
        valueFromText: text => parseInt(text)
        value: Math.round(page.cfg_clockScale * 100)
        onValueModified: page.cfg_clockScale = value / 100
    }
    QQC2.SpinBox {
        id: sidesSpin
        visible: page.analog
        Kirigami.FormData.label: "Cookie sides:"
        from: 4; to: 32; editable: true
    }
    QQC2.ComboBox {
        visible: page.analog
        Kirigami.FormData.label: "Dial marks:"
        model: ["Full", "Dots", "Numbers", "None"]
        currentIndex: Math.max(0, ["full", "dots", "numbers", "none"].indexOf(page.cfg_dialStyle))
        onActivated: page.cfg_dialStyle = ["full", "dots", "numbers", "none"][currentIndex]
    }
    QQC2.ComboBox {
        visible: page.analog
        Kirigami.FormData.label: "Hour hand:"
        model: ["Filled", "Hollow", "Classic", "Hidden"]
        currentIndex: Math.max(0, ["fill", "hollow", "classic", "hide"].indexOf(page.cfg_hourHandStyle))
        onActivated: page.cfg_hourHandStyle = ["fill", "hollow", "classic", "hide"][currentIndex]
    }
    QQC2.ComboBox {
        visible: page.analog
        Kirigami.FormData.label: "Minute hand:"
        model: ["Bold", "Medium", "Thin", "Classic", "Hidden"]
        currentIndex: Math.max(0, ["bold", "medium", "thin", "classic", "hide"].indexOf(page.cfg_minuteHandStyle))
        onActivated: page.cfg_minuteHandStyle = ["bold", "medium", "thin", "classic", "hide"][currentIndex]
    }
    QQC2.ComboBox {
        visible: page.analog
        Kirigami.FormData.label: "Second hand:"
        model: ["Dot", "Classic", "Line", "Hidden"]
        currentIndex: Math.max(0, ["dot", "classic", "line", "hide"].indexOf(page.cfg_secondHandStyle))
        onActivated: page.cfg_secondHandStyle = ["dot", "classic", "line", "hide"][currentIndex]
    }
    QQC2.ComboBox {
        visible: page.analog
        Kirigami.FormData.label: "Date indicator:"
        model: ["Bubbles", "Rectangle", "Border", "Hidden"]
        currentIndex: Math.max(0, ["bubble", "rect", "border", "hide"].indexOf(page.cfg_dateStyle))
        onActivated: page.cfg_dateStyle = ["bubble", "rect", "border", "hide"][currentIndex]
    }
    QQC2.CheckBox {
        id: timeIndicators
        visible: page.analog
        Kirigami.FormData.label: "Details:"
        text: "Show time indicators"
    }
    QQC2.CheckBox { id: hourMarks; visible: page.analog; text: "Show inner hour marks" }
    QQC2.CheckBox { id: sineCookie; visible: page.analog; text: "Use sine-cookie shape" }
    QQC2.CheckBox { id: constantlyRotate; visible: page.analog; text: "Continuously rotate cookie" }
    QQC2.SpinBox {
        id: rotationSpeed
        visible: page.analog && constantlyRotate.checked
        Kirigami.FormData.label: "Rotation speed:"
        from: 1; to: 120; editable: true
        valueFromText: text => parseInt(text)
    }

    QQC2.CheckBox {
        id: digitalShowDate
        visible: page.digital
        Kirigami.FormData.label: "Information:"
        text: "Show date"
    }
    QQC2.ComboBox {
        id: digitalDatePosition
        visible: page.digital && digitalShowDate.checked
        Kirigami.FormData.label: "Date position:"
        model: ["Adaptive", "Beside time", "Below time"]
    }
    QQC2.ComboBox {
        id: digitalShowSeconds
        visible: page.digital
        Kirigami.FormData.label: "Show seconds:"
        model: ["Never", "Only in tooltip", "Always"]
    }
    QQC2.ComboBox {
        id: digitalUse24h
        visible: page.digital
        Kirigami.FormData.label: "Time display:"
        model: ["12-hour", "Use region defaults", "24-hour"]
    }
    QQC2.ComboBox {
        id: digitalDateFormat
        visible: page.digital && digitalShowDate.checked
        Kirigami.FormData.label: "Date format:"
        model: ["Long date", "Short date", "ISO date", "Custom"]
        currentIndex: Math.max(0, ["longDate", "shortDate", "isoDate", "custom"].indexOf(page.cfg_digitalDateFormat))
        onActivated: page.cfg_digitalDateFormat = ["longDate", "shortDate", "isoDate", "custom"][currentIndex]
    }
    QQC2.TextField {
        id: digitalCustomDateFormat
        visible: page.digital && digitalShowDate.checked && page.cfg_digitalDateFormat === "custom"
        Kirigami.FormData.label: "Custom format:"
        placeholderText: "ddd d"
    }
    QQC2.CheckBox {
        id: digitalShowTimezone
        visible: page.digital
        Kirigami.FormData.label: "Time zone:"
        text: "Show time-zone label"
    }
    QQC2.TextField {
        id: digitalTimezone
        visible: page.digital
        Kirigami.FormData.label: "Time-zone ID:"
        placeholderText: "Local or America/Chicago"
    }
    QQC2.ComboBox {
        id: digitalTimezoneFormat
        visible: page.digital && digitalShowTimezone.checked
        Kirigami.FormData.label: "Display time zone as:"
        model: ["Code", "City", "UTC offset"]
    }
    QQC2.CheckBox {
        id: digitalAutoFont
        visible: page.digital
        Kirigami.FormData.label: "Text display:"
        text: "Automatic font and size"
    }
    RowLayout {
        visible: page.digital && !digitalAutoFont.checked
        Kirigami.FormData.label: "Font:"
        QQC2.Button {
            text: "Choose Font…"
            icon.name: "preferences-desktop-font"
            onClicked: {
                digitalFontDialog.currentFont = digitalFontPreview.font
                digitalFontDialog.open()
            }
        }
        QQC2.Label {
            Layout.fillWidth: true
            text: {
                const family = page.cfg_digitalFontFamily.length > 0
                    ? page.cfg_digitalFontFamily : Kirigami.Theme.defaultFont.family
                return family + " · " + page.cfg_digitalFontSize + " pt"
                    + (page.cfg_digitalItalic ? " · Italic" : "")
            }
            font.family: page.cfg_digitalFontFamily.length > 0
                ? page.cfg_digitalFontFamily : Kirigami.Theme.defaultFont.family
            elide: Text.ElideRight
        }
    }
    Text {
        id: digitalFontPreview
        visible: false
        font.family: page.cfg_digitalFontFamily.length > 0
            ? page.cfg_digitalFontFamily : Kirigami.Theme.defaultFont.family
        font.pointSize: page.cfg_digitalFontSize
        font.weight: page.cfg_digitalFontWeight
        font.italic: page.cfg_digitalItalic
    }
    Platform.FontDialog {
        id: digitalFontDialog
        title: "Choose Digital Clock Font"
        modality: Qt.WindowModal
        parentWindow: page.Window.window
        onAccepted: {
            page.cfg_digitalFontFamily = font.family
            if (font.pointSize > 0)
                page.cfg_digitalFontSize = Math.round(font.pointSize)
            page.cfg_digitalFontWeight = font.weight
            page.cfg_digitalItalic = font.italic
        }
    }
}
