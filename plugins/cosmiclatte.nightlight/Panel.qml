import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.indicators"
  ipcTarget: ""
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")
  property int temperature: 4000
  property bool active: false

  function refreshTemperature() {
    if (!temperatureProbe.running) temperatureProbe.running = true
  }

  function setTemperature(value) {
    var temp = Number(value)
    if (!isFinite(temp) || temp < 2500 || temp > 6500) return
    var rounded = Math.round(temp / 100) * 100
    root.temperature = rounded
    root.active = rounded < 6000
    applyTemperatureProcess.command = rounded === 6500
      ? ["hyprctl", "hyprsunset", "identity"]
      : ["hyprctl", "hyprsunset", "temperature", String(rounded)]
    applyTemperatureProcess.running = true
  }

  Process {
    id: applyTemperatureProcess
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.refreshTemperature()
        return
      }
      if (root.hostWidget && typeof root.hostWidget.setNightlightState === "function")
        root.hostWidget.setNightlightState(root.active, root.temperature)
    }
  }

  Process {
    id: temperatureProbe
    command: ["hyprctl", "hyprsunset", "temperature"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var match = String(text).match(/[0-9]+/)
        if (match) {
          var current = Number(match[0])
          root.active = root.nightlightService ? root.nightlightService.enabled : current < 6000
          root.temperature = root.active ? current : 6500
          if (root.hostWidget && typeof root.hostWidget.setNightlightState === "function")
            root.hostWidget.setNightlightState(root.active, root.temperature)
        }
      }
    }
  }

  onOpenedChanged: if (opened) refreshTemperature()

  function closeForPopoutSwitch() {
    root.popoutSwitchClosing = true
    root.close()
    Qt.callLater(function() { root.popoutSwitchClosing = false })
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: controlsColumn.implicitHeight

      Component.onCompleted: keyCatcher.forceActiveFocus()

      ColumnLayout {
        id: controlsColumn
        anchors.fill: parent
        spacing: Style.space(14)

        RowLayout {
          Layout.fillWidth: true

          Text {
            text: "Night Light"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            Layout.fillWidth: true
          }

          Text {
            text: root.active ? "ON" : "OFF"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }
        }

        PanelSlider {
          id: temperatureSlider
          Layout.fillWidth: true
          bar: root.bar
          minimum: 2500
          maximum: 6500
          step: 100
          integer: true
          value: root.temperature
          onReleased: function(value) {
            root.setTemperature(value)
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Text {
            text: "Warmer"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
          Item { Layout.fillWidth: true }
          Text {
            text: root.temperature + " K"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
          Item { Layout.fillWidth: true }
          Text {
            text: "Cooler"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }
      }
    }
  }
}
