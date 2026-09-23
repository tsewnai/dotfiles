.pragma library

// Lines are kept verbatim so headings, notes, and completed items survive
// every write; only the one checkbox line being edited is rewritten.
var CHECKBOX = /^(\s*[-*+]\s+)\[([ xX])\]\s?(.*)$/

var GLYPH_UNCHECKED = String.fromCodePoint(0xF0131)
var GLYPH_CHECKED = String.fromCodePoint(0xF0132)
var GLYPH_ALL_DONE = String.fromCodePoint(0xF0133)
var GLYPH_TRASH = String.fromCodePoint(0xF0A7A)
var GLYPH_EDIT = String.fromCodePoint(0xF03EB)
var GLYPH_CHEVRON_DOWN = String.fromCodePoint(0xF0140)
var GLYPH_CHEVRON_UP = String.fromCodePoint(0xF0143)

function expandHome(path, home) {
  var p = String(path || "").trim()
  if (p === "~") return home
  if (p.indexOf("~/") === 0) return home + p.substring(1)
  return p
}

function parse(text) {
  var lines = String(text || "").split("\n")
  if (lines.length > 0 && lines[lines.length - 1] === "") lines.pop()
  var items = []
  for (var i = 0; i < lines.length; i++) {
    var m = CHECKBOX.exec(lines[i])
    if (!m) continue
    items.push({ line: i, text: m[3].trim(), done: m[2] !== " " })
  }
  return { lines: lines, items: items }
}

function serialize(lines) {
  return lines.length === 0 ? "" : lines.join("\n") + "\n"
}

function toggle(lines, lineIndex) {
  var next = lines.slice()
  var m = CHECKBOX.exec(next[lineIndex] || "")
  if (!m) return next
  next[lineIndex] = m[1] + "[" + (m[2] === " " ? "x" : " ") + "] " + m[3]
  return next
}

function remove(lines, lineIndex) {
  var next = lines.slice()
  if (lineIndex >= 0 && lineIndex < next.length) next.splice(lineIndex, 1)
  return next
}

function add(lines, text) {
  var t = String(text || "").trim()
  if (!t) return lines
  var next = lines.length === 0 ? ["# Todos", ""] : lines.slice()
  next.push("- [ ] " + t)
  return next
}
