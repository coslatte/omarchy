import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui as Ui

// 2026-11-10 11:53: solicitud: mostrar en vivo los valores al mover los controles.
Ui.Panel {
  id: root
  moduleName: "cosmiclatte.glass"
  ipcTarget: ""
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string mode: "auto"
  property string activeMode: "opaque"
  property int blurSize: 7
  property real glassOpacity: 0.88
  property real previewBlurSize: blurSize
  property real previewOpacity: glassOpacity
  property string failure: ""
  property string focusSection: "mode"
  property int modeCursor: 0
  property bool loadedMode: false
  property var pendingSettings: []
  property bool refreshPending: false
  readonly property var modeOptions: ["auto", "on", "off"]
  readonly property bool busy: settingProcess.running

  function refresh() {
    if (settingProcess.running || statusProcess.running) {
      refreshPending = true
      return
    }
    refreshPending = false
    statusProcess.running = true
  }

  function refreshWhenIdle() {
    if (refreshPending && !settingProcess.running && !statusProcess.running)
      Qt.callLater(root.refresh)
  }

  function startSetting(key, value) {
    failure = ""
    if (statusProcess.running) refreshPending = true
    settingProcess.command = ["omarchy-glass", key, String(value)]
    settingProcess.running = true
  }

  function applySetting(key, value) {
    if (settingProcess.running) {
      var pending = pendingSettings.slice()
      var queued = { key: key, value: String(value) }
      var index = -1
      for (var i = 0; i < pending.length; i++) {
        if (pending[i].key === key) { index = i; break }
      }
      if (index >= 0) pending[index] = queued
      else pending.push(queued)
      pendingSettings = pending
      return
    }
    startSetting(key, value)
  }

  function syncHost() {
    if (hostWidget && typeof hostWidget.applyState === "function")
      hostWidget.applyState(mode, activeMode === "glassy", blurSize, glassOpacity)
  }

  function moveFocus(delta) {
    var sections = ["mode", "blur", "opacity"]
    var index = sections.indexOf(focusSection)
    focusSection = sections[(index + delta + sections.length) % sections.length]
  }

  function moveCursor(dx) {
    if (focusSection === "mode") {
      modeCursor = Math.max(0, Math.min(modeOptions.length - 1, modeCursor + dx))
    } else if (focusSection === "blur") {
      previewBlurSize = Math.max(1, Math.min(24, previewBlurSize + dx))
      applySetting("blur", Math.round(previewBlurSize))
    } else {
      previewOpacity = Math.max(0.00, Math.min(1.00, +(previewOpacity + dx * 0.01).toFixed(2)))
      applySetting("opacity", previewOpacity.toFixed(2))
    }
  }

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  Process {
    id: statusProcess
    command: ["omarchy-glass", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        // 2026-11-11 10:14: solicitud: mostrar el estado real de glass.
        if (settingProcess.running) {
          root.refreshPending = true
          return
        }
        var output = String(text)
        var match = output.match(/^mode=(auto|on|off)$/m)
        if (match) {
          root.mode = match[1]
          if (!root.loadedMode || root.focusSection !== "mode")
            root.modeCursor = Math.max(0, root.modeOptions.indexOf(root.mode))
          root.loadedMode = true
        }
        match = output.match(/^active=(glassy|opaque)\b/m)
        if (match) root.activeMode = match[1]
        match = output.match(/^blur_size=([0-9]+)$/m)
        if (match) {
          root.blurSize = Number(match[1])
          if (!blurSlider.dragging) root.previewBlurSize = root.blurSize
        }
        match = output.match(/^opacity=([0-9.]+)$/m)
        if (match) {
          root.glassOpacity = Number(match[1])
          if (!opacitySlider.dragging) root.previewOpacity = root.glassOpacity
        }
        root.syncHost()
      }
    }
    onExited: Qt.callLater(root.refreshWhenIdle)
  }

  Process {
    id: settingProcess
    onExited: function(code) {
      var next = root.pendingSettings.length > 0 ? root.pendingSettings[0] : null
      if (next) {
        root.pendingSettings = root.pendingSettings.slice(1)
        root.startSetting(next.key, next.value)
        return
      }
      if (code !== 0) root.failure = strings.t("error")
      else root.refresh()
      root.refreshWhenIdle()
    }
  }

  Timer {
    interval: 3000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: refresh()
  onOpenedChanged: {
    if (!opened) {
      focusTimer.stop()
      return
    }
    refresh()
    focusTimer.restart()
  }

  Timer {
    id: focusTimer
    interval: 75
    onTriggered: if (panel.open) keyCatcher.forceActiveFocus()
  }

  // 2026-11-10: solicitud: mantener accesible el botón con contenido dinámico.
  Ui.PopupCard {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(controlsColumn.implicitHeight)

    Ui.PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: controlsColumn.implicitHeight
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.moveFocus(direction) }
      onMoveRequested: function(dx, dy) {
        if (dy !== 0) root.moveFocus(dy)
        else if (dx !== 0) root.moveCursor(dx)
      }
      onActivateRequested: {
        if (root.focusSection === "mode")
          root.applySetting("mode", root.modeOptions[root.modeCursor])
      }

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
            text: root.activeMode === "glassy" ? strings.t("status.on") : strings.t("status.off")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: root.failure !== ""
          text: root.failure
          color: root.bar ? root.bar.foreground : "white"
        }

        Text {
          textFormat: Text.PlainText
          text: strings.t("mode.label")
          color: root.bar ? root.bar.foreground : "white"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: root.focusSection === "mode"
        }

        RowLayout {
          id: modeGroup
          Layout.fillWidth: true
          spacing: Style.space(6)

          Repeater {
            model: root.modeOptions
            delegate: Ui.Button {
              required property string modelData
              required property int index
              Layout.fillWidth: true
              Layout.minimumWidth: 0
              Layout.preferredWidth: (modeGroup.width - modeGroup.spacing * (root.modeOptions.length - 1)) / root.modeOptions.length
              enabled: !root.busy
              text: modelData === "auto" ? strings.t("mode.auto")
                : modelData === "on" ? strings.t("mode.on") : strings.t("mode.off")
              selected: root.mode === modelData
              hasCursor: root.focusSection === "mode" && root.modeCursor === index
              bordered: true
              foreground: root.bar ? root.bar.foreground : Color.foreground
              accent: Color.accent
              fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
              fontSize: Style.font.body
              onClicked: {
                root.modeCursor = index
                root.applySetting("mode", modelData)
              }
              onHovered: function(hovered) {
                if (hovered) root.modeCursor = index
              }
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Text {
            textFormat: Text.PlainText
            text: strings.t("blur.label")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: root.focusSection === "blur"
          }
          Item { Layout.fillWidth: true }
          Text {
            textFormat: Text.PlainText
            text: String(Math.round(root.previewBlurSize))
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }

        Ui.PanelSlider {
          id: blurSlider
          Layout.fillWidth: true
          enabled: !root.busy
          bar: root.bar
          minimum: 1
          maximum: 24
          step: 1
          integer: true
          value: root.previewBlurSize
          onMoved: function(value) { root.previewBlurSize = value }
          onReleased: function(value) { root.applySetting("blur", Math.round(value)) }
        }

        RowLayout {
          Layout.fillWidth: true
          Text {
            textFormat: Text.PlainText
            text: strings.t("opacity.label")
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: root.focusSection === "opacity"
          }
          Item { Layout.fillWidth: true }
          Text {
            textFormat: Text.PlainText
            text: Math.round(root.previewOpacity * 100) + "%"
            color: root.bar ? root.bar.foreground : "white"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }

        Ui.PanelSlider {
          id: opacitySlider
          Layout.fillWidth: true
          enabled: !root.busy
          bar: root.bar
          minimum: 0.00
          maximum: 1.00
          step: 0.01
          integer: false
          value: root.previewOpacity
          onMoved: function(value) { root.previewOpacity = value }
          onReleased: function(value) { root.applySetting("opacity", Number(value).toFixed(2)) }
        }
      }
    }
  }
}
