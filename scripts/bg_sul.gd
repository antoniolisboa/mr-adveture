extends RefCounted
## Fundos do Sul. Chamado por scripts/background.gd, que passa a si mesmo (bg)
## para desenhar e emprestar os ajudantes (bg._sky, bg._hills, bg._hill_y, bg._rand,
## bg._cam_x, bg._time, bg._garoa, bg._city...).

## Tema -> descrição (o nome do tema vem da constante THEME de cada fase).
const THEMES := {
	"curitiba": "Curitiba na garoa: a estufa do Jardim Botânico, araucárias e prédios no céu cinza",
	"cataratas": "Cataratas do Iguaçu: paredões de mata, quedas d'água sem fim, névoa e arco-íris",
	"joaquina": "Praia da Joaquina: dunas, ondas boas, surfistas e o morro verde de Florianópolis",
	"hercilioluz": "a Ponte Hercílio Luz iluminada à noite, sobre o mar, com a cidade ao fundo",
	"pampa": "o pampa gaúcho: coxilhas sem fim, cerca de arame, galpão e ovelhas ao longe",
	"serragaucha": "Serra Gaúcha: neblina, araucárias, casas enxaimel e hortênsias azuis",
	"guaiba": "pôr do sol no Guaíba: o rio dourado, a chaminé do Gasômetro e Porto Alegre",
}

## Temas que mudam sozinhos (água, ondas, luzes, garoa): redesenha todo quadro.
const ANIMATED := ["curitiba", "cataratas", "joaquina", "hercilioluz", "guaiba"]

const INK := Color("2b1d2e")
const WHITE := Color("f4f1e8")
const ARAUCARIA := Color("2a5a32")
const ARAUCARIA_DARK := Color("1f4426")
const TRUNK := Color("6b4a32")
const GRAY := [Color("a8b2bc"), Color("b8c0c8"), Color("c8ced4"), Color("d6dade")]
const SUNSET := [Color("4a2e5e"), Color("8a3e6a"), Color("d0604e"), Color("f0904a"), Color("f8c070")]
const NIGHT := [Color("0e1030"), Color("161a44"), Color("1f2656"), Color("2a3066")]


static func draw(bg, theme: String, size: Vector2) -> void:
	match theme:
		"curitiba":
			_curitiba(bg, size)
		"cataratas":
			_cataratas(bg, size)
		"joaquina":
			_joaquina(bg, size)
		"hercilioluz":
			_hercilioluz(bg, size)
		"pampa":
			_pampa(bg, size)
		"serragaucha":
			_serra(bg, size)
		"guaiba":
			_guaiba(bg, size)


# --- Ajudantes -------------------------------------------------------------

static func _bands(bg, size: Vector2, colors: Array, top: float, bottom: float) -> void:
	var h = (bottom - top) / colors.size()
	for i in colors.size():
		bg.draw_rect(Rect2(0, top + i * h, size.x, h + 1), colors[i])


## Araucária: tronco reto e a copa em forma de taça, achatada em cima.
static func _araucaria(bg, x: float, base: float, h: float, col: Color, dark: Color) -> void:
	bg.draw_rect(Rect2(x - 1, base - h, 2, h), TRUNK)
	var top = base - h
	var widths = [30.0, 26.0, 20.0, 12.0]
	for j in widths.size():
		var w: float = widths[j] * h / 70.0
		var y = top + j * 4.0 * h / 70.0
		bg.draw_rect(Rect2(x - w / 2.0, y, w, 3), col if j % 2 == 0 else dark)
		bg.draw_rect(Rect2(x - w / 2.0, y - 2, 2, 2), col)
		bg.draw_rect(Rect2(x + w / 2.0 - 2, y - 2, 2, 2), col)


## Fileira de araucárias com paralaxe.
static func _araucarias(bg, size: Vector2, factor: float, base: float, spacing: int, hmin: float, col: Color, dark: Color, salt: int) -> void:
	var off = floorf(bg._cam_x * factor)
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		if bg._rand(i, salt) % 4 == 0:
			continue
		var x = i * spacing - off + bg._rand(i, salt + 1) % 18
		_araucaria(bg, x, base, hmin + bg._rand(i, salt + 2) % 24, col, dark)


static func _clouds(bg, size: Vector2, col: Color, factor: float, y0: int) -> void:
	var off = floorf(bg._cam_x * factor)
	var spacing = 130
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 5):
		var x = i * spacing - off + bg._rand(i, 70) % 40
		var y = y0 + bg._rand(i, 71) % 26
		bg.draw_rect(Rect2(x, y, 40, 7), col)
		bg.draw_rect(Rect2(x + 8, y - 5, 20, 5), col)
		bg.draw_rect(Rect2(x + 4, y + 7, 28, 2), col)


# --- Paraná ----------------------------------------------------------------

static func _curitiba(bg, size: Vector2) -> void:
	_bands(bg, size, GRAY, 0.0, size.y)
	_clouds(bg, size, Color("e4e8ec"), 0.04, 14)
	bg._city(size, 0.08, 120.0, Color("9aa4ae"), Color("c8d0d8"), 81)
	# A estufa do Jardim Botânico, de vidro e ferro branco, no meio do jardim.
	var off = floorf(bg._cam_x * 0.18)
	var spacing = 520
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var cx = i * spacing - off + 200
		_estufa(bg, cx, 150.0)
	# Gramado com canteiros
	bg.draw_rect(Rect2(0, 150, size.x, size.y - 150), Color("5f9a4f"))
	for i in int(size.x / 24) + 2:
		var x = fposmod(i * 24.0 - bg._cam_x * 0.25, size.x + 24.0) - 12.0
		bg.draw_rect(Rect2(x, 156, 14, 3), Color("d64545") if i % 2 == 0 else Color("f7d038"))
	_araucarias(bg, size, 0.3, 156.0, 60, 50.0, ARAUCARIA, ARAUCARIA_DARK, 83)
	_araucarias(bg, size, 0.55, 186.0, 90, 70.0, Color("244e2c"), Color("1a3a20"), 85)
	bg._garoa(size, 40)


static func _estufa(bg, cx: float, base: float) -> void:
	var glass = Color("bfe0e8")
	var frame = Color("f4f6f8")
	# Asas laterais
	for side in [-1, 1]:
		var x = cx + side * 30 - 16
		bg.draw_rect(Rect2(x, base - 26, 32, 26), glass)
		bg.draw_rect(Rect2(x, base - 28, 32, 2), frame)
		for k in 5:
			bg.draw_rect(Rect2(x + k * 8, base - 26, 1, 26), frame)
		bg.draw_rect(Rect2(x, base - 14, 32, 1), frame)
	# Corpo central com a cúpula em arco
	bg.draw_rect(Rect2(cx - 16, base - 40, 32, 40), glass)
	for k in 17:
		var dx = k * 2 - 16
		var hy = sqrt(maxf(0.0, 256.0 - dx * dx)) * 0.9
		bg.draw_rect(Rect2(cx + dx, base - 40 - hy, 2, hy), glass)
		bg.draw_rect(Rect2(cx + dx, base - 41 - hy, 2, 1), frame)
	for k in 5:
		bg.draw_rect(Rect2(cx - 16 + k * 8, base - 40, 1, 40), frame)
	for y in [-30, -20, -10]:
		bg.draw_rect(Rect2(cx - 16, base + y, 32, 1), frame)
	bg.draw_rect(Rect2(cx - 1, base - 62, 2, 7), frame)          # pináculo
	bg.draw_rect(Rect2(cx - 5, base - 10, 10, 10), Color("6f8f9a"))   # porta


static func _cataratas(bg, size: Vector2) -> void:
	bg.draw_rect(Rect2(Vector2.ZERO, size), Color("8fd3ff"))
	bg.draw_rect(Rect2(0, 70, size.x, 40), Color("b0e0ff"))
	_clouds(bg, size, Color("f4fbff"), 0.03, 12)
	# Arco-íris na névoa
	var rc = Vector2(160 - fposmod(bg._cam_x * 0.05, 400.0) + 100.0, 150)
	var bow = [Color("e85d75"), Color("f07a2a"), Color("f7d038"), Color("5bbf3a"), Color("3f8fd1"), Color("b583d6")]
	for k in bow.size():
		bg.draw_arc(rc, 70.0 - k * 2.0, PI, TAU, 40, Color(bow[k], 0.55), 2.0)
	# Paredões de mata com as quedas d'água
	var off = floorf(bg._cam_x * 0.2)
	for x in int(size.x):
		var y: float = bg._hill_y(x + off, 70.0, 18.0, 0.02, 4.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("3c7a3a"))
		bg.draw_rect(Rect2(x, y, 1, 3), Color("5bbf3a"))
	var spacing = 34
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		if bg._rand(i, 90) % 3 == 0:
			continue
		var wx = i * spacing + bg._rand(i, 91) % 10
		var x = wx - off
		var w = 6 + bg._rand(i, 92) % 10
		var top: float = bg._hill_y(wx, 70.0, 18.0, 0.02, 4.0) + 2.0
		bg.draw_rect(Rect2(x, top, w, 128 - top), Color("dff4ff"))
		for k in 4:
			var sy = fposmod(bg._time * 90.0 + k * 17.0 + i * 7.0, 128.0 - top)
			bg.draw_rect(Rect2(x + (k * 3) % w, top + sy, 1, 6), Color("9fd0e8"))
	# Rio lá embaixo e a névoa subindo
	bg.draw_rect(Rect2(0, 128, size.x, size.y - 128), Color("6f9fb0"))
	for i in 10:
		var mx = fposmod(i * 47.0 - bg._cam_x * 0.25 + sin(bg._time + i) * 6.0, size.x + 40.0) - 20.0
		bg.draw_rect(Rect2(mx, 118 + (i % 3) * 4, 30, 8), Color(1, 1, 1, 0.45))
	bg._hills(size, 0.5, 176.0, 16.0, 0.04, 6.0, Color("2f6f3f"), false)


# --- Santa Catarina --------------------------------------------------------

static func _joaquina(bg, size: Vector2) -> void:
	bg._sky(size)
	# Morro verde ao fundo
	var off = floorf(bg._cam_x * 0.08)
	for x in int(size.x):
		var y: float = bg._hill_y(x + off, 104.0, 40.0, 0.012, 2.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("4f8a4a"))
	# Mar com as ondas quebrando
	bg.draw_rect(Rect2(0, 104, size.x, size.y - 104), Color("2f8fbf"))
	for row in 4:
		var y = 110 + row * 9
		for i in 8:
			var x = fposmod(i * 61.0 + row * 23.0 - bg._cam_x * (0.15 + row * 0.05) + bg._time * (8.0 + row * 4.0), size.x + 40.0) - 20.0
			bg.draw_rect(Rect2(x, y, 22, 2), WHITE)
			bg.draw_rect(Rect2(x + 4, y - 1, 10, 1), Color("bfefff"))
	# Surfistas pegando onda
	for i in 3:
		var sx = fposmod(i * 140.0 - bg._cam_x * 0.2 + bg._time * 18.0, size.x + 60.0) - 30.0
		var sy = 118 + i * 8 + sin(bg._time * 2.0 + i) * 2.0
		bg.draw_rect(Rect2(sx, sy, 8, 1), Color("f7d038"))
		bg.draw_rect(Rect2(sx + 3, sy - 5, 2, 5), INK)
		bg.draw_rect(Rect2(sx + 3, sy - 7, 2, 2), Color("e0a47a"))
	# Dunas da Joaquina
	var off2 = floorf(bg._cam_x * 0.4)
	for x in int(size.x):
		var y: float = bg._hill_y(x + off2, 168.0, 30.0, 0.018, 7.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("f2d58a"))
		bg.draw_rect(Rect2(x, y, 1, 1), Color("fff0c0"))


static func _hercilioluz(bg, size: Vector2) -> void:
	_bands(bg, size, NIGHT, 0.0, 120.0)
	for i in 30:
		var x = fposmod(bg._rand(i, 60) * 0.4 - bg._cam_x * 0.02, size.x)
		var y = bg._rand(i, 61) % 90
		var tw = 1.0 if int(bg._time * 2.0 + i) % 5 != 0 else 0.4
		bg.draw_rect(Rect2(x, y, 1, 1), Color(1, 1, 0.9, tw))
	bg.draw_circle(Vector2(260 - fposmod(bg._cam_x * 0.02, 40.0), 30), 9.0, Color("fff3c8"))
	# Mar escuro
	bg.draw_rect(Rect2(0, 120, size.x, size.y - 120), Color("10183a"))
	# Morro e a cidade do outro lado
	bg._city(size, 0.06, 120.0, Color("1a1e40"), Color("f7d38a"), 91)
	# A ponte pênsil: duas torres, os cabos em curva e o tabuleiro iluminado.
	var off = floorf(bg._cam_x * 0.15)
	var spacing = 640
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x0 = i * spacing - off + 40
		_ponte_pensil(bg, x0, 136.0)
	# Reflexo das luzes no mar
	for i in 18:
		var x = fposmod(i * 29.0 - bg._cam_x * 0.15, size.x)
		var y = 142 + (i % 5) * 7
		var w = 4 + int(bg._time * 3.0 + i) % 4
		bg.draw_rect(Rect2(x, y, w, 1), Color("f7d38a", 0.6))


static func _ponte_pensil(bg, x0: float, deck: float) -> void:
	var steel = Color("c9ccd2")
	var light = Color("fff3b0")
	var t1 = x0 + 90.0
	var t2 = x0 + 330.0
	# Tabuleiro
	bg.draw_rect(Rect2(x0, deck, 420, 4), Color("5a5e70"))
	bg.draw_rect(Rect2(x0, deck, 420, 1), steel)
	# Torres
	for tx in [t1, t2]:
		bg.draw_rect(Rect2(tx - 3, deck - 56, 2, 66), steel)
		bg.draw_rect(Rect2(tx + 2, deck - 56, 2, 66), steel)
		for y in [-54, -40, -26, -12]:
			bg.draw_rect(Rect2(tx - 3, deck + y, 7, 1), steel)
		bg.draw_rect(Rect2(tx - 1, deck - 60, 3, 4), light)
	# Cabo principal em curva (vão central) e para as margens, com luzinhas
	for k in 61:
		var u = k / 60.0
		var x = lerpf(t1, t2, u)
		var y = deck - 54 + 46 * (1.0 - pow(2.0 * u - 1.0, 2.0))
		bg.draw_rect(Rect2(x, y, 4, 1), steel)
		if k % 4 == 0:
			bg.draw_rect(Rect2(x, y + 1, 1, deck - y - 1), Color(0.8, 0.8, 0.85, 0.35))
			bg.draw_rect(Rect2(x + 1, y - 1, 2, 2), light)
	for k in 21:
		var u = k / 20.0
		bg.draw_rect(Rect2(lerpf(x0, t1, u), deck - 54 * u, 4, 1), steel)
		bg.draw_rect(Rect2(lerpf(t2, x0 + 420.0, u), deck - 54 * (1.0 - u), 4, 1), steel)


# --- Rio Grande do Sul -----------------------------------------------------

static func _pampa(bg, size: Vector2) -> void:
	bg._sky(size)
	# Coxilhas suaves, uma atrás da outra
	bg._hills(size, 0.08, 128.0, 14.0, 0.008, 1.0, Color("8fbf6a"), false)
	bg._hills(size, 0.2, 146.0, 16.0, 0.01, 3.0, Color("6fae5a"), false)
	# Galpão de estância e umbu solitário
	var off = floorf(bg._cam_x * 0.2)
	var spacing = 460
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var wx = i * spacing + 120
		var x = wx - off
		var y: float = bg._hill_y(wx + 10, 146.0, 16.0, 0.01, 3.0) + 2.0
		bg.draw_rect(Rect2(x, y - 12, 26, 12), Color("c9a36b"))
		bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 3, y - 12), Vector2(x + 13, y - 20), Vector2(x + 29, y - 12)]), Color("a8542a"))
		bg.draw_rect(Rect2(x + 10, y - 8, 6, 8), Color("6b4f2c"))
		var ux = x + 120
		bg.draw_rect(Rect2(ux, y - 14, 3, 14), Color("6b4a32"))
		bg.draw_rect(Rect2(ux - 10, y - 24, 24, 11), Color("3c7a3a"))
		bg.draw_rect(Rect2(ux - 6, y - 28, 16, 4), Color("3c7a3a"))
	# Ovelhinhas ao longe
	for i in 9:
		var wx = i * 53.0 + 30.0
		var x = fposmod(wx - bg._cam_x * 0.2, size.x + 20.0) - 10.0
		var y: float = bg._hill_y(x + off, 146.0, 16.0, 0.01, 3.0) + 6.0
		bg.draw_rect(Rect2(x, y, 4, 3), WHITE)
		bg.draw_rect(Rect2(x - 1, y, 1, 2), INK)
	# Coxilha da frente com a cerca de arame
	bg._hills(size, 0.45, 172.0, 12.0, 0.015, 5.0, Color("5a9a48"), false)
	var off3 = floorf(bg._cam_x * 0.45)
	for i in int(size.x / 20) + 2:
		var wx = (int(off3 / 20) + i) * 20
		var x = wx - off3
		var y: float = bg._hill_y(wx, 172.0, 12.0, 0.015, 5.0)
		bg.draw_rect(Rect2(x, y - 9, 2, 9), Color("6b4a32"))
		var y2: float = bg._hill_y(wx + 20, 172.0, 12.0, 0.015, 5.0)
		for h in [-7.0, -4.0]:
			bg.draw_line(Vector2(x, y + h), Vector2(x + 20, y2 + h), Color("9aa4b0"), 1.0)


static func _serra(bg, size: Vector2) -> void:
	_bands(bg, size, [Color("aebccb"), Color("bfcad6"), Color("d0d8e0")], 0.0, size.y)
	# Serra azulada na neblina
	bg._hills(size, 0.06, 104.0, 40.0, 0.014, 2.0, Color("8a9cae"), false)
	bg._hills(size, 0.15, 124.0, 30.0, 0.018, 4.0, Color("6f8a8a"), false)
	_araucarias(bg, size, 0.22, 136.0, 46, 40.0, Color("4a6a52"), Color("3f5c46"), 95)
	# Faixa de neblina
	for i in 8:
		var x = fposmod(i * 61.0 - bg._cam_x * 0.25, size.x + 60.0) - 30.0
		bg.draw_rect(Rect2(x, 128 + (i % 3) * 3, 50, 6), Color(1, 1, 1, 0.4))
	# Casas enxaimel de telhado pontudo
	var off = floorf(bg._cam_x * 0.4)
	var spacing = 90
	var first = int(floor(off / spacing)) - 1
	var base = 168.0
	bg.draw_rect(Rect2(0, base, size.x, size.y - base), Color("4f7a46"))
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off + bg._rand(i, 97) % 20
		var w = 26 + bg._rand(i, 98) % 8
		bg.draw_rect(Rect2(x, base - 20, w, 20), WHITE)
		var beam = Color("5a3a22")
		bg.draw_rect(Rect2(x, base - 20, w, 1), beam)
		bg.draw_rect(Rect2(x, base - 10, w, 1), beam)
		for k in range(0, w + 1, 8):
			bg.draw_rect(Rect2(x + mini(k, w - 1), base - 20, 1, 20), beam)
		for k in range(0, w - 7, 8):
			bg.draw_line(Vector2(x + k, base - 10), Vector2(x + k + 8, base - 20), beam, 1.0)
		bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 3, base - 20), Vector2(x + w / 2.0, base - 38),
				Vector2(x + w + 3, base - 20)]), Color("a8342a"))
		bg.draw_rect(Rect2(x + w / 2.0 - 2, base - 30, 4, 4), Color("f7d38a"))
	# Hortênsias na frente
	var off2 = floorf(bg._cam_x * 0.6)
	var cols = [Color("6f8fe0"), Color("b583d6"), Color("e88ab0"), Color("8fb0f0")]
	for i in int(size.x / 14) + 3:
		var wi = int(off2 / 14) + i
		var x = wi * 14 - off2
		var y = 172 + bg._rand(wi, 99) % 4
		bg.draw_rect(Rect2(x, y + 3, 12, 6), Color("3c7a3a"))
		bg.draw_rect(Rect2(x + 1, y, 10, 5), cols[bg._rand(wi, 100) % cols.size()])
		bg.draw_rect(Rect2(x + 3, y - 2, 6, 2), cols[bg._rand(wi, 101) % cols.size()])


static func _guaiba(bg, size: Vector2) -> void:
	_bands(bg, size, SUNSET, 0.0, 116.0)
	var sun_x = 200 - fposmod(bg._cam_x * 0.02, 30.0)
	bg.draw_circle(Vector2(sun_x, 104), 16.0, Color("ffd070"))
	# Rio dourado
	bg.draw_rect(Rect2(0, 112, size.x, size.y - 112), Color("c06a4a"))
	for i in 14:
		var y = 116 + i * 4
		var x = sun_x - 20 + sin(bg._time * 1.5 + i) * 6.0 + (i % 3) * 8
		bg.draw_rect(Rect2(x, y, 24 - i, 1), Color("ffd070"))
	for i in 8:
		var x = fposmod(i * 47.0 - bg._cam_x * 0.1 + bg._time * 5.0, size.x)
		bg.draw_rect(Rect2(x, 124 + i * 6, 14, 1), Color("e0906a"))
	# Porto Alegre e o Gasômetro com a chaminé
	bg._city(size, 0.05, 112.0, Color("3a2a4a"), Color("f7b06a"), 99)
	var off = floorf(bg._cam_x * 0.12)
	var spacing = 560
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x = i * spacing - off + 240
		var brick = Color("5a2e3a")
		bg.draw_rect(Rect2(x, 92, 60, 20), brick)
		bg.draw_rect(Rect2(x + 40, 40, 8, 72), brick)
		bg.draw_rect(Rect2(x + 39, 40, 10, 3), brick)
		for wx in range(4, 56, 7):
			bg.draw_rect(Rect2(x + wx, 98, 3, 5), Color("f7b06a"))
	# Barquinho
	var bx = fposmod(80.0 - bg._cam_x * 0.18 + bg._time * 6.0, size.x + 40.0) - 20.0
	bg.draw_rect(Rect2(bx, 130, 16, 3), INK)
	bg.draw_colored_polygon(PackedVector2Array([Vector2(bx + 7, 129), Vector2(bx + 7, 116), Vector2(bx + 15, 129)]), WHITE)
	# Orla com os ipês
	bg._hills(size, 0.45, 176.0, 8.0, 0.03, 4.0, Color("4a5a3a"), false)
	var off2 = floorf(bg._cam_x * 0.45)
	for i in int(size.x / 70) + 3:
		var wi = int(off2 / 70) + i
		var x = wi * 70 - off2 + bg._rand(wi, 102) % 20
		bg.draw_rect(Rect2(x, 152, 2, 20), Color("4a3428"))
		bg.draw_rect(Rect2(x - 9, 144, 20, 9), Color("f7d038") if wi % 2 == 0 else Color("e88ab0"))
		bg.draw_rect(Rect2(x - 5, 140, 12, 4), Color("f7d038") if wi % 2 == 0 else Color("e88ab0"))
