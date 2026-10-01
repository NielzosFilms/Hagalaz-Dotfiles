import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Hagalaz sysmon: "ᛋ 12%  ᛗ 79%" on the bar (Sowilo = CPU, Mannaz = memory),
// left click for the stats popup, right click for btop.
BarWidget {
  id: root
  moduleName: "local.hagalaz-sysmon"

  readonly property string statsScript: Qt.resolvedUrl("stats").toString().replace("file://", "")
  property real cpu: -1
  property real mem: -1
  readonly property bool hot: cpu >= setting("cpuHotAt", 85) || mem >= setting("memHotAt", 90)

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    target.bar = root.bar
    target.settings = root.settings
    target.anchorItem = button
    target.hostWidget = root
    target.statsScript = root.statsScript
  }

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false
  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

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

  Process {
    id: briefProc
    command: [root.statsScript, "--brief"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var data = JSON.parse(text)
          root.cpu = data.cpu
          root.mem = data.mem
        } catch (e) {}
      }
    }
  }

  Timer {
    interval: root.setting("intervalSec", 2) * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!briefProc.running) briefProc.running = true
  }

  readonly property string displayFont: "Grenze Gotisch"
  readonly property int labelSize: Style.font.body + 3

  // Grenze has proportional digits; reserve the widest label so the bar
  // doesn't shift as the numbers change.
  TextMetrics {
    id: widest
    font.family: root.displayFont
    font.pixelSize: root.labelSize
    font.features: { "lnum": 1, "tnum": 1 }
    text: root.vertical ? "100" : "ᛋ  100%    ᛗ  100%"
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.cpu < 0 ? "ᛋ …" : (root.vertical
      ? String(Math.round(root.cpu))
      : "ᛋ  " + Math.round(root.cpu) + "%    ᛗ  " + Math.round(root.mem) + "%")
    fontFamily: root.displayFont
    fontSize: root.labelSize
    labelVisible: root.vertical

    // Grenze defaults to old-style numerals (3/4/5/7/9 drop below the
    // baseline); draw our own label with lining + tabular figures.
    Text {
      id: sysLabel
      visible: !root.vertical
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: button.text
      color: button.active && button.useActiveColor ? button.activeColor : button.foreground
      font.family: button.fontFamily
      font.pixelSize: button.fontSize
      font.features: { "lnum": 1, "tnum": 1 }
      renderType: Text.NativeRendering
    }
    fixedWidth: root.vertical ? -1 : Math.ceil(widest.advanceWidth) + Style.space(14)
    active: root.hot
    tooltipText: ""

    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.RightButton) root.bar.run("omarchy-launch-or-focus-tui btop")
      else if (panelLoader.item) panelLoader.item.toggle()
    }
  }
}
