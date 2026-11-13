import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// 2026-11-10 11:51: solicitud: mantener operativo el botón del panel tras cambiar ajustes.
BarWidget {
  id: root
  moduleName: "cosmiclatte.glass"

  property string mode: "auto"
  property bool glassy: false
  property int blurSize: 7
  property real glassOpacity: 0.88
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function applyState(nextMode, nextGlassy, nextBlurSize, nextOpacity) {
    mode = nextMode
    glassy = nextGlassy
    blurSize = nextBlurSize
    glassOpacity = nextOpacity
  }
  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function openPanel() { open() }
  function toggle() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }
  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
    panelLoader.item.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  onBarChanged: injectPanel()

  ShellIpc {
    target: "cosmiclatte.glass"
    function press(which: string): void { button.triggerPress(which === "right" ? Qt.RightButton : Qt.LeftButton) }
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function status(): string {
      return JSON.stringify({ opened: root.opened, mode: root.mode, glassy: root.glassy, blurSize: root.blurSize, opacity: root.glassOpacity })
    }
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰂵"
    active: root.glassy
    activeColor: Commons.Color.accent
    tooltipText: strings.t("tooltip").arg(strings.t(root.glassy ? "status.on" : "status.off"))
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.toggle()
    }
  }
}
