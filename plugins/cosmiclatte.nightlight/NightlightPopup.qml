import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui as Ui

Ui.Panel {
  id: root
  moduleName: "cosmiclatte.nightlight"
  ipcTarget: ""
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property int temperature: 6500
  property bool active: false

  function refreshTemperature() {
    if (!temperatureProbe.running) temperatureProbe.running = true
  }

  property int pendingTemperature: -1
  property string failure: ""

  function toggleNightlight() {
    if (!toggleProcess.running && !applyTemperatureProcess.running) toggleProcess.running = true
  }

  function setTemperature(value) {
    var temp = Number(value)
    if (!isFinite(temp) || temp < 2500 || temp > 6500) return
    pendingTemperature = Math.round(temp / 100) * 100
    applyPending()
  }

  function applyPending() {
    if (applyTemperatureProcess.running || pendingTemperature < 0) return
    var temp = pendingTemperature
    pendingTemperature = -1
    temperature = temp
    failure = ""
    applyTemperatureProcess.command = ["bash", Qt.resolvedUrl("apply-temperature").toString().replace(/^file:\/\//, ""), String(temp)]
    applyTemperatureProcess.running = true
  }

  Process {
    id: toggleProcess
    command: ["bash", Qt.resolvedUrl("apply-temperature").toString().replace(/^file:\/\//, ""), "toggle"]
    onExited: function(code) { if (code !== 0) root.failure = strings.t("error"); root.refreshTemperature() }
  }

  Process {
    id: applyTemperatureProcess
    onExited: function(code) {
      if (code !== 0) root.failure = strings.t("error")
      if (root.pendingTemperature >= 0) root.applyPending()
      else root.refreshTemperature()
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
          root.active = current < 6000
          root.temperature = current
          if (root.hostWidget && typeof root.hostWidget.setNightlightState === "function")
            root.hostWidget.setNightlightState(root.active, root.temperature)
        }
      }
    }
  }

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }
  Component.onCompleted: refreshTemperature()
  Timer { interval: 2000; running: true; repeat: true; onTriggered: if (!applyTemperatureProcess.running && !toggleProcess.running) root.refreshTemperature() }

  onOpenedChanged: if (opened) refreshTemperature()

  function closeForPopoutSwitch() {
    root.popoutSwitchClosing = true
    root.close()
    Qt.callLater(function() { root.popoutSwitchClosing = false })
  }

  Ui.KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: Ui.PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: controlsColumn.implicitHeight

      onCloseRequested: root.close()
      onMoveRequested: function(dx, dy) { root.setTemperature(root.temperature + (dx || -dy) * 100) }

      ColumnLayout {
        id: controlsColumn
        anchors.fill: parent
        spacing: Style.space(14)

        RowLayout {
          Layout.fillWidth: true

          Text {
            textFormat: Text.PlainText
            text: strings.t("title")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            Layout.fillWidth: true
          }

          Text {
            textFormat: Text.PlainText
            text: root.active ? strings.t("on") : strings.t("off")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }
        }

        Text {
          visible: root.failure !== ""
          text: root.failure
          textFormat: Text.PlainText
          color: root.bar ? root.bar.foreground : "white"
        }

        Ui.PanelSlider {
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
            textFormat: Text.PlainText
            text: strings.t("warmer")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
          Item { Layout.fillWidth: true }
          Text {
            textFormat: Text.PlainText
            text: root.temperature + " K"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
          Item { Layout.fillWidth: true }
          Text {
            textFormat: Text.PlainText
            text: strings.t("cooler")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }
      }
    }
  }
}
