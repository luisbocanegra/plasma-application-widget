import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid

Item {
    id: root
    Layout.preferredWidth: Kirigami.Units.gridUnit * 25
    Layout.preferredHeight: Kirigami.Units.gridUnit * 25

    readonly property string socket: Plasmoid.configuration.socket || ("plasma-application-widget-" + Math.random().toString(36).substring(2, 10))
    property real scale: Plasmoid.configuration.unscaled ? Screen.devicePixelRatio : 1.0
    property string command: Plasmoid.configuration.command ? Plasmoid.configuration.command : null
    property bool allowinput: Plasmoid.configuration.allowInput
    property int fps: Plasmoid.configuration.fps

    property bool enabled: true

    property var toplevel: null // XdgToplevel
    property var process: null // QQmlPropertyMap

    function restartApplication() {
        stopApplication();
        restartTimer.start();
    }

    function stopApplication() {
        if (root.toplevel)
            root.toplevel.xdgSurface.surface.client.close();
        root.process = null;
        root.enabled = false;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Restart background application")
            icon.name: "system-reboot"
            onTriggered: {
                root.restartApplication();
            }
        },
        PlasmaCore.Action {
            text: i18n("Stop background application")
            icon.name: "process-stop-symbolic"
            enabled: root.enabled
            onTriggered: {
                root.stopApplication();
            }
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: !root.enabled
            PlasmaExtras.PlaceholderMessage {
                anchors.centerIn: parent
                anchors.margins: Kirigami.Units.gridUnit
                text: i18n("Application is not running")
                iconName: Plasmoid.icon || "window-symbolic"
                helpfulAction: QQC2.Action {
                    icon.name: "configure"
                    text: i18n("Restart background application")

                    onTriggered: {
                        root.restartApplication();
                    }
                }
            }
        }
        Kirigami.InlineMessage {
            type: Kirigami.MessageType.Warning
            text: i18n("No window to show.")
            Layout.fillWidth: true
            SequentialAnimation on visible {
                PropertyAnimation {
                    to: false
                    duration: 0
                }
                PropertyAnimation {
                    to: false
                    duration: 5000
                }
                PropertyAnimation {
                    to: true
                    duration: 0
                }
                running: root.enabled && !root.toplevel && !root.process
            }
        }

        Kirigami.InlineMessage {
            type: Kirigami.MessageType.Error
            Layout.fillWidth: true
            text: root.process ? (i18n("Process ended with exit code %1", root.process["exit code"]) + "\n\n" + root.process.stdout + root.process.stderr).trim() : ""
            visible: root.enabled && !root.toplevel && root.process
        }

        Kirigami.InlineMessage {
            type: Kirigami.MessageType.Error
            Layout.fillWidth: true
            text: i18n("Could not load the compositor. Is QtWayland.Compositor installed?")
            visible: wayland.status == Loader.Error
        }

        Loader {
            id: wayland
            source: "wayland.qml"
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: !!root.toplevel
        }

        Connections {
            target: wayland.item
            function onWidthChanged() {
                root.updateWindowSize();
            }
            function onHeightChanged() {
                root.updateWindowSize();
            }
        }

        Item {
            Layout.fillHeight: true
            visible: !root.toplevel && root.enabled
        }
    }

    function updateWindowSize() {
        if (toplevel)
            toplevel.sendFullscreen(Qt.size(wayland.width * root.scale, wayland.height * root.scale));
    }

    onCommandChanged: {
        if (toplevel)
            toplevel.xdgSurface.surface.client.close();
        process = null;
    }

    onScaleChanged: {
        restartApplication();
    }

    Timer {
        id: restartTimer
        running: false
        interval: 100
        onTriggered: {
            root.enabled = true;
        }
    }

    P5Support.DataSource {
        engine: 'executable'
        property string cmd: "QT_QPA_PLATFORM= QT_WAYLAND_SHELL_INTEGRATION= DISPLAY= WAYLAND_DISPLAY=" + socket + " " + command
        onCmdChanged: console.log(cmd)
        connectedSources: command && wayland.status == Loader.Ready && wayland.item.compositor.created && root.enabled ? [cmd] : []
        onNewData: (source, data) => {
            root.process = data;
        }
    }
}
