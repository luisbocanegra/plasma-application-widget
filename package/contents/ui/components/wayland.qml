// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtWayland.Compositor
import QtWayland.Compositor.XdgShell

Item {
    property alias compositor: compositor
    property alias view: view

    WaylandCompositor {
        id: compositor
        socketName: socket

        XdgOutputManagerV1 {
            WaylandOutput {
                id: wl_output
                compositor: compositor
                window: Window {
                    width: root.width * scale
                    height: root.height * scale
                    visible: false
                }
                sizeFollowsWindow: true
                physicalSize: Qt.size(root.width * scale * Screen.devicePixelRatio / Screen.pixelDensity, root.height * scale * Screen.devicePixelRatio / Screen.pixelDensity)
                position: Qt.point(Screen.virtualX, Screen.virtualY)
                scaleFactor: Screen.devicePixelRatio / scale
                model: Screen.model
                manufacturer: Screen.manufacturer

                XdgOutputV1 {
                    name: Screen.name
                    logicalPosition: wl_output.position
                    logicalSize: Qt.size(wl_output.geometry.width / Screen.devicePixelRatio * scale, wl_output.geometry.height / Screen.devicePixelRatio * scale)
                }
            }
        }

        XdgDecorationManagerV1 {
            preferredMode: XdgToplevel.ServerSideDecoration
        }

        XdgShell {
            onToplevelCreated: (toplevel, xdgSurface) => {
                if (root.toplevel) {
                    toplevel.sendClose();
                    return;
                }
                toplevel.sendFullscreen(Qt.size(root.width * scale, root.height * scale));
                root.toplevel = toplevel;
            }
        }

        Component {
            id: timerComponent
            Timer {
                running: root.toplevel && root.fps
                interval: 1000.0 / root.fps
                repeat: true
            }
        }

        Component {
            id: fpsComponent
            Connections {
                target: root
                property WaylandSurface surface

                function onFpsChanged() {
                    surface.frameStarted();
                    surface.sendFrameCallbacks();
                }
            }
        }

        onSurfaceCreated: function (surface) {
            let timer = timerComponent.createObject(surface, {});
            timer.triggered.connect(function () {
                surface.frameStarted();
                surface.sendFrameCallbacks();
            });
            surface.redraw.connect(() => {
                if (!root.fps) {
                    surface.frameStarted();
                    surface.sendFrameCallbacks();
                }
            });
            fpsComponent.createObject(surface, {
                surface: surface
            });
        }
    }

    WaylandQuickItem {
        id: view
        anchors.fill: parent
        visible: root.toplevel && root.toplevel.fullscreen
        surface: root.toplevel ? root.toplevel.xdgSurface.surface : null
        inputEventsEnabled: allowinput
        output: wl_output
    }
}
