pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "./components/" as Components

PlasmoidItem {
    id: main

    readonly property bool onDesktop: Plasmoid.location === PlasmaCore.Types.Floating
    readonly property bool preferCompact: Plasmoid.configuration.preferCompact
    Plasmoid.icon: Plasmoid.configuration.icon

    Component.onCompleted: {
        console.log("Component.onCompleted");
    }

    preferredRepresentation: preferCompact ? compactRepresentation : null

    property Component compactVew: CompactRepresentation {
        icon: Plasmoid.icon || "window-symbolic"
        onWidgetClicked: main.expanded = !main.expanded
    }
    property Component popupView: Components.PopupView {}
    compactRepresentation: compactVew
    fullRepresentation: popupView
}
