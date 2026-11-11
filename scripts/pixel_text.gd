extends Node2D
## Texto em pixel art com uma fonte 3x5 desenhada em código.
## A posição do nó é o canto superior esquerdo da linha (ou o centro, se align = 1).

const GLYPHS := {
	"A": [".#.", "#.#", "###", "#.#", "#.#"],
	"B": ["##.", "#.#", "##.", "#.#", "##."],
	"C": [".##", "#..", "#..", "#..", ".##"],
	"D": ["##.", "#.#", "#.#", "#.#", "##."],
	"E": ["###", "#..", "##.", "#..", "###"],
	"F": ["###", "#..", "##.", "#..", "#.."],
	"G": [".##", "#..", "#.#", "#.#", ".##"],
	"H": ["#.#", "#.#", "###", "#.#", "#.#"],
	"I": ["###", ".#.", ".#.", ".#.", "###"],
	"J": ["..#", "..#", "..#", "#.#", ".#."],
	"K": ["#.#", "#.#", "##.", "#.#", "#.#"],
	"L": ["#..", "#..", "#..", "#..", "###"],
	"M": ["#.#", "###", "###", "#.#", "#.#"],
	"N": ["##.", "#.#", "#.#", "#.#", "#.#"],
	"O": [".#.", "#.#", "#.#", "#.#", ".#."],
	"P": ["##.", "#.#", "##.", "#..", "#.."],
	"Q": [".#.", "#.#", "#.#", "##.", ".##"],
	"R": ["##.", "#.#", "##.", "#.#", "#.#"],
	"S": [".##", "#..", ".#.", "..#", "##."],
	"T": ["###", ".#.", ".#.", ".#.", ".#."],
	"U": ["#.#", "#.#", "#.#", "#.#", "###"],
	"V": ["#.#", "#.#", "#.#", "#.#", ".#."],
	"W": ["#.#", "#.#", "###", "###", "#.#"],
	"X": ["#.#", "#.#", ".#.", "#.#", "#.#"],
	"Y": ["#.#", "#.#", ".#.", ".#.", ".#."],
	"Z": ["###", "..#", ".#.", "#..", "###"],
	"0": ["###", "#.#", "#.#", "#.#", "###"],
	"1": [".#.", "##.", ".#.", ".#.", "###"],
	"2": ["##.", "..#", ".#.", "#..", "###"],
	"3": ["##.", "..#", ".#.", "..#", "##."],
	"4": ["#.#", "#.#", "###", "..#", "..#"],
	"5": ["###", "#..", "##.", "..#", "##."],
	"6": [".##", "#..", "###", "#.#", "###"],
	"7": ["###", "..#", ".#.", ".#.", ".#."],
	"8": ["###", "#.#", "###", "#.#", "###"],
	"9": ["###", "#.#", "###", "..#", "##."],
	".": ["...", "...", "...", "...", ".#."],
	",": ["...", "...", "...", ".#.", "#.."],
	":": ["...", ".#.", "...", ".#.", "..."],
	"!": [".#.", ".#.", ".#.", "...", ".#."],
	"?": ["##.", "..#", ".#.", "...", ".#."],
	"-": ["...", "...", "###", "...", "..."],
	"/": ["..#", "..#", ".#.", "#..", "#.."],
	"(": [".#.", "#..", "#..", "#..", ".#."],
	")": [".#.", "..#", "..#", "..#", ".#."],
	"'": [".#.", ".#.", "...", "...", "..."],
	"<": ["..#", ".#.", "#..", ".#.", "..#"],
	">": ["#..", ".#.", "..#", ".#.", "#.."],
	"\"": ["#.#", "#.#", "...", "...", "..."],
}

# Letras acentuadas = letra base + acento desenhado acima (ou cedilha abaixo).
const ACCENTS := {
	"Á": ["A", "acute"], "À": ["A", "grave"], "Â": ["A", "circ"], "Ã": ["A", "tilde"],
	"É": ["E", "acute"], "Ê": ["E", "circ"], "Í": ["I", "acute"],
	"Ó": ["O", "acute"], "Ô": ["O", "circ"], "Õ": ["O", "tilde"],
	"Ú": ["U", "acute"], "Ç": ["C", "cedilla"],
}

const ACCENT_PIXELS := {
	"acute": [Vector2i(1, -1), Vector2i(2, -2)],
	"grave": [Vector2i(0, -2), Vector2i(1, -1)],
	"circ": [Vector2i(0, -1), Vector2i(1, -2), Vector2i(2, -1)],
	"tilde": [Vector2i(0, -1), Vector2i(1, -2), Vector2i(2, -2)],
	"cedilla": [Vector2i(1, 5), Vector2i(2, 6)],
}

const LINE_HEIGHT := 9

var text := "":
	set(value):
		text = value
		queue_redraw()
var color := Color.WHITE:
	set(value):
		color = value
		queue_redraw()
var pixel := 1      # escala inteira
var align := 0      # 0 = esquerda, 1 = centro, 2 = direita
var shadow := true


func _draw() -> void:
	var lines := text.to_upper().split("\n")
	for i in lines.size():
		var line: String = lines[i]
		var w := line.length() * 4 * pixel - pixel
		var x0 := 0
		if align == 1:
			x0 = -w / 2
		elif align == 2:
			x0 = -w
		var y0 := i * LINE_HEIGHT * pixel
		if shadow:
			_draw_line(line, x0 + 1, y0 + 1, Color(0, 0, 0, 0.55))
		_draw_line(line, x0, y0, color)


func _draw_line(line: String, x0: int, y0: int, col: Color) -> void:
	for i in line.length():
		var ch := line[i]
		var accent := ""
		if ACCENTS.has(ch):
			accent = ACCENTS[ch][1]
			ch = ACCENTS[ch][0]
		var cx := x0 + i * 4 * pixel
		var glyph: Array = GLYPHS.get(ch, [])
		for gy in glyph.size():
			var row: String = glyph[gy]
			for gx in 3:
				if row[gx] == "#":
					_px(cx, y0, gx, gy, col)
		for p in ACCENT_PIXELS.get(accent, []):
			_px(cx, y0, p.x, p.y, col)


func _px(cx: int, y0: int, gx: int, gy: int, col: Color) -> void:
	draw_rect(Rect2(cx + gx * pixel, y0 + (gy + 2) * pixel, pixel, pixel), col)
