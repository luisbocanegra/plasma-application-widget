pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels
import org.kde.plasma.plasma5support as Plasma5Support

Kirigami.SearchDialog {
    id: dialog

    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
    emptyText: i18n("No applications found.")

    implicitWidth: Kirigami.Units.gridUnit * 36
    implicitHeight: Kirigami.Units.gridUnit * 24

    signal applicationSelected(desktopEntry: string, name: string, icon: string)

    Plasma5Support.DataSource {
        id: appSource
        engine: "apps"
        connectedSources: sources
    }

    Plasma5Support.DataModel {
        id: dataModel
        dataSource: appSource
    }

    model: KSortFilterProxyModel {
        id: shortcutsListFiltered
        sourceModel: dataModel
        filterRoleName: "name"
        sortRoleName: "name"
        filterRowCallback: sourceRow => {
            const rowData = sourceModel.get(sourceRow);
            if (!rowData) {
                return false;
            }
            return rowData.isApp && rowData.display && (rowData.name || "").toLowerCase().includes(dialog.text.toLowerCase());
        }
    }
    onTextChanged: {
        shortcutsListFiltered.setFilterWildcard(text);
    }
    delegate: ItemDelegate {
        width: ListView.view.width
        required property int index
        required property string name
        required property string comment
        required property string genericName
        required property string entryPath
        required property string iconName
        text: name + " - " + (comment || genericName)
        icon.name: iconName
        onClicked: {
            dialog.applicationSelected(entryPath, name, iconName);
            dialog.close();
        }
    }
}
