import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: compact

    property real itemSize: Math.min(compact.height, compact.width)
    property string icon

    signal widgetClicked

    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
        widgetClicked();
    }

    Item {
        id: container
        height: compact.itemSize
        width: compact.itemSize

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Math.min(parent.height, parent.width)
            height: width
            source: compact.icon
            active: compact.containsMouse
        }
    }
}
