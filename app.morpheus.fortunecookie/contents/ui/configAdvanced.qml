import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_fortuneArguments: fortuneArguments.text

    title: "Advanced"

    ColumnLayout {
        width: page.availableWidth
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            RowLayout {
                Kirigami.FormData.label: "Command:"

                QQC2.Label {
                    text: "fortune"
                    font.family: "monospace"
                    font.bold: true
                }

                QQC2.TextField {
                    id: fortuneArguments
                    Layout.fillWidth: true
                    placeholderText: "-s"
                    font.family: "monospace"
                }
            }

            QQC2.Label {
                Kirigami.FormData.label: "Examples:"
                Layout.fillWidth: true
                text: "-s  •  -l  •  -n 160  •  -a"
                wrapMode: Text.Wrap
                opacity: 0.7
            }

            QQC2.Label {
                Kirigami.FormData.label: ""
                Layout.fillWidth: true
                text: "Arguments are individually shell-quoted. Use matching single or double quotes to keep spaces inside one argument."
                wrapMode: Text.Wrap
                opacity: 0.65
            }
        }
    }
}
