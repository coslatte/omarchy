import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "cosmiclatte.nightlight"

  readonly property int temperature: panelLoader.item ? panelLoader.item.temperature : 6500
  readonly property bool active: temperature < 6000
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing : false

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function toggle() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }
  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
    panelLoader.item.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("NightlightPopup.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  ShellIpc {
    target: "cosmiclatte.nightlight"
    function press(which: string): void { button.triggerPress(which === "right" ? Qt.RightButton : Qt.LeftButton) }
    function status(): string { return JSON.stringify({opened: root.opened, temperature: root.temperature}) }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰔎"
    tooltipText: root.active ? "Night Light · " + root.temperature + " K" : "Night Light off"
    onPressed: function(b) {
      if (b === Qt.RightButton) root.toggle()
      else if (b === Qt.LeftButton && panelLoader.item) panelLoader.item.toggleNightlight()
    }
  }
}
