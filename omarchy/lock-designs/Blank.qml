// Wallpaper-only companion screen for the non-input monitors.
// Pointed at from Service.qml:661 ("companion" -> "my-blank").
import QtQuick
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: input
  shakeOnFail: true

  Wallpaper { anchors.fill: parent; lock: lock; blur: 0.0; dim: 0 }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  LockInput {
    id: input
    lock: lock
    width: 1; height: 1
    opacity: 0
  }
}
