import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "cosmiclatte.notifications"
  ipcTarget: "cosmiclatte.notifications"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var history: []
  property var mutedApps: []
  property int page: 0
  property int selectedRowIndex: 0
  property bool previewImageOpen: false
  readonly property int pageSize: 10
  readonly property int pageCount: Math.max(1, Math.ceil(history.length / pageSize))
  readonly property var visibleRows: history.slice(page * pageSize, page * pageSize + pageSize)
  readonly property var selectedNotification: visibleRows.length > 0 ? visibleRows[Math.min(selectedRowIndex, visibleRows.length - 1)] : null
  readonly property color contentForeground: bar ? bar.foreground : Commons.Color.foreground

  readonly property var barIdentity: hostWidget || root

  function open() {
    refresh()
    root.controller.show()
  }
  function close() { root.controller.hide() }
  function toggle() { root.opened ? root.close() : root.open() }
  function closeForPopoutSwitch() {
    root.popoutSwitchClosing = true
    root.close()
    Qt.callLater(function() { root.popoutSwitchClosing = false })
  }
  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }
  function refresh() {
    historyProcess.running = true
    mutedAppsProcess.running = true
  }
  function setMutedApps(raw) {
    try {
      var parsed = JSON.parse(raw || "[]")
      mutedApps = Array.isArray(parsed) ? parsed : []
    } catch (error) {
      mutedApps = []
    }
  }
  function isAppMuted(app) {
    var key = String(app || "").trim().toLowerCase()
    return key !== "" && mutedApps.some(function(name) { return String(name || "").trim().toLowerCase() === key })
  }
  function toggleSelectedAppMute() {
    if (!selectedNotification || !selectedNotification.app) return
    var app = String(selectedNotification.app)
    var muted = !isAppMuted(app)
    if (muted) mutedApps = mutedApps.concat([app])
    else mutedApps = mutedApps.filter(function(name) { return String(name || "").trim().toLowerCase() !== app.trim().toLowerCase() })
    muteAppProcess.command = ["omarchy-shell", "notifications", "setAppMuted", app, muted ? "true" : "false"]
    muteAppProcess.running = true
  }
  function setHistory(raw) {
    try {
      var parsed = JSON.parse(raw || "[]")
      history = Array.isArray(parsed) ? parsed.slice(0, 30) : []
      page = Math.min(page, pageCount - 1)
      selectedRowIndex = Math.min(selectedRowIndex, Math.max(0, visibleRows.length - 1))
    } catch (error) {
      history = []
      page = 0
    }
  }
  onPageChanged: selectedRowIndex = 0
  function relativeTime(timestamp) {
    var minutes = Math.max(0, Math.floor((Date.now() - Number(timestamp || 0)) / 60000))
    if (minutes < 1) return "Just now"
    if (minutes < 60) return minutes + " min ago"
    var hours = Math.floor(minutes / 60)
    if (hours < 24) return hours + " hr ago"
    return Qt.formatDateTime(new Date(Number(timestamp)), "MMM d, HH:mm")
  }
  function notificationTime(timestamp) {
    var value = Number(timestamp || 0)
    return value > 0 ? Qt.formatDateTime(new Date(value), "HH:mm") : "--:--"
  }
  function mediaSource(value) {
    var source = String(value || "")
    if (!source) return ""
    if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0 || source.indexOf("https://") === 0 || source.indexOf("http://") === 0)
      return source
    if (source.charAt(0) === "/") return Util.fileUrl(source)
    return Quickshell.iconPath(source, true)
  }

  Process {
    id: historyProcess
    command: ["bash", "-c", "find \"$1\" -type f -name '*.json' -exec cat {} + 2>/dev/null | jq -s '[.[] | select(type == \"object\" and (.timestamp | type == \"number\"))] | sort_by(.timestamp) | reverse | .[0:30]' 2>/dev/null || echo '[]'", "--", Quickshell.env("HOME") + "/.local/state/omarchy/notifications"]
    stdout: StdioCollector { onStreamFinished: root.setHistory(text) }
  }

  Process {
    id: mutedAppsProcess
    command: ["omarchy-shell", "notifications", "mutedApps"]
    stdout: StdioCollector { onStreamFinished: root.setMutedApps(text) }
  }

  Process { id: muteAppProcess; onExited: root.refresh() }
  Process { id: openAppProcess }

  function openNotification(entry) {
    if (!entry || !entry.app || openAppProcess.running) return
    openAppProcess.command = ["omarchy-hyprland-focus-app", String(entry.app).replace(/[.*+?^${}()|[\]\\]/g, "\\$&")]
    openAppProcess.running = true
    root.close()
  }

  Timer {
    interval: 3000
    repeat: true
    running: root.opened
    onTriggered: root.refresh()
  }

  PopupCard {
    id: popup
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    contentWidth: fittedContentWidth(Style.space(790))
    contentHeight: fittedContentHeight(content.implicitHeight)
    triggerMode: "click"

    Rectangle {
      anchors.fill: parent
      z: 10
      visible: root.previewImageOpen
      color: "#e6000000"
      radius: Style.cornerRadius
      MouseArea { anchors.fill: parent; onClicked: root.previewImageOpen = false }
      Image {
        anchors.fill: parent
        anchors.margins: Style.space(36)
        source: notificationImage.imageSource
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
      }
      PanelActionButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Style.space(12)
        iconText: "󰅖"
        tooltipText: "Close image preview"
        foreground: root.contentForeground
        fontFamily: Style.font.family
        onClicked: root.previewImageOpen = false
      }
    }

    ColumnLayout {
      id: content
      anchors.fill: parent
      spacing: Style.space(12)

      RowLayout {
        Layout.fillWidth: true
        Text {
          Layout.fillWidth: true
          text: "Notifications"
          color: root.contentForeground
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
        }
        Text {
          text: root.history.length + " / 30"
          color: Qt.darker(root.contentForeground, 1.5)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
        PanelActionButton {
          iconText: "󰅁"
          tooltipText: "Newer notifications"
          foreground: root.contentForeground
          fontFamily: Style.font.family
          enabled: root.page > 0
          onClicked: { root.page--; root.refresh() }
        }
        Text {
          text: (root.page + 1) + " / " + root.pageCount
          color: Qt.darker(root.contentForeground, 1.5)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
        PanelActionButton {
          iconText: "󰅂"
          tooltipText: "Older notifications"
          foreground: root.contentForeground
          fontFamily: Style.font.family
          enabled: root.page + 1 < root.pageCount
          onClicked: { root.page++; root.refresh() }
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Style.space(430)
        spacing: Style.space(10)

        // The left pane keeps each notification visually distinct while
        // letting the user browse all ten entries without changing pages.
        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredWidth: Style.space(300)
          radius: Style.cornerRadius
          color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.035)
          border.width: 1
          border.color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.1)

          Flickable {
            anchors.fill: parent
            anchors.margins: Style.space(7)
            clip: true
            contentWidth: width
            contentHeight: notificationList.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
              id: notificationList
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: root.visibleRows
                delegate: Rectangle {
                  id: notificationCard
                  required property var modelData
                  required property int index
                  width: notificationList.width
                  height: cardContent.implicitHeight + Style.space(18)
                  radius: Style.cornerRadius
                  color: root.selectedRowIndex === index
                    ? Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.11)
                    : Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.045)
                  border.width: root.selectedRowIndex === index ? 1 : 0
                  border.color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.18)

                  RowLayout {
                    id: cardContent
                    x: Style.space(9)
                    y: Style.space(9)
                    width: parent.width - Style.space(18)
                    spacing: Style.space(9)

                    Item {
                      Layout.preferredWidth: Style.space(38)
                      Layout.preferredHeight: Style.space(38)

                      Image {
                        id: summaryIcon
                        readonly property string iconSource: root.mediaSource(modelData.appIcon || modelData.image)
                        anchors.fill: parent
                        source: iconSource
                        visible: iconSource !== "" && status !== Image.Error
                        sourceSize.width: width * Screen.devicePixelRatio
                        sourceSize.height: height * Screen.devicePixelRatio
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                      }
                      Text {
                        anchors.fill: parent
                        visible: !summaryIcon.visible
                        text: modelData.glyph || "󰂚"
                        color: root.contentForeground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.title
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                      }
                    }

                    ColumnLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(3)

                      RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.space(8)
                        Text {
                          Layout.fillWidth: true
                          text: modelData.summary || modelData.app || "Untitled notification"
                          color: root.contentForeground
                          font.family: Style.font.family
                          font.pixelSize: Style.font.body
                          font.bold: true
                          elide: Text.ElideRight
                          wrapMode: Text.NoWrap
                        }
                        Text {
                          text: root.notificationTime(modelData.timestamp)
                          color: Qt.darker(root.contentForeground, 1.5)
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                        }
                      }
                      Text {
                        Layout.fillWidth: true
                        text: modelData.body || modelData.app || "No additional text"
                        color: Qt.darker(root.contentForeground, 1.25)
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                      }
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    onEntered: root.selectedRowIndex = notificationCard.index
                  }
                  TapHandler {
                    onTapped: { root.selectedRowIndex = notificationCard.index; root.openNotification(modelData) }
                  }
                }
              }

              Text {
                visible: root.history.length === 0
                width: notificationList.width
                height: Style.space(410)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "No recent notifications"
                color: Qt.darker(root.contentForeground, 1.4)
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
              }
            }
          }
        }

        // The right pane shows the selected notification's complete text.
        // Its own Flickable keeps long descriptions readable without moving
        // the list or the pagination controls.
        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredWidth: Style.space(430)
          radius: Style.cornerRadius
          color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.055)
          border.width: 1
          border.color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.12)

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.space(14)
            spacing: 0

            Flickable {
              Layout.fillWidth: true
              Layout.fillHeight: true
              clip: true
              contentWidth: width
              contentHeight: detailContent.implicitHeight
              boundsBehavior: Flickable.StopAtBounds
              ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

              Column {
                id: detailContent
                width: parent.width
                spacing: Style.space(12)

                RowLayout {
                  width: detailContent.width
                  spacing: Style.space(10)

                  Item {
                    Layout.preferredWidth: Style.space(40)
                    Layout.preferredHeight: Style.space(40)

                    Image {
                      id: detailIcon
                      readonly property string iconSource: root.selectedNotification
                        ? root.mediaSource(root.selectedNotification.appIcon || root.selectedNotification.image) : ""
                      anchors.fill: parent
                      source: iconSource
                      visible: iconSource !== "" && status !== Image.Error
                      sourceSize.width: width * Screen.devicePixelRatio
                      sourceSize.height: height * Screen.devicePixelRatio
                      fillMode: Image.PreserveAspectFit
                      asynchronous: true
                    }
                    Text {
                      anchors.fill: parent
                      visible: !detailIcon.visible
                      text: root.selectedNotification ? (root.selectedNotification.glyph || "󰂚") : "󰂚"
                      color: root.contentForeground
                      font.family: Style.font.family
                      font.pixelSize: Style.font.title
                      horizontalAlignment: Text.AlignHCenter
                      verticalAlignment: Text.AlignVCenter
                    }
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(4)

                    RowLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(8)
                      Text {
                        Layout.fillWidth: true
                        text: root.selectedNotification
                          ? (root.selectedNotification.summary || root.selectedNotification.app || "Notification")
                          : "Notification details"
                        color: root.contentForeground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                      }
                      Text {
                        text: root.selectedNotification ? root.notificationTime(root.selectedNotification.timestamp) : ""
                        color: Qt.darker(root.contentForeground, 1.5)
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }

                    Text {
                      Layout.fillWidth: true
                      text: root.selectedNotification
                        ? (root.selectedNotification.app || "Unknown app") + " · " + (root.selectedNotification.urgency === 2 ? "Urgent" : root.selectedNotification.urgency === 0 ? "Low priority" : "Normal")
                        : ""
                      color: Qt.darker(root.contentForeground, 1.3)
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    RowLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(8)
                      PanelActionButton {
                        iconText: root.selectedNotification && root.isAppMuted(root.selectedNotification.app) ? "󰂛" : "󰂚"
                        tooltipText: root.selectedNotification && root.isAppMuted(root.selectedNotification.app)
                          ? "Allow notifications from this app"
                          : "Silence notifications from this app"
                        foreground: root.contentForeground
                        fontFamily: Style.font.family
                        enabled: !!(root.selectedNotification && root.selectedNotification.app) && !muteAppProcess.running
                        onClicked: root.toggleSelectedAppMute()
                      }
                      Text {
                        Layout.fillWidth: true
                        text: root.selectedNotification
                          ? (root.isAppMuted(root.selectedNotification.app)
                            ? "Notifications from " + root.selectedNotification.app + " are silenced"
                            : "Silence notifications from " + root.selectedNotification.app)
                          : "Select a notification to manage its app"
                        color: Qt.darker(root.contentForeground, 1.25)
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.PlainText
                      }
                    }
                  }
                }

                Image {
                  id: notificationImage
                  readonly property string imageSource: root.selectedNotification ? root.mediaSource(root.selectedNotification.image) : ""
                  width: detailContent.width
                  height: imageSource !== "" && status !== Image.Error ? Style.space(190) : 0
                  visible: height > 0
                  source: imageSource
                  sourceSize.width: width * Screen.devicePixelRatio
                  sourceSize.height: height * Screen.devicePixelRatio
                  fillMode: Image.PreserveAspectFit
                  asynchronous: true
                  smooth: true
                  MouseArea {
                    anchors.fill: parent
                    enabled: notificationImage.status === Image.Ready
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.previewImageOpen = true
                  }
                }

                Text {
                  id: description
                  width: detailContent.width
                  text: root.selectedNotification
                    ? (root.selectedNotification.body || "This notification has no additional description.")
                    : "Hover over a notification to see its details."
                  color: Qt.darker(root.contentForeground, 1.12)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                  textFormat: Text.PlainText
                }

                Text {
                  visible: root.selectedNotification && root.selectedNotification.glyph
                  width: detailContent.width
                  text: root.selectedNotification ? root.selectedNotification.glyph : ""
                  color: root.contentForeground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.title
                  wrapMode: Text.Wrap
                }
              }
            }
          }
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Text {
          text: root.history.length === 0
            ? "0 notifications"
            : (root.page * root.pageSize + 1) + "–" + Math.min((root.page + 1) * root.pageSize, root.history.length) + " of " + root.history.length
          color: Qt.darker(root.contentForeground, 1.5)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
        Item { Layout.fillWidth: true }
      }
    }
  }
}
