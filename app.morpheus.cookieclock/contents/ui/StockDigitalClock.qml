/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2013 Martin Klapetek <mklapetek@kde.org>
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.private.digitalclock
import org.kde.kirigami as Kirigami
import org.kde.plasma.clock

MouseArea {
    id: main
    objectName: "digital-clock-compactrepresentation"

    required property var appletRoot

    property string timeFormat
    property string timeFormatWithSeconds

    // This is quite convoluted in Qt 6:
    // Qt.formatDate with locale only accepts Locale.FormatType as format type,
    // no Qt.DateFormat (ISODate) and no format string.
    // Locale.toString on the other hand only formats a date *with* time...
    readonly property var dateFormatter: {
        if (Plasmoid.configuration.digitalDateFormat === "custom") {
            Plasmoid.configuration.digitalCustomDateFormat; // create a binding dependency on this property.
            return (d) => {
                return Qt.locale().toString(d, Plasmoid.configuration.digitalCustomDateFormat);
            };
        } else if (Plasmoid.configuration.digitalDateFormat === "isoDate") {
            return (d) => {
                return Qt.formatDate(d, Qt.ISODate);
            };
        } else if (Plasmoid.configuration.digitalDateFormat === "longDate") {
            return (d) => {
                return Qt.formatDate(d, Qt.locale(), Locale.LongFormat);
            };
        } else {
            return (d) => {
                return Qt.formatDate(d, Qt.locale(), Locale.ShortFormat);
            };
        }
    }

    property string lastDate: ""
    property int tzOffset

    // This is the index in the list of user selected time zones
    property int tzIndex: 0

    // if showing the date and the time in one line or
    // if the date/time zone cannot be fit with the smallest font to its designated space
    readonly property bool oneLineMode: {
        if (Plasmoid.configuration.digitalDatePosition === 1) {
            // BesideTime
            return true;
        } else if (Plasmoid.configuration.digitalDatePosition === 2) {
            // BelowTime
            return false;
        } else {
            // Adaptive
            return Plasmoid.formFactor === PlasmaCore.Types.Horizontal &&
                height <= 2 * Kirigami.Theme.smallFont.pixelSize &&
                (Plasmoid.configuration.digitalShowDate || timeZoneLabel.visible);
        }
    }

    property bool wasExpanded
    property int wheelDelta: 0

    Accessible.role: Accessible.Button
    Accessible.onPressAction: clicked(null)

    Clock {
        id: clock
        timeZone: Plasmoid.configuration.digitalTimezone
        trackSeconds: Plasmoid.configuration.digitalShowSeconds == 2 // show seconds always
        onDateTimeChanged: main.dateTimeChanged()
        onTimeZoneChanged: main.setupLabels()
    }

    Connections {
        target: Plasmoid
        function onContextualActionsAboutToShow() {
            ClipboardMenu.secondsIncluded = (Plasmoid.configuration.digitalShowSeconds === 2);
            ClipboardMenu.timezone = clock.timeZone;
        }
    }

    Connections {
        target: Plasmoid.configuration
        function onDigitalSelectedTimeZonesChanged() {
            main.setupLabels();
            main.setTimeZoneIndex();
        }

        function onDigitalTimezoneFormatChanged() {
            main.setupLabels();
        }

        function onDigitalTimezoneChanged() {
            main.timeFormatCorrection();
        }

        function onDigitalShowTimezoneChanged() {
            main.timeFormatCorrection();
        }

        function onDigitalShowDateChanged() {
            main.timeFormatCorrection();
        }

        function onDigitalUse24hChanged() {
            main.timeFormatCorrection();
        }

        function onDigitalShowSecondsChanged() {
            main.setupLabels();
        }
    }

    function pointToPixel(pointSize: int): int {
        const pixelsPerInch = Screen.pixelDensity * 25.4
        return Math.round(pointSize / 72 * pixelsPerInch)
    }

    states: [
        State {
            name: "horizontalPanel"
            when: Plasmoid.formFactor === PlasmaCore.Types.Horizontal && !main.oneLineMode

            PropertyChanges {
                main.Layout.fillHeight: true
                main.Layout.fillWidth: false
                main.Layout.minimumWidth: contentItem.width
                main.Layout.maximumWidth: main.Layout.minimumWidth

                contentItem.height: timeLabel.height + (contentItem.Plasmoid.configuration.digitalShowDate || timeZoneLabel.visible ? 0.8 * timeLabel.height : 0)
                contentItem.width: Math.max(timeLabel.width + (contentItem.Plasmoid.configuration.digitalShowDate ? timeZoneLabel.paintedWidth : 0),
                                timeZoneLabel.paintedWidth, dateLabel.paintedWidth) + Kirigami.Units.largeSpacing

                labelsGrid.rows: labelsGrid.Plasmoid.configuration.digitalShowDate ? 1 : 2

                timeLabel.height: sizehelper.height
                timeLabel.width: sizehelper.contentWidth
                timeLabel.font.pixelSize: timeLabel.height

                timeZoneLabel.height: timeZoneLabel.Plasmoid.configuration.digitalShowDate ? 0.7 * timeLabel.height : 0.8 * timeLabel.height
                timeZoneLabel.width: timeZoneLabel.Plasmoid.configuration.digitalShowDate ? timeZoneLabel.paintedWidth : timeLabel.width
                timeZoneLabel.font.pixelSize: timeZoneLabel.height

                dateLabel.height: 0.8 * timeLabel.height
                dateLabel.width: dateLabel.paintedWidth
                dateLabel.verticalAlignment: Text.AlignVCenter
                dateLabel.font.pixelSize: dateLabel.height

                /*
                 * The value 0.71 was picked by testing to give the clock the right
                 * size (aligned with tray icons).
                 * Value 0.56 seems to be chosen rather arbitrary as well such that
                 * the time label is slightly larger than the date or time zone label
                 * and still fits well into the panel with all the applied margins.
                 */
                sizehelper.height: Math.min(timeZoneLabel.Plasmoid.configuration.digitalShowDate || timeZoneLabel.visible ? main.height * 0.56 : main.height * 0.71,
                                            fontHelper.font.pixelSize)

                sizehelper.font.pixelSize: sizehelper.height
            }

            AnchorChanges {
                target: labelsGrid

                anchors.horizontalCenter: contentItem.horizontalCenter
            }

            AnchorChanges {
                target: dateLabel

                anchors.top: labelsGrid.bottom
                anchors.horizontalCenter: labelsGrid.horizontalCenter
            }
        },

        State {
            name: "oneLineDate"
            // the one-line mode has no effect on a vertical panel because it would never fit
            when: Plasmoid.formFactor !== PlasmaCore.Types.Vertical && main.oneLineMode

            PropertyChanges {
                main.Layout.fillHeight: true
                main.Layout.fillWidth: false
                main.Layout.minimumWidth: contentItem.width
                main.Layout.maximumWidth: main.Layout.minimumWidth

                contentItem.height: sizehelper.height
                contentItem.width: (dateLabel.visible ? dateLabel.width + dateLabel.anchors.rightMargin : 0) + labelsGrid.width

                dateLabel.height: timeLabel.height
                dateLabel.width: dateLabel.paintedWidth

                dateLabel.font.pixelSize: 1024
                dateLabel.verticalAlignment: Text.AlignVCenter
                // between date and time; they are styled the same, so
                // a space is more appropriate than smallSpacing
                dateLabel.anchors.rightMargin: timeMetrics.advanceWidth(" ")
                dateLabel.fontSizeMode: Text.VerticalFit

                timeLabel.height: sizehelper.height
                timeLabel.width: sizehelper.contentWidth
                timeLabel.fontSizeMode: Text.VerticalFit

                timeZoneLabel.height: 0.7 * timeLabel.height
                timeZoneLabel.width: timeZoneLabel.paintedWidth
                timeZoneLabel.fontSizeMode: Text.VerticalFit
                timeZoneLabel.horizontalAlignment: Text.AlignHCenter

                sizehelper.height: Math.min(main.height, fontHelper.contentHeight)
                sizehelper.fontSizeMode: Text.VerticalFit
                sizehelper.font.pixelSize: fontHelper.font.pixelSize
            }

            AnchorChanges {
                target: labelsGrid

                anchors.right: contentItem.right
            }

            AnchorChanges {
                target: dateLabel

                anchors.right: labelsGrid.left
                anchors.verticalCenter: labelsGrid.verticalCenter
            }
        },

        State {
            name: "verticalPanel"
            when: Plasmoid.formFactor === PlasmaCore.Types.Vertical

            PropertyChanges {
                main.Layout.fillHeight: false
                main.Layout.fillWidth: true
                main.Layout.maximumHeight: contentItem.height
                main.Layout.minimumHeight: main.Layout.maximumHeight

                contentItem.height: contentItem.Plasmoid.configuration.digitalShowDate ? labelsGrid.height + dateLabel.contentHeight : labelsGrid.height
                contentItem.width: main.width

                labelsGrid.rows: 2

                timeLabel.height: sizehelper.contentHeight
                timeLabel.width: main.width
                timeLabel.font.pixelSize: Math.min(timeLabel.height, fontHelper.font.pixelSize)
                timeLabel.fontSizeMode: Text.Fit

                timeZoneLabel.height: Math.max(0.7 * timeLabel.height, dateLabel.minimumPixelSize)
                timeZoneLabel.width: main.width
                timeZoneLabel.fontSizeMode: Text.Fit
                timeZoneLabel.minimumPixelSize: dateLabel.minimumPixelSize
                timeZoneLabel.elide: Text.ElideRight

                dateLabel.width: main.width
                //NOTE: in order for Text.Fit to work as intended, the actual height needs to be quite big, in order for the font to enlarge as much it needs for the available width, and then request a sensible height, for which contentHeight will need to be considered as opposed to height
                dateLabel.height: Kirigami.Units.gridUnit * 10
                dateLabel.fontSizeMode: Text.Fit
                dateLabel.verticalAlignment: Text.AlignTop
                // Those magic numbers are purely what looks nice as maximum size, here we have it the smallest
                // between slightly bigger than the default font (1.4 times) and a bit smaller than the time font
                dateLabel.font.pixelSize: Math.min(0.7 * timeLabel.height, contentItem.Kirigami.Theme.defaultFont.pixelSize * 1.4)
                dateLabel.elide: Text.ElideRight
                dateLabel.wrapMode: Text.WordWrap

                sizehelper.width: main.width
                sizehelper.fontSizeMode: Text.HorizontalFit
                sizehelper.font.pixelSize: fontHelper.font.pixelSize
            }

            AnchorChanges {
                target: dateLabel

                anchors.top: labelsGrid.bottom
                anchors.horizontalCenter: labelsGrid.horizontalCenter
            }
        },

        State {
            name: "other"
            when: Plasmoid.formFactor !== PlasmaCore.Types.Vertical && Plasmoid.formFactor !== PlasmaCore.Types.Horizontal

            PropertyChanges {
                main.Layout.fillHeight: false
                main.Layout.fillWidth: false
                main.Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                main.Layout.minimumHeight: Kirigami.Units.gridUnit * 3

                contentItem.height: main.height
                contentItem.width: main.width

                labelsGrid.rows: 2

                timeLabel.height: sizehelper.height
                timeLabel.width: main.width
                timeLabel.fontSizeMode: Text.Fit

                timeZoneLabel.height: 0.7 * timeLabel.height
                timeZoneLabel.width: main.width
                timeZoneLabel.fontSizeMode: Text.Fit
                timeZoneLabel.minimumPixelSize: 1

                dateLabel.height: 0.7 * timeLabel.height
                dateLabel.font.pixelSize: 1024
                dateLabel.width: Math.max(timeLabel.contentWidth, Kirigami.Units.gridUnit * 3)
                dateLabel.verticalAlignment: Text.AlignVCenter
                dateLabel.fontSizeMode: Text.Fit
                dateLabel.minimumPixelSize: 1
                dateLabel.wrapMode: Text.WordWrap

                sizehelper.height: {
                    if (sizehelper.Plasmoid?.configuration.digitalShowDate) {
                        if (timeZoneLabel.visible) {
                            return 0.4 * main.height
                        }
                        return 0.56 * main.height
                    } else if (timeZoneLabel.visible) {
                        return 0.59 * main.height
                    }
                    return main.height
                }
                sizehelper.width: main.width
                sizehelper.fontSizeMode: Text.Fit
                sizehelper.font.pixelSize: 1024
            }

            AnchorChanges {
                target: dateLabel

                anchors.top: labelsGrid.bottom
                anchors.horizontalCenter: labelsGrid.horizontalCenter
            }
        }
    ]

    acceptedButtons: Qt.LeftButton
    onClicked: mouse => {
        if (Plasmoid.configuration.organizerEnabled && (!mouse || mouse.button === Qt.LeftButton))
            appletRoot.toggleOrganizer();
    }
    onWheel: wheel => {
        if (!Plasmoid.configuration.digitalWheelChangesTimezone) {
            return;
        }

        var delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x);
        var newIndex = tzIndex;
        wheelDelta += delta;
        // magic number 120 for common "one click"
        // See: https://doc.qt.io/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
        while (wheelDelta >= 120) {
            wheelDelta -= 120;
            newIndex--;
        }
        while (wheelDelta <= -120) {
            wheelDelta += 120;
            newIndex++;
        }

        if (newIndex >= Plasmoid.configuration.digitalSelectedTimeZones.length) {
            newIndex = 0;
        } else if (newIndex < 0) {
            newIndex = Plasmoid.configuration.digitalSelectedTimeZones.length - 1;
        }

        if (newIndex !== tzIndex) {
            Plasmoid.configuration.digitalTimezone = Plasmoid.configuration.digitalSelectedTimeZones[newIndex];
            tzIndex = newIndex;
        }
    }

    /*
     * Visible elements
     *
     */
    Rectangle {
        anchors.fill: parent
        anchors.margins: -Kirigami.Units.smallSpacing
        z: -1
        visible: appletRoot.clockBackgroundEnabled
        radius: Kirigami.Units.cornerRadius * 1.5
        color: appletRoot.effectiveClockBackgroundColor
        border.width: 1
        border.color: appletRoot.effectiveClockBorderColor
    }

    Item {
        id: contentItem
        anchors.verticalCenter: main.verticalCenter

        Grid {
            id: labelsGrid

            rows: 1
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter

            flow: Grid.TopToBottom
            // between time and timezone; timezone is styled differently, so
            // smallSpacing is more appropriate than a space
            columnSpacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label  {
                id: timeLabel
                color: appletRoot.effectiveDigitalTextColor

                font {
                    family: fontHelper.font.family
                    weight: fontHelper.font.weight
                    italic: fontHelper.font.italic
                    features: { "tnum": 1 }
                    pixelSize: 1024
                }
                minimumPixelSize: 1

                text: Qt.locale().toString(clock.dateTime, Plasmoid.configuration.digitalShowSeconds === 2 ? main.timeFormatWithSeconds : main.timeFormat)
                textFormat: Text.PlainText
                style: Plasmoid.configuration.digitalTextOutlineEnabled
                    ? Text.Outline : Text.Normal
                styleColor: Plasmoid.configuration.digitalTextOutlineColor
                layer.enabled: Plasmoid.configuration.digitalTextOutlineEnabled
                    && Plasmoid.configuration.digitalTextOutlineThickness > 1
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Plasmoid.configuration.digitalTextOutlineColor
                    shadowOpacity: 1.0
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 0
                    shadowBlur: Math.min(1.0, Plasmoid.configuration.digitalTextOutlineThickness / 10)
                    blurMax: Plasmoid.configuration.digitalTextOutlineThickness * 2
                    autoPaddingEnabled: true
                }

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                id: timeZoneLabel
                color: appletRoot.effectiveDigitalTextColor

                font.family: timeLabel.font.family
                font.weight: timeLabel.font.weight
                font.italic: timeLabel.font.italic
                font.pixelSize: 1024
                minimumPixelSize: 1

                visible: text.length > 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
                style: Plasmoid.configuration.digitalTextOutlineEnabled
                    ? Text.Outline : Text.Normal
                styleColor: Plasmoid.configuration.digitalTextOutlineColor
                layer.enabled: Plasmoid.configuration.digitalTextOutlineEnabled
                    && Plasmoid.configuration.digitalTextOutlineThickness > 1
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Plasmoid.configuration.digitalTextOutlineColor
                    shadowOpacity: 1.0
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 0
                    shadowBlur: Math.min(1.0, Plasmoid.configuration.digitalTextOutlineThickness / 10)
                    blurMax: Plasmoid.configuration.digitalTextOutlineThickness * 2
                    autoPaddingEnabled: true
                }
            }
        }

        PlasmaComponents.Label {
            id: dateLabel
            color: appletRoot.effectiveDigitalTextColor

            visible: Plasmoid.configuration.digitalShowDate

            font.family: timeLabel.font.family
            font.weight: timeLabel.font.weight
            font.italic: timeLabel.font.italic
            font.pixelSize: 1024
            minimumPixelSize: 1

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            style: Plasmoid.configuration.digitalTextOutlineEnabled
                ? Text.Outline : Text.Normal
            styleColor: Plasmoid.configuration.digitalTextOutlineColor
            layer.enabled: Plasmoid.configuration.digitalTextOutlineEnabled
                && Plasmoid.configuration.digitalTextOutlineThickness > 1
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Plasmoid.configuration.digitalTextOutlineColor
                shadowOpacity: 1.0
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowBlur: Math.min(1.0, Plasmoid.configuration.digitalTextOutlineThickness / 10)
                blurMax: Plasmoid.configuration.digitalTextOutlineThickness * 2
                autoPaddingEnabled: true
            }
        }
    }
    /*
     * end: Visible Elements
     *
     */

    PlasmaComponents.Label {
        id: sizehelper

        font.family: timeLabel.font.family
        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
        minimumPixelSize: 1

        visible: false
        textFormat: Text.PlainText
    }

    // To measure Label.height for maximum-sized font in VerticalFit mode
    PlasmaComponents.Label {
        id: fontHelper

        height: 1024

        font.family: (Plasmoid.configuration.digitalAutoFont || Plasmoid.configuration.digitalFontFamily.length === 0) ? Kirigami.Theme.defaultFont.family : Plasmoid.configuration.digitalFontFamily
        font.weight: Plasmoid.configuration.digitalAutoFont ? Kirigami.Theme.defaultFont.weight : Plasmoid.configuration.digitalFontWeight
        font.italic: Plasmoid.configuration.digitalAutoFont ? Kirigami.Theme.defaultFont.italic : Plasmoid.configuration.digitalItalic
        font.pixelSize: Plasmoid.configuration.digitalAutoFont ? 3 * Kirigami.Theme.defaultFont.pixelSize : main.pointToPixel(Plasmoid.configuration.digitalFontSize)
        fontSizeMode: Text.VerticalFit

        visible: false
        textFormat: Text.PlainText
    }

    FontMetrics {
        id: timeMetrics

        font.family: timeLabel.font.family
        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
    }

    // Qt's QLocale does not offer any modular time creating like Klocale did
    // eg. no "gimme time with seconds" or "gimme time without seconds and with time zone".
    // QLocale supports only two formats - Long and Short. Long is unusable in many situations
    // and Short does not provide seconds. So if seconds are enabled, we need to add it here.
    //
    // What happens here is that it looks for the delimiter between "h" and "m", takes it
    // and appends it after "mm" and then appends "ss" for the seconds.
    function timeFormatCorrection(timeFormatString = Qt.locale().timeFormat(Locale.ShortFormat)) {
        const regexp = /(hh*)(.+)(mm)/i
        const match = regexp.exec(timeFormatString);

        const hours = match[1];
        const delimiter = match[2];
        const minutes = match[3]
        const seconds = "ss";
        const amPm = "AP";
        const uses24hFormatByDefault = timeFormatString.toLowerCase().indexOf("ap") === -1;

        // because QLocale is incredibly stupid and does not convert 12h/24h clock format
        // when uppercase H is used for hours, needs to be h or hh, so toLowerCase()
        let result = hours.toLowerCase() + delimiter + minutes;

        let result_sec = result + delimiter + seconds;

        // add "AM/PM" either if the setting is the default and locale uses it OR if the user unchecked "use 24h format"
        if ((Plasmoid.configuration.digitalUse24h === Qt.PartiallyChecked && !uses24hFormatByDefault) || Plasmoid.configuration.digitalUse24h === Qt.Unchecked) {
            result += " " + amPm;
            result_sec += " " + amPm;
        }

        timeFormat = result;
        timeFormatWithSeconds = result_sec;
        setupLabels();
    }

    function setupLabels() {
        const showTimezone = Plasmoid.configuration.digitalShowTimezone
            || (Plasmoid.configuration.digitalTimezone !== "Local"
                && !clock.isSystemTimeZone);

        let timezoneString = "";

        if (showTimezone) {
            // format time zone as tz code, city or UTC offset
            switch (Plasmoid.configuration.digitalTimezoneFormat) {
            case 0: // Code
                timezoneString = clock.timeZoneCode;
                break;
            case 1: // City
                timezoneString = TimeZonesI18n.i18nCity(clock.timeZone);
                break;
            case 2: // Offset from UTC time
                timezoneString = clock.timeZoneOffset;
                break;
            }
            if ((Plasmoid.configuration.digitalShowDate || oneLineMode) && Plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
                timezoneString = `(${timezoneString})`;
            }
        }
        // an empty string clears the label and that makes it hidden
        timeZoneLabel.text = timezoneString;

        if (Plasmoid.configuration.digitalShowDate) {
            dateLabel.text = main.dateFormatter(clock.dateTime);
        } else {
            // clear it so it doesn't take space in the layout
            dateLabel.text = "";
        }

        // find widest character between 0 and 9
        let maximumWidthNumber = 0;
        let maximumAdvanceWidth = 0;
        for (let i = 0; i <= 9; i++) {
            const advanceWidth = timeMetrics.advanceWidth(i);
            if (advanceWidth > maximumAdvanceWidth) {
                maximumAdvanceWidth = advanceWidth;
                maximumWidthNumber = i;
            }
        }
        // replace all placeholders with the widest number (two digits)
        const format = (Plasmoid.configuration.digitalShowSeconds === 2 ? main.timeFormatWithSeconds : main.timeFormat).replace(/(h+|m+|s+)/g, "" + maximumWidthNumber + maximumWidthNumber); // make sure maximumWidthNumber is formatted as string
        // build the time string twice, once with an AM time and once with a PM time
        const date = new Date(2000, 0, 1, 1, 0, 0);
        const timeAm = Qt.formatTime(date, format);
        const advanceWidthAm = timeMetrics.advanceWidth(timeAm);
        date.setHours(13);
        const timePm = Qt.formatTime(date, format);
        const advanceWidthPm = timeMetrics.advanceWidth(timePm);
        // set the sizehelper's text to the widest time string
        if (advanceWidthAm > advanceWidthPm) {
            sizehelper.text = timeAm;
        } else {
            sizehelper.text = timePm;
        }
        fontHelper.text = sizehelper.text
    }

    function dateTimeChanged() {
        let doCorrections = false;

        if (Plasmoid.configuration.digitalShowDate) {
            // If the date has changed, force size recalculation, because the day name
            // or the month name can now be longer/shorter, so we need to adjust applet size
            const currentDate = Qt.formatDateTime(clock.dateTime, "yyyy-MM-dd");
            if (lastDate !== currentDate) {
                doCorrections = true;
                lastDate = currentDate
            }
        }

        if (doCorrections) {
            timeFormatCorrection();
        }
    }

    function setTimeZoneIndex() {
        tzIndex = Plasmoid.configuration.digitalSelectedTimeZones.indexOf(Plasmoid.configuration.digitalTimezone);
    }

    Component.onCompleted: {
        Plasmoid.configuration.digitalSelectedTimeZones = TimeZoneUtils.sortedTimeZones(Plasmoid.configuration.digitalSelectedTimeZones);

        setTimeZoneIndex();
        dateTimeChanged();
        timeFormatCorrection();

        dateFormatterChanged
            .connect(setupLabels);

        stateChanged
            .connect(setupLabels);
    }
}
