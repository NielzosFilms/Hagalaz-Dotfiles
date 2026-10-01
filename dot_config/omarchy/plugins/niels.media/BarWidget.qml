import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

// Hagalaz media: organ-pipe play indicator, blackletter title ᛫ muted artist,
// and a blood-red progress line under the label.
BarWidget {
  id: root
  moduleName: "niels.media"

  readonly property string displayFont: "Grenze Gotisch"
  // Lining + tabular figures: Grenze defaults to old-style numerals.
  readonly property var numerals: ({ "lnum": 1, "tnum": 1 })
  readonly property color fg: root.bar ? root.bar.barForeground : Color.foreground
  readonly property color dim: Qt.darker(fg, 1.6)
  readonly property color iron: "#2e2724"
  readonly property color blood: Color.accent

  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
  readonly property var activePlayer: mediaService ? mediaService.activePlayer : null
  readonly property var sourcePlayers: mediaService ? mediaService.sourcePlayers : []

  readonly property bool hasMedia: activePlayer !== null && (activePlayer.trackTitle || activePlayer.trackArtist)
  readonly property bool playing: activePlayer !== null && activePlayer.isPlaying
  readonly property string title: activePlayer ? (activePlayer.trackTitle || "") : ""
  readonly property string artist: activePlayer ? (activePlayer.trackArtist || "") : ""

  // MPRIS position isn't pushed; poll it while playing (or while the popup is open).
  readonly property bool hasProgress: activePlayer !== null && activePlayer.positionSupported && activePlayer.lengthSupported && activePlayer.length > 0
  readonly property real progress: hasProgress ? Math.max(0, Math.min(1, activePlayer.position / activePlayer.length)) : 0

  function timeLabel(sec) {
    sec = Math.max(0, Math.floor(sec || 0))
    var m = Math.floor(sec / 60), s = sec % 60
    return m + ":" + (s < 10 ? "0" : "") + s
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.activePlayer !== null && (root.playing || root.popupOpen)
    onTriggered: if (root.activePlayer) root.activePlayer.positionChanged()
  }

  // Live audio levels from cava (see cava.conf): 4 values 0-100 per line.
  // Runs only while something is playing.
  readonly property string cavaConfig: Qt.resolvedUrl("cava.conf").toString().replace("file://", "")
  property var levels: [0, 0, 0, 0]
  property bool cavaLive: false

  function applyLevels(line) {
    var parts = line.split(";")
    if (parts.length < 4) return
    levels = [parts[0] / 100, parts[1] / 100, parts[2] / 100, parts[3] / 100]
    cavaLive = true
  }

  Process {
    id: cavaProc
    command: ["cava", "-p", root.cavaConfig]
    // Paused while the popup is open: the popup's cava feeds the bar too.
    running: root.playing && root.hasMedia && !root.vertical && !root.popupOpen
    stdout: SplitParser { onRead: function(data) { root.applyLevels(data) } }
    onRunningChanged: root.syncCavaLive()
  }

  // Popup organ: 24 mirrored bars from cava-popup.conf, only while the
  // popup is open. cava's stereo layout puts the bass on the outer edges;
  // each half is reversed so the tall bass pipes stand in the centre.
  readonly property string popupCavaConfig: Qt.resolvedUrl("cava-popup.conf").toString().replace("file://", "")
  readonly property int organPipes: 24
  property var organLevels: []

  function syncCavaLive() {
    if (!cavaProc.running && !popupCavaProc.running) cavaLive = false
  }

  function applyOrganLevels(line) {
    var raw = line.split(";")
    var n = root.organPipes, half = n / 2
    if (raw.length < n) return
    var shown = new Array(n)
    for (var i = 0; i < half; i++) {
      shown[i] = raw[half - 1 - i] / 100
      shown[n - 1 - i] = raw[half + i] / 100
    }
    organLevels = shown
    // Fold both channels into 12 low-to-high bands, then 4 groups for the bar.
    var bar = [0, 0, 0, 0], per = half / 4
    for (var b = 0; b < half; b++) bar[Math.floor(b / per)] += (raw[b] / 100 + raw[n - 1 - b] / 100) / 2 / per
    levels = bar
    cavaLive = true
  }

  Process {
    id: popupCavaProc
    command: ["cava", "-p", root.popupCavaConfig]
    running: root.playing && root.hasMedia && root.popupOpen
    stdout: SplitParser { onRead: function(data) { root.applyOrganLevels(data) } }
    onRunningChanged: root.syncCavaLive()
  }

  property bool popupOpen: false

  readonly property bool opened: popupOpen
  function open() { popupOpen = true }
  function close() { popupOpen = false }
  property real maxLabelWidth: 280

  visible: hasMedia
  implicitWidth: hasMedia ? row.implicitWidth + Style.space(14) : 0
  implicitHeight: barSize

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(7)

    // Organ pipes: live cava levels while playing (red), resting in the
    // normal text color when paused. Falls back to a slow decorative loop
    // when cava isn't available.
    Item {
      id: pipes
      anchors.verticalCenter: parent.verticalCenter
      readonly property int pipeWidth: 3
      readonly property int pipeGap: 2
      readonly property real maxHeight: Style.space(14)
      width: pipeWidth * 4 + pipeGap * 3
      height: maxHeight

      Repeater {
        model: [
          [0.45, 0.85, 0.30, 0.70, 950],
          [0.80, 0.40, 1.00, 0.55, 780],
          [0.60, 1.00, 0.50, 0.90, 1100],
          [0.35, 0.65, 0.25, 0.75, 870]
        ]

        Rectangle {
          required property var modelData
          required property int index
          property real level: 0.15
          readonly property real shown: !root.playing ? 0.15
            : root.cavaLive ? Math.max(0.1, root.levels[index] || 0) : level

          x: index * (pipes.pipeWidth + pipes.pipeGap)
          anchors.bottom: parent.bottom
          width: pipes.pipeWidth
          height: Math.max(2, pipes.maxHeight * shown)
          color: root.playing ? root.blood : root.fg
          Behavior on color { ColorAnimation { duration: 220 } }

          SequentialAnimation on level {
            running: root.playing && !root.cavaLive
            loops: Animation.Infinite
            NumberAnimation { to: modelData[0]; duration: modelData[4]; easing.type: Easing.InOutSine }
            NumberAnimation { to: modelData[1]; duration: modelData[4] * 0.8; easing.type: Easing.InOutSine }
            NumberAnimation { to: modelData[2]; duration: modelData[4] * 1.3; easing.type: Easing.InOutSine }
            NumberAnimation { to: modelData[3]; duration: modelData[4] * 0.9; easing.type: Easing.InOutSine }
          }
        }
      }
    }

    // Title and artist update separately on a track change; settle first.
    Timer {
      id: scrollRestart
      interval: 120
      onTriggered: labelRow.restartScroll()
    }
    Connections {
      target: root
      function onPopupOpenChanged() { scrollRestart.restart() }
      function onTitleChanged() { scrollRestart.restart() }
      function onArtistChanged() { scrollRestart.restart() }
    }
    Connections {
      target: scrollClip
      function onWidthChanged() { scrollRestart.restart() }
    }

    Item {
      id: scrollClip
      width: Math.min(root.maxLabelWidth, labelRow.implicitWidth)
      height: Math.max(pipes.height, labelRow.implicitHeight)
      clip: true
      anchors.verticalCenter: parent.verticalCenter
      visible: !root.vertical && root.title !== ""

      Row {
        id: labelRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(6)

        property bool needsScroll: implicitWidth > scrollClip.width

        Text {
          id: titleText
          textFormat: Text.PlainText
          anchors.verticalCenter: parent.verticalCenter
          text: root.title
          color: root.fg
          font.family: root.displayFont
          font.pixelSize: Style.font.body + 3
          font.features: root.numerals
        }
        Text {
          textFormat: Text.PlainText
          anchors.verticalCenter: parent.verticalCenter
          visible: root.artist !== ""
          text: "᛫"
          color: root.blood
          font.pixelSize: Style.font.body + 2
        }
        Text {
          textFormat: Text.PlainText
          visible: root.artist !== ""
          anchors.baseline: titleText.baseline
          text: root.artist
          color: root.dim
          font.family: root.displayFont
          font.pixelSize: Style.font.body + 1
          font.features: root.numerals
        }

        // Marquee. Driven explicitly instead of via a `running` binding:
        // when a binding stops the animation mid-scroll, x keeps its stale
        // offset, and a short new title shows as a blank gap with its first
        // letters clipped. Every relevant change resets x and restarts.
        NumberAnimation {
          id: scrollAnim
          target: labelRow
          property: "x"
          loops: Animation.Infinite
          easing.type: Easing.Linear
        }

        function restartScroll() {
          scrollAnim.stop()
          x = 0
          if (!needsScroll || root.popupOpen || root.vertical) return
          scrollAnim.from = scrollClip.width
          scrollAnim.to = -implicitWidth
          scrollAnim.duration = Math.max(6000, implicitWidth * 25)
          scrollAnim.start()
        }

        onNeedsScrollChanged: scrollRestart.restart()
        onImplicitWidthChanged: scrollRestart.restart()
        Component.onCompleted: scrollRestart.restart()
      }
    }
  }

  // Blood progress line under the label.
  Rectangle {
    visible: root.hasProgress && scrollClip.visible
    x: row.x + scrollClip.x
    width: scrollClip.width
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Style.space(3)
    height: 2
    color: root.iron

    Rectangle {
      width: parent.width * root.progress
      height: parent.height
      color: root.blood
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.activePlayer ? Qt.PointingHandCursor : Qt.ArrowCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: function(mouse) {
      if (!root.activePlayer) return
      if (mouse.button === Qt.MiddleButton) {
        if (root.mediaService) root.mediaService.runAction("next", false)
      } else if (mouse.button === Qt.RightButton) {
        root.popupOpen = !root.popupOpen
      } else {
        if (root.mediaService) root.mediaService.runAction("playPause", false)
      }
    }
    onWheel: function(wheel) {
      if (!root.activePlayer) return
      if (wheel.angleDelta.y > 0 && root.mediaService) root.mediaService.runAction("previous", false)
      else if (wheel.angleDelta.y < 0 && root.mediaService) root.mediaService.runAction("next", false)
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.hasMedia ? (root.title + (root.artist ? " — " + root.artist : "")) : "")
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(340))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      anchors.fill: parent
      spacing: Style.space(12)

      Row {
        spacing: Style.space(12)
        width: parent.width

        // Iron-framed cover art.
        Rectangle {
          width: Style.space(76)
          height: Style.space(76)
          color: "#070605"
          border.color: root.iron
          border.width: 2

          Image {
            anchors.fill: parent
            anchors.margins: 3
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            source: root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : ""
            visible: source !== ""
          }

          Text {
            anchors.centerIn: parent
            visible: !root.activePlayer || !root.activePlayer.trackArtUrl
            text: "󰝚"
            color: root.dim
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.displayLarge
          }
        }

        Column {
          spacing: Style.space(3)
          width: parent.width - Style.space(88)
          anchors.verticalCenter: parent.verticalCenter

          Text {
            textFormat: Text.PlainText
            text: root.title || "Nothing playing"
            color: root.fg
            font.family: root.displayFont
            font.pixelSize: Style.font.heading + 6
            font.features: root.numerals
            elide: Text.ElideRight
            width: parent.width
          }

          Text {
            textFormat: Text.PlainText
            text: root.artist
            color: Qt.darker(root.fg, 1.3)
            font.family: root.displayFont
            font.pixelSize: Style.font.title
            font.features: root.numerals
            elide: Text.ElideRight
            width: parent.width
            visible: text !== ""
          }

          Text {
            textFormat: Text.PlainText
            text: root.activePlayer && root.activePlayer.trackAlbum ? root.activePlayer.trackAlbum : ""
            color: root.dim
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
            width: parent.width
            visible: text !== ""
          }
        }
      }

      // Organ facade: each pipe fills up to its own height, and the heights
      // rise toward the centre like an organ front. Faint iron outlines show
      // the facade even in silence.
      Item {
        id: organ
        width: parent.width
        height: Style.space(64)
        readonly property real gap: 3
        readonly property real pipeWidth: (width - gap * (root.organPipes - 1)) / root.organPipes

        function facade(i) {
          return 0.5 + 0.5 * Math.sin(Math.PI * (i + 0.5) / root.organPipes)
        }

        Repeater {
          model: root.organPipes

          Item {
            required property int index
            readonly property real maxHeight: organ.height * organ.facade(index)
            readonly property real level: root.playing && root.organLevels.length === root.organPipes
              ? Math.max(0.04, root.organLevels[index]) : 0.04

            x: index * (organ.pipeWidth + organ.gap)
            width: organ.pipeWidth
            height: organ.height

            // Iron outline of the pipe.
            Rectangle {
              anchors.bottom: parent.bottom
              width: parent.width
              height: parent.maxHeight
              color: "transparent"
              border.color: root.iron
              border.width: 1
            }

            // Sound: blood while playing, bone when paused.
            Rectangle {
              anchors.bottom: parent.bottom
              width: parent.width
              height: Math.max(2, parent.maxHeight * parent.level)
              color: root.playing ? root.blood : root.fg
              opacity: root.playing ? 0.55 + 0.45 * parent.level : 0.35
            }

            // Pipe mouth: a dark notch a little above the foot.
            Rectangle {
              anchors.bottom: parent.bottom
              anchors.bottomMargin: Style.space(5)
              anchors.horizontalCenter: parent.horizontalCenter
              width: Math.max(1, parent.width - 2)
              height: 2
              color: "#0a0807"
              opacity: 0.8
            }
          }
        }
      }

      // Blood scrubber with timestamps; click to seek when the player allows it.
      Column {
        visible: root.hasProgress
        width: parent.width
        spacing: Style.space(4)

        Item {
          width: parent.width
          height: Style.space(10)

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 3
            color: root.iron

            Rectangle {
              width: parent.width * root.progress
              height: parent.height
              color: root.blood
            }
            Rectangle {
              x: parent.width * root.progress - width / 2
              anchors.verticalCenter: parent.verticalCenter
              width: 3
              height: 9
              color: root.blood
            }
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.activePlayer && root.activePlayer.canSeek
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: function(mouse) {
              root.activePlayer.position = root.activePlayer.length * Math.max(0, Math.min(1, mouse.x / width))
            }
          }
        }

        Item {
          width: parent.width
          height: elapsed.implicitHeight
          Text {
            id: elapsed
            text: root.timeLabel(root.activePlayer ? root.activePlayer.position : 0)
            color: root.dim
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
          }
          Text {
            anchors.right: parent.right
            text: root.timeLabel(root.activePlayer ? root.activePlayer.length : 0)
            color: root.dim
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
          }
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(6)

        Button {
          iconText: "󰒮"
          foreground: root.fg
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          enabled: root.activePlayer && root.activePlayer.canGoPrevious
          opacity: enabled ? 1.0 : 0.4
          onClicked: if (root.mediaService) root.mediaService.runAction("previous", false, root.mediaService.playerKey(root.activePlayer))
        }

        Button {
          iconText: root.playing ? "󰏤" : "󰐊"
          foreground: root.playing ? root.blood : root.fg
          horizontalPadding: Style.spacing.panelGap
          verticalPadding: Style.spacing.controlPaddingY
          iconSize: Style.font.iconLarge
          enabled: root.activePlayer && (root.activePlayer.canTogglePlaying || root.activePlayer.canPlay || root.activePlayer.canPause)
          opacity: enabled ? 1.0 : 0.4
          onClicked: if (root.mediaService) root.mediaService.runAction("playPause", false, root.mediaService.playerKey(root.activePlayer))
        }

        Button {
          iconText: "󰒭"
          foreground: root.fg
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          enabled: root.activePlayer && root.activePlayer.canGoNext
          opacity: enabled ? 1.0 : 0.4
          onClicked: if (root.mediaService) root.mediaService.runAction("next", false, root.mediaService.playerKey(root.activePlayer))
        }
      }

      PanelSeparator {
        visible: root.sourcePlayers.length > 1
        foreground: root.bar.foreground
      }

      Column {
        id: sourceList
        visible: root.sourcePlayers.length > 1
        width: parent.width
        spacing: Style.space(4)

        Repeater {
          model: root.sourcePlayers

          BorderSurface {
            id: sourceRow
            required property var modelData

            readonly property var player: modelData
            readonly property bool selected: root.activePlayer && player
              && root.mediaService.playerKey(root.activePlayer) === root.mediaService.playerKey(player)
            readonly property string sourceTitle: player ? (player.trackTitle || player.identity || player.desktopEntry || "Media source") : "Media source"
            readonly property string sourceDetail: player && player.trackArtist ? player.trackArtist : (player && player.identity ? player.identity : "")

            width: sourceList.width
            height: sourceInner.implicitHeight + Style.space(10)
            radius: Style.spacing.labelGap
            color: selected ? Style.selectedFillFor(root.bar.foreground, Color.accent) : "transparent"
            borderSpec: selected ? Border.controlSpec("normal", root.bar.foreground, Color.accent) : Border.none()

            Row {
              id: sourceInner
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.leftMargin: sourceRow.borderLeft + Style.space(8)
              anchors.rightMargin: sourceRow.borderRight + Style.space(8)
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                text: sourceRow.player && sourceRow.player.isPlaying ? "󰏤" : "󰐊"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
                width: Style.space(18)
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                width: parent.width - Style.space(26)
                spacing: Style.space(1)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  textFormat: Text.PlainText
                  text: sourceRow.sourceTitle
                  color: root.bar.foreground
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: sourceRow.selected
                  elide: Text.ElideRight
                  width: parent.width
                }

                Text {
                  textFormat: Text.PlainText
                  text: sourceRow.sourceDetail
                  color: Qt.darker(root.bar.foreground, 1.5)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                  width: parent.width
                  visible: text !== ""
                }
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (root.mediaService) root.mediaService.selectPlayer(root.mediaService.playerKey(sourceRow.player))
            }
          }
        }
      }
    }
  }
}
