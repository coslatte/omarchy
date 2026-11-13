import QtQuick
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")
  property var temperaturePanel: null

  active: nightlightService ? nightlightService.enabled : false
  activeText: "󰔎"
  inactiveText: "󰔎"
  activeTooltipText: I18n.t("bar.dayLight")
  inactiveTooltipText: I18n.t("bar.nightLight")

  function toggleTemperaturePanel() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.temperaturePanel = item
      item.bar = root.bar
      item.anchorItem = root
      item.hostWidget = root
    }
  }

  onPressed: function(button) {
    if (button === Qt.RightButton) root.toggleTemperaturePanel()
    else if (root.nightlightService) root.nightlightService.setNightlight(!root.active)
  }
}
