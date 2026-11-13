import QtQuick
import QtQuick.Layouts
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
  property real temperature: 6500

  function open() {
    if (nightlightService && nightlightService.enabled) temperature = 4000
    controller.show()
  }

  KeyboardPanel {
    id: popup
    anchorItem: root.anchorItem
    owner: root.hostWidget
    bar: root.bar
    open: root.opened
    focusTarget: temperatureSlider
    contentWidth: fittedContentWidth(Style.space(320))
    contentHeight: fittedContentHeight(contentColumn.implicitHeight)

    ColumnLayout {
      id: contentColumn
      anchors.fill: parent
      spacing: Style.space(12)

      Text {
        text: "Night Light · " + Math.round(temperature) + " K"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
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
          var next = Math.round(value / 100) * 100
          root.temperature = next
          if (root.nightlightService) root.nightlightService.setNightlight(next < 6000)
          if (root.bar) {
            root.bar.run(next < 6000
              ? "hyprctl hyprsunset temperature " + next
              : "hyprctl hyprsunset identity")
          }
        }
      }
    }
  }
}
