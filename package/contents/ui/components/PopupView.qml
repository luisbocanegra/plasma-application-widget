import QtQuick
import org.kde.plasma.plasmoid
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

Item {
    id: root
    Layout.minimumWidth: Kirigami.Units.gridUnit * 25
    Layout.minimumHeight: Kirigami.Units.gridUnit * 25
    Layout.preferredWidth: Kirigami.Units.gridUnit * 25
    Layout.preferredHeight: Kirigami.Units.gridUnit * 25

    readonly property string socket: Plasmoid.configuration.socket || ("plasma-wallpaper-application-" + Math.random().toString(36).substring(2, 10))
    property real scale: Plasmoid.configuration.unscaled ? Screen.devicePixelRatio : 1.0
    property string command: Plasmoid.configuration.command ? Plasmoid.configuration.command : null
    property bool allowinput: Plasmoid.configuration.allowInput
    property int fps: Plasmoid.configuration.fps

    property bool enabled: true

    property var toplevel: null // XdgToplevel
    property var process: null // QQmlPropertyMap

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Restart background application")
            icon.name: "system-reboot"
            enabled: root.enabled
            onTriggered: {
                if (root.toplevel)
                    root.toplevel.xdgSurface.surface.client.close();
                root.enabled = false;
            }
        }
    ]

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Kirigami.InlineMessage {
        type: Kirigami.MessageType.Warning
        text: i18n("No window to show.")
        width: 200
        anchors.centerIn: parent
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
        width: 500
        text: root.process ? (i18n("Process ended with exit code %1", root.process["exit code"]) + "\n\n" + root.process.stdout + root.process.stderr).trim() : ""
        anchors.centerIn: parent
        visible: root.enabled && !root.toplevel && root.process
    }

    Kirigami.InlineMessage {
        type: Kirigami.MessageType.Error
        width: 500
        text: i18n("Could not load the compositor. Is QtWayland.Compositor installed?")
        anchors.centerIn: parent
        visible: wayland.status == Loader.Error
    }

    Loader {
        id: wayland
        source: "wayland.qml"
        anchors.fill: parent
    }

    onWidthChanged: {
        if (toplevel)
            toplevel.sendFullscreen(Qt.size(root.width * scale, root.height * scale));
    }

    onHeightChanged: {
        if (toplevel)
            toplevel.sendFullscreen(Qt.size(root.width * scale, root.height * scale));
    }

    onCommandChanged: {
        if (toplevel)
            toplevel.xdgSurface.surface.client.close();
        process = null;
    }

    onScaleChanged: {
        if (toplevel)
            toplevel.xdgSurface.surface.client.close();
        enabled = false;
    }

    Timer {
        interval: 100
        running: !enabled
        onTriggered: {
            root.process = null;
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
