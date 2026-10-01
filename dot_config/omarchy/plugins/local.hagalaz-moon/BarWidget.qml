import QtQuick
import qs.Commons
import qs.Ui

// Hagalaz moon: current lunar phase, computed locally (no network).
BarWidget {
  id: root
  moduleName: "local.hagalaz-moon"

  readonly property real synodic: 29.530588853
  // Reference new moon: 2000-01-06 18:14 UTC.
  readonly property real referenceNewMoon: Date.UTC(2000, 0, 6, 18, 14)

  readonly property var phases: [
    { name: "New Moon",        glyph: 0xF0F64 },
    { name: "Waxing Crescent", glyph: 0xF0F67 },
    { name: "First Quarter",   glyph: 0xF0F61 },
    { name: "Waxing Gibbous",  glyph: 0xF0F68 },
    { name: "Full Moon",       glyph: 0xF0F62 },
    { name: "Waning Gibbous",  glyph: 0xF0F66 },
    { name: "Last Quarter",    glyph: 0xF0F63 },
    { name: "Waning Crescent", glyph: 0xF0F65 }
  ]

  property real age: 0

  function update() {
    var days = (Date.now() - referenceNewMoon) / 86400000
    age = ((days % synodic) + synodic) % synodic
  }

  readonly property int phaseIndex: Math.floor((age / synodic) * 8 + 0.5) % 8
  readonly property int illumination: Math.round(50 * (1 - Math.cos(2 * Math.PI * age / synodic)))

  function daysLabel(d) {
    var n = Math.round(d)
    return n <= 0 ? "today" : n === 1 ? "tomorrow" : "in " + n + " days"
  }

  readonly property string nextEvent: age < synodic / 2
    ? "Full moon " + daysLabel(synodic / 2 - age)
    : "New moon " + daysLabel(synodic - age)

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: update()

  Timer {
    interval: 3600000
    running: true
    repeat: true
    onTriggered: root.update()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.statusSlot
    text: String.fromCodePoint(root.phases[root.phaseIndex].glyph)
    foreground: root.phaseIndex === 4 && root.bar ? root.bar.foreground : Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.3)
    pressable: false
    tooltipText: root.phases[root.phaseIndex].name + "  ·  " + root.illumination + "% lit\n" + root.nextEvent
  }
}
