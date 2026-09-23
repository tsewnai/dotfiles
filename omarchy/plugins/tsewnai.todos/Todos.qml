import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "TodoFile.js" as TodoFile

Panel {
  id: root
  moduleName: "tsewnai.todos"
  ipcTarget: "todos"

  readonly property string home: Quickshell.env("HOME")
  readonly property string filePath: TodoFile.expandHome(setting("file", "~/Documents/vault/todos.md"), home)
  readonly property string fileDir: filePath.substring(0, filePath.lastIndexOf("/"))
  readonly property string editor: String(setting("editor", "nvim"))

  readonly property bool vertical: bar ? bar.vertical : false
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property var lines: []
  property var items: []
  readonly property var pending: items.filter(function(i) { return !i.done })
  readonly property var done: items.filter(function(i) { return i.done })
  property bool showDone: false

  // -1 means the input field owns the keyboard; list rows count from 0.
  property int cursorIndex: -1
  readonly property int toggleRowIndex: pending.length
  readonly property int rowCount: pending.length + (done.length > 0 ? 1 + (showDone ? done.length : 0) : 0)

  readonly property string barText: pending.length === 0
    ? TodoFile.GLYPH_ALL_DONE
    : (vertical ? TodoFile.GLYPH_UNCHECKED : TodoFile.GLYPH_UNCHECKED + " " + pending.length)
  readonly property string tooltipText: {
    if (pending.length === 0) return "All done"
    var shown = pending.slice(0, 8).map(function(i) { return "• " + i.text })
    if (pending.length > 8) shown.push("… " + (pending.length - 8) + " more")
    return shown.join("\n")
  }
  readonly property real openPanelIndicatorWidth: button.labelWidth

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    showDone = false
    cursorIndex = -1
    listFlick.contentY = 0
  }

  function applyText(text) {
    var parsed = TodoFile.parse(text)
    lines = parsed.lines
    items = parsed.items
    clampCursor()
  }

  function writeLines(next) {
    applyText(TodoFile.serialize(next))
    todoFile.setText(TodoFile.serialize(lines))
    // The first write creates the file, and a watch can only start on a file
    // that exists, so read it back by hand instead of waiting for inotify.
    todoFile.reload()
  }

  function clampCursor() {
    if (cursorIndex >= rowCount) cursorIndex = rowCount - 1
  }

  function addTodo(text) {
    if (!String(text).trim()) return
    writeLines(TodoFile.add(lines, text))
  }

  function toggleItem(item) {
    if (item) writeLines(TodoFile.toggle(lines, item.line))
  }

  function removeItem(item) {
    if (item) writeLines(TodoFile.remove(lines, item.line))
  }

  function rowAt(index) {
    if (index < 0 || index >= rowCount) return null
    if (index < pending.length) return { kind: "item", item: pending[index] }
    if (index === toggleRowIndex) return { kind: "toggle" }
    return { kind: "item", item: done[index - toggleRowIndex - 1] }
  }

  function rowHasCursor(index) {
    return cursorIndex === index && !input.activeFocus
  }

  function focusInput() {
    cursorIndex = -1
    input.forceActiveFocus()
  }

  function focusList(index) {
    if (rowCount === 0) { focusInput(); return }
    keyCatcher.forceActiveFocus()
    cursorIndex = Math.max(0, Math.min(index, rowCount - 1))
    ensureCursorVisible()
  }

  function moveCursor(dy) {
    var next = cursorIndex + dy
    if (next < 0) { focusInput(); return }
    focusList(next)
  }

  function hoverRow(index) {
    if (!input.activeFocus) cursorIndex = index
  }

  function activateCursor() {
    var row = rowAt(cursorIndex)
    if (!row) return
    if (row.kind === "toggle") showDone = !showDone
    else toggleItem(row.item)
  }

  function deleteCursor() {
    var row = rowAt(cursorIndex)
    if (row && row.kind === "item") removeItem(row.item)
  }

  function openEditor() {
    if (!bar) return
    close()
    bar.run("omarchy-launch-floating-terminal-with-presentation " + editor + " " + bar.shellQuote(filePath))
  }

  function ensureCursorVisible() {
    var kids = listColumn.children
    for (var i = 0; i < kids.length; i++) {
      var kid = kids[i]
      if (!kid || kid.rowIndex === undefined || kid.rowIndex !== cursorIndex) continue
      var top = kid.y
      var bottom = top + kid.height
      if (top < listFlick.contentY) listFlick.contentY = top
      else if (bottom > listFlick.contentY + listFlick.height) listFlick.contentY = Math.max(0, bottom - listFlick.height)
      return
    }
  }

  FileView {
    id: todoFile
    path: root.filePath
    watchChanges: true
    atomicWrites: true
    blockWrites: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applyText(text())
    onLoadFailed: root.applyText("")
  }

  // Editors and atomic writes replace the inode, which can drop the file
  // watch above; the directory watch catches those and re-reads.
  FileView {
    path: root.fileDir
    watchChanges: true
    printErrors: false
    onFileChanged: todoFile.reload()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.barText
    tooltipText: root.tooltipText
    dimmed: root.pending.length === 0
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.openEditor()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: input
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(header.implicitHeight + Style.space(10) + listColumn.implicitHeight, Style.space(520))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: input.activeFocus
      onMoveRequested: function(dx, dy) { if (dy !== 0) root.moveCursor(dy) }
      onActivateRequested: root.activateCursor()
      onDeleteRequested: root.deleteCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        var key = String(t).toLowerCase()
        if (key === "a" || key === "i" || key === "n") root.focusInput()
        else if (key === "e") root.openEditor()
        else if (key === "c") root.showDone = !root.showDone
        else if (key === "r") todoFile.reload()
      }

      Column {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(10)

        RowLayout {
          width: parent.width
          spacing: Style.space(8)

          PanelSectionHeader {
            text: "TODOS"
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Item { Layout.fillWidth: true }

          Text {
            textFormat: Text.PlainText
            text: root.pending.length + " left" + (root.done.length > 0 ? " · " + root.done.length + " done" : "")
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          PanelActionButton {
            iconText: TodoFile.GLYPH_EDIT
            tooltipText: "Edit file (e)"
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: root.openEditor()
          }
        }

        TextField {
          id: input
          width: parent.width
          placeholderText: "Add a todo…"
          foreground: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          verticalPadding: Style.spacing.controlPaddingY
          onAccepted: { root.addTodo(text); text = "" }
          Keys.onEscapePressed: { if (text) text = ""; else root.close() }
          Keys.onDownPressed: root.focusList(0)
          Keys.onTabPressed: root.focusList(0)
        }
      }

      Flickable {
        id: listFlick
        anchors.top: header.bottom
        anchors.topMargin: Style.space(10)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentWidth: width
        contentHeight: listColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: listColumn
          width: listFlick.width
          spacing: Style.space(4)

          Repeater {
            model: root.pending
            TodoRow {
              required property var modelData
              required property int index
              width: listColumn.width
              item: modelData
              rowIndex: index
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.pending.length === 0
            width: parent.width
            topPadding: Style.space(6)
            bottomPadding: Style.space(6)
            text: root.items.length === 0 ? "Nothing here yet. Type above to add one." : "All done."
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
          }

          ToggleRow {
            visible: root.done.length > 0
            width: listColumn.width
            rowIndex: root.toggleRowIndex
          }

          Repeater {
            model: root.showDone ? root.done : []
            TodoRow {
              required property var modelData
              required property int index
              width: listColumn.width
              item: modelData
              rowIndex: root.toggleRowIndex + 1 + index
            }
          }
        }
      }
    }
  }

  component TodoRow: CursorSurface {
    id: row
    property var item: null
    property int rowIndex: -1

    readonly property bool isDone: item ? item.done === true : false

    hasCursor: root.rowHasCursor(rowIndex)
    foreground: root.foreground
    implicitHeight: rowLayout.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.hoverRow(row.rowIndex)
      onClicked: root.toggleItem(row.item)
    }

    RowLayout {
      id: rowLayout
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        Layout.alignment: Qt.AlignVCenter
        text: row.isDone ? TodoFile.GLYPH_CHECKED : TodoFile.GLYPH_UNCHECKED
        color: row.isDone ? root.dim : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
      }

      Text {
        textFormat: Text.PlainText
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        text: row.item ? row.item.text : ""
        color: root.foreground
        opacity: row.isDone ? 0.55 : 1.0
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.strikeout: row.isDone
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }

      PanelActionButton {
        Layout.alignment: Qt.AlignVCenter
        iconText: TodoFile.GLYPH_TRASH
        tooltipText: "Delete (x)"
        foreground: root.foreground
        hoverColor: root.urgent
        fontFamily: root.fontFamily
        opacity: row.hasCursor ? 1.0 : 0.0
        enabled: row.hasCursor
        onClicked: root.removeItem(row.item)
      }
    }
  }

  component ToggleRow: CursorSurface {
    id: toggleRow
    property int rowIndex: -1

    hasCursor: root.rowHasCursor(rowIndex)
    foreground: root.foreground
    implicitHeight: toggleLabel.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.hoverRow(toggleRow.rowIndex)
      onClicked: root.showDone = !root.showDone
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        id: toggleLabel
        Layout.fillWidth: true
        text: "Completed (" + root.done.length + ")"
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
      }

      Text {
        textFormat: Text.PlainText
        text: root.showDone ? TodoFile.GLYPH_CHEVRON_UP : TodoFile.GLYPH_CHEVRON_DOWN
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
      }
    }
  }
}
