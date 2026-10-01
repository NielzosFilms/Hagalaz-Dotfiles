import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Hagalaz sysmon popup: CPU, memory, GPU, disk and top processes.
Panel {
  id: root
  moduleName: "local.hagalaz-sysmon"
  ipcTarget: "local.hagalaz-sysmon"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string statsScript: ""
  readonly property var barIdentity: hostWidget || root

  readonly property string displayFont: "Grenze Gotisch"
  readonly property color fg: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(fg, 1.5)
  readonly property color iron: Qt.rgba(fg.r, fg.g, fg.b, 0.10)
  readonly property color blood: Color.accent

  property var stats: null

  function open() {
    root.controller.show()
    refresh()
  }
  function close() { root.controller.hide() }
  function toggle() { root.opened ? root.close() : root.open() }
  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function refresh() {
    if (statsScript !== "" && !statsProc.running) statsProc.running = true
  }

  function gib(bytes) { return (bytes / 1073741824).toFixed(1) }
  function size(bytes) {
    return bytes >= 1099511627776 ? (bytes / 1099511627776).toFixed(1) + "T" : Math.round(bytes / 1073741824) + "G"
  }
  function uptime(sec) {
    var d = Math.floor(sec / 86400), h = Math.floor(sec % 86400 / 3600), m = Math.floor(sec % 3600 / 60)
    return (d > 0 ? d + "d " : "") + (d > 0 || h > 0 ? h + "h " : "") + m + "m"
  }
  function temp(t) { return t === null || t === undefined ? "" : Math.round(t) + "°C" }

  Process {
    id: statsProc
    command: [root.statsScript]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try { root.stats = JSON.parse(text) } catch (e) {}
      }
    }
  }

  Timer {
    interval: 2000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  // Thin horizontal meter: iron track, bone fill, blood when hot.
  component Meter: Rectangle {
    property real value: 0
    property real hotAt: 85
    width: parent ? parent.width : 100
    height: Style.space(4)
    color: root.iron
    Rectangle {
      height: parent.height
      width: parent.width * Math.max(0, Math.min(1, parent.value / 100))
      color: parent.value >= parent.hotAt ? root.blood : root.fg
      Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }
  }

  // Section heading in blackletter with a right-aligned detail line.
  component Heading: Item {
    property string title: ""
    property string detail: ""
    width: parent ? parent.width : 100
    implicitHeight: Math.max(headingTitle.implicitHeight, headingDetail.implicitHeight)
    Text {
      id: headingTitle
      anchors.left: parent.left
      anchors.baseline: parent.bottom
      anchors.baselineOffset: -Style.space(4)
      text: parent.title
      textFormat: Text.PlainText
      color: root.fg
      font.family: root.displayFont
      font.pixelSize: Style.font.heading + 4
    }
    Text {
      id: headingDetail
      anchors.right: parent.right
      anchors.baseline: headingTitle.baseline
      text: parent.detail
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.bodySmall
    }
  }

  component Line: Text {
    textFormat: Text.PlainText
    color: root.dim
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.bodySmall
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(10)

        readonly property var s: root.stats

        // ---- CPU
        Heading {
          title: "ᛋ  Processor"
          detail: column.s ? [root.temp(column.s.cpu.temp), "load " + column.s.cpu.load.join(" ")].filter(Boolean).join("  ·  ") : "…"
        }
        Row {
          width: parent.width
          spacing: Style.space(8)
          Text {
            id: cpuPct
            text: column.s ? Math.round(column.s.cpu.pct) + "%" : "—"
            textFormat: Text.PlainText
            color: column.s && column.s.cpu.pct >= 85 ? root.blood : root.fg
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.display
            font.bold: true
            width: Style.space(64)
          }
          // Per-core columns, filled from the bottom.
          Row {
            id: cores
            anchors.verticalCenter: cpuPct.verticalCenter
            readonly property var values: column.s ? column.s.cpu.cores : []
            spacing: Style.space(2)
            Repeater {
              model: cores.values.length
              Rectangle {
                required property int index
                readonly property real v: cores.values[index] || 0
                width: Math.max(2, (column.width - Style.space(72) - cores.spacing * (cores.values.length - 1)) / Math.max(1, cores.values.length))
                height: Style.space(26)
                color: root.iron
                Rectangle {
                  anchors.bottom: parent.bottom
                  width: parent.width
                  height: Math.max(1, parent.height * parent.v / 100)
                  color: parent.v >= 85 ? root.blood : root.fg
                  opacity: 0.35 + 0.65 * parent.v / 100
                  Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
              }
            }
          }
        }

        PanelSeparator { foreground: root.fg }

        // ---- Memory
        Heading {
          title: "ᛗ  Memory"
          detail: column.s ? root.gib(column.s.mem.used) + " / " + root.gib(column.s.mem.total) + " GiB" : "…"
        }
        Meter { value: column.s ? column.s.mem.pct : 0; hotAt: 90 }
        Line {
          text: column.s
            ? "cached " + root.gib(column.s.mem.cached) + " GiB   ·   swap " + root.gib(column.s.mem.swapUsed) + " / " + root.gib(column.s.mem.swapTotal) + " GiB"
            : ""
        }

        PanelSeparator { foreground: root.fg }

        // ---- GPU
        Heading {
          readonly property var g: column.s ? column.s.gpu : null
          title: "ᛟ  Graphics"
          detail: !g ? "unavailable" : g.asleep ? "asleep" : [g.util + "%", root.temp(g.temp), g.power !== null ? g.power.toFixed(1) + " W" : ""].filter(Boolean).join("  ·  ")
        }
        Column {
          readonly property var g: column.s ? column.s.gpu : null
          visible: g !== null && !g.asleep
          width: parent.width
          spacing: Style.space(6)
          Line { text: parent.g && !parent.g.asleep ? parent.g.name : "" }
          Meter { value: parent.g && parent.g.util !== null ? parent.g.util : 0 }
          Line {
            text: parent.g && !parent.g.asleep && parent.g.memTotal ? "VRAM " + Math.round(parent.g.memUsed) + " / " + Math.round(parent.g.memTotal) + " MiB" : ""
          }
          Meter { value: parent.g && parent.g.memTotal ? 100 * parent.g.memUsed / parent.g.memTotal : 0; hotAt: 90 }
        }
        Line {
          visible: column.s && column.s.gpu && column.s.gpu.asleep
          text: "dGPU is runtime-suspended; not waking it to poll"
        }

        PanelSeparator { foreground: root.fg }

        // ---- Disk
        Heading {
          title: "ᛞ  Disk"
          detail: column.s && column.s.nvmeTemp !== null ? "NVMe " + root.temp(column.s.nvmeTemp) : ""
        }
        Repeater {
          model: column.s ? column.s.disks : []
          Column {
            required property var modelData
            width: column.width
            spacing: Style.space(4)
            Line { text: modelData.mount + "   " + root.size(modelData.used) + " / " + root.size(modelData.total) + "   (" + Math.round(modelData.pct) + "%)" }
            Meter { value: modelData.pct; hotAt: 90 }
          }
        }

        PanelSeparator { foreground: root.fg }

        // ---- Processes
        Heading {
          title: "ᛉ  Processes"
          detail: column.s ? "up " + root.uptime(column.s.uptime) : ""
        }
        Repeater {
          model: column.s ? column.s.procs : []
          Item {
            required property var modelData
            required property int index
            width: column.width
            height: procName.implicitHeight
            Text {
              id: procName
              anchors.left: parent.left
              text: modelData.name
              textFormat: Text.PlainText
              elide: Text.ElideRight
              width: parent.width - Style.space(80)
              color: index === 0 ? root.fg : root.dim
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.body
            }
            Text {
              anchors.right: parent.right
              text: modelData.cpu.toFixed(1) + "%"
              textFormat: Text.PlainText
              color: modelData.cpu >= 50 ? root.blood : (index === 0 ? root.fg : root.dim)
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.body
            }
          }
        }
        Line {
          text: "right-click the bar readout for btop"
          opacity: 0.6
        }
      }
    }
  }
}
