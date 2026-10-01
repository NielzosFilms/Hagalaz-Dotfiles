import QtQuick
import qs.Commons
import qs.Ui

// Hagalaz pomodoro: a candle that burns down.
//   left = start (or skip to the next phase), right = pause/resume, middle = reset.
// Settings (inline on the shell.json entry): workMinutes, breakMinutes.
BarWidget {
  id: root
  moduleName: "local.hagalaz-pomodoro"

  readonly property string flame: String.fromCodePoint(0xF0238)
  readonly property int workSeconds: setting("workMinutes", 25) * 60
  readonly property int breakSeconds: setting("breakMinutes", 5) * 60
  readonly property color breakColor: setting("breakColor", "#a8956a")

  property string phase: "idle"   // idle | work | break
  property bool paused: false
  property int remaining: 0
  property real deadline: 0

  function start(nextPhase) {
    phase = nextPhase
    paused = false
    remaining = nextPhase === "work" ? workSeconds : breakSeconds
    deadline = Date.now() + remaining * 1000
  }

  function reset() {
    phase = "idle"
    paused = false
    remaining = 0
  }

  function togglePause() {
    if (phase === "idle") return
    paused = !paused
    if (!paused) deadline = Date.now() + remaining * 1000
  }

  function notify(title, body) {
    if (root.bar) root.bar.run("notify-send -a Pomodoro " + Util.shellQuote(title) + " " + Util.shellQuote(body))
  }

  function tick() {
    remaining = Math.max(0, Math.round((deadline - Date.now()) / 1000))
    if (remaining > 0) return
    if (phase === "work") {
      notify("ᚺ The candle is spent", "Rest for " + setting("breakMinutes", 5) + " minutes.")
      start("break")
    } else {
      notify("ᚺ Rest is over", "Light another candle when ready.")
      reset()
    }
  }

  function clock(sec) {
    var m = Math.floor(sec / 60), s = sec % 60
    return m + ":" + (s < 10 ? "0" : "") + s
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Timer {
    interval: 1000
    running: root.phase !== "idle" && !root.paused
    repeat: true
    onTriggered: root.tick()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    // Minutes only on the bar; seconds appear during the final minute.
    text: root.phase === "idle" || root.vertical ? root.flame
      : root.flame + " " + (root.remaining < 60 ? root.clock(root.remaining) : Math.ceil(root.remaining / 60))
    fontFamily: root.phase === "idle" || root.vertical ? (root.bar ? root.bar.fontFamily : Style.font.family) : "Grenze Gotisch"
    fontSize: root.phase === "idle" ? Style.bar.iconFont : Style.font.body + 3
    labelVisible: root.vertical
    fixedWidth: root.vertical ? -1 : Math.ceil(pomoLabel.implicitWidth + Style.spaceReal(8.5) * 2)

    // Grenze defaults to old-style numerals (3/4/5/7/9 drop below the
    // baseline); draw our own label with lining + tabular figures.
    Text {
      id: pomoLabel
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
    foreground: root.phase === "break" ? root.breakColor
      : root.phase === "work" ? (root.bar ? root.bar.foreground : Color.foreground)
      : Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.6)
    dimmed: root.paused
    activeColor: Color.accent
    active: root.phase === "work" && root.remaining < 60
    tooltipText: root.phase === "idle" ? "Light a candle (" + setting("workMinutes", 25) + " min)"
      : (root.phase === "work" ? "Focus" : "Rest") + "  ·  " + root.clock(root.remaining) + (root.paused ? "  (paused)" : "")
      + "\nleft: skip · right: pause · middle: reset"

    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.reset()
      else if (b === Qt.RightButton) root.togglePause()
      else if (root.phase === "idle" || root.phase === "break") root.start("work")
      else root.start("break")
    }
  }
}
