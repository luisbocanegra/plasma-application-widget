pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid
import "./components/" as Components

PlasmoidItem {
    id: main

    readonly property bool onDesktop: Plasmoid.location === PlasmaCore.Types.Floating
    readonly property bool preferCompact: Plasmoid.configuration.preferCompact

    Component.onCompleted: {
        console.log("Component.onCompleted");
    }

    preferredRepresentation: preferCompact ? compactRepresentation : null

    property Component compactVew: CompactRepresentation {
        icon: "window-symbolic"
        onWidgetClicked: main.expanded = !main.expanded
    }
    property Component popupView: Components.PopupView {}
    compactRepresentation: compactVew
    fullRepresentation: popupView
}
