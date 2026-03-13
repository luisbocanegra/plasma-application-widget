import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.ksvg as KSvg
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_command: command.text
    property alias cfg_allowInput: allowInput.checked
    property alias cfg_unscaled: unscaled.checked
    property alias cfg_socket: socket.text
    property alias cfg_fps: fps.value
    property alias cfg_preferCompact: preferCompact.checked
    property string cfg_icon: Plasmoid.configuration.icon

    property string socketText: cfg_socket
    ColumnLayout {
        // anchors.fill: parent
        Kirigami.FormLayout {
            TextField {
                id: command
                Kirigami.FormData.label: i18n("Application to run:")
                placeholderText: i18n("Command")
            }

            CheckBox {
                id: preferCompact
                text: i18n("Compact")
            }

            SpinBox {
                id: fps
                Kirigami.FormData.label: i18n("FPS limit:")
                from: 0
                to: 9999999
                stepSize: 1
                live: true
                textFromValue: (value, locale) => value ? value : i18n("off")
                valueFromText: (text, locale) => text == i18n("off") ? 0 : Number.fromLocaleString(locale, text)
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Advanced settings:")
                CheckBox {
                    id: allowInput
                    text: i18n("Pass input events")
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Input events (pointer & keyboard) can only be passed through the desktop wallpaper. This option is ineffective on the screen locker.")
                }
            }

            CheckBox {
                id: unscaled
                text: i18n("Disable HiDPI scaling")
            }

            RowLayout {
                CheckBox {
                    id: customSocket
                    text: i18n("Use custom Wayland socket name")
                    onCheckedChanged: {
                        if (!checked) {
                            socketText = socket.text;
                            socket.text = "";
                        } else {
                            socket.text = socketText;
                        }
                    }
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Requires a reload to take effect. Don't use on the lock screen with multiple outputs.")
                }
            }

            TextField {
                id: socket
                placeholderText: i18n("Socket")
                visible: customSocket.checked
                onTextChanged: {
                    if (text) {
                        customSocket.checked = true;
                        socketText = text;
                    }
                }
                validator: RegularExpressionValidator {
                    regularExpression: /^[A-Za-z0-9._-]+$/
                }
            }

            Button {
                id: iconButton
                Kirigami.FormData.label: i18n("Icon:")
                implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
                implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
                hoverEnabled: true

                Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
                Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", root.cfg_icon)
                Accessible.role: Accessible.ButtonMenu

                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", root.cfg_icon)
                ToolTip.visible: iconButton.hovered && root.cfg_icon.length > 0

                KIconThemes.IconDialog {
                    id: iconDialog
                    onIconNameChanged: root.cfg_icon = iconName || "window-symbolic"
                }

                onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

                KSvg.FrameSvgItem {
                    id: previewFrame
                    anchors.centerIn: parent
                    imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal ? "widgets/panel-background" : "widgets/background"
                    width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                    height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Math.min(parent.height, parent.width)
                        height: width
                        source: root.cfg_icon
                    }
                }

                Menu {
                    id: iconMenu

                    // Appear below the button
                    y: +parent.height

                    MenuItem {
                        text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                        icon.name: "document-open-folder"
                        Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                        onClicked: iconDialog.open()
                    }
                    MenuItem {
                        text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                        icon.name: "edit-clear"
                        enabled: root.cfg_icon !== "window-symbolic"
                        onClicked: root.cfg_icon = "window-symbolic"
                    }
                }
            }
        }
    }
}
