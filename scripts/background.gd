extends Node2D
## Fundo com parallax. Fica num CanvasLayer (coordenadas da tela).
## Temas: "serra" (montanhas, igrejinha, café), "cidade" (casario de Ouro Preto),
## "mina" (caverna com escoras e lampiões), "estacao" (entardecer com postes),
## "calcadao" (mar, Pão de Açúcar e coqueiros), "praia" (mar, Pão de Açúcar e guarda-sóis),
## "pelourinho" (casarões coloridos com fitas), "baia" (Baía de Todos os Santos e o elevador),
## "farol" (pôr do sol no Farol da Barra), "carnaval" (noite de festa com a multidão),
## "ponte" (baía de Vitória com a Terceira Ponte), "penha" (mata e o Convento da Penha no alto),
## "marginal" (céu cinza, o rio e o trânsito), "farialima" (prédios espelhados)
## e "terraco" (fim de tarde em cima dos prédios, com garoa).

const BgNE := preload("res://scripts/bg_ne.gd")   # temas do Nordeste

const SKY := Color("8fd3ff")
const SKY_LOW := Color("b8e6ff")
const CLOUD := Color("ffffff")
const FAR := Color("86a9c9")
const MID := Color("6fae6a")
const NEAR := Color("4f8f4f")
const BERRY := Color("c0392b")
const CHURCH := Color("f4f1e8")
const CHURCH_TRIM := Color("c9a36b")
const DOOR := Color("6b4f2c")
const INK := Color("2b1d2e")

const HOUSE_WALLS := [Color("f4f1e8"), Color("f2d16b"), Color("7fb3d5"), Color("e8a0a0"), Color("b5d99c")]
const ROOF := Color("8a4a2a")
const WINDOW := Color("2e5e5a")

const CAVE := Color("2a1f18")
const CAVE_ROCK := Color("3b2c22")
const BEAM := Color("6b4f2c")
const LAMP := Color("f7d038")

const SUNSET := [Color("4a2f5e"), Color("7a3b6e"), Color("c0587e"), Color("f08a5d"), Color("f7c873")]
const SUN := Color("ffe08a")
const DUSK_FAR := Color("5a3f6e")
const DUSK_MID := Color("3f2f4e")
const POLE := Color("2b1d2e")

const SEA := Color("2f7fbf")
const SEA_LIGHT := Color("6fb7e6")
const SUGARLOAF := Color("5f7f9a")
const SAND_BG := Color("f2d58a")
const TRUNK := Color("8a6a3f")
const LEAF := Color("3c8d2f")
const UMBRELLAS := [Color("d64545"), Color("f7d038"), Color("2bb3c0"), Color("f07a2a")]

const PELO_WALLS := [Color("3f8fd1"), Color("f7d038"), Color("e85d75"), Color("5bbf3a"),
		Color("f07a2a"), Color("b583d6"), Color("f4f1e8")]
const RIBBONS := [Color("d64545"), Color("f7d038"), Color("2a9d4a"), Color("2b5fb4"), Color("ffffff")]
const BAY := Color("2a8fc0")
const BAY_LIGHT := Color("7fd0f0")
const CLIFF := Color("6f9a4f")
const CLIFF_DARK := Color("4f7a3a")
const ELEVATOR := Color("e8e2d0")
const ELEVATOR_SHADE := Color("b8b09a")
const FORT := Color("d9b07a")
const FORT_DARK := Color("a8824f")
const NIGHT := [Color("120c2e"), Color("1d1446"), Color("2b1d5e"), Color("3d2470")]
const NIGHT_BUILDING := Color("241a3e")
const WINDOW_LIT := Color("f7d38a")
const CROWD := Color("150f26")
const GRANITE := Color("8c8f96")
const GRANITE_DARK := Color("6a6d75")
const CONVENT := Color("f4f1e8")
const BRIDGE := Color("c9ccd2")
const BRIDGE_DARK := Color("9a9ea8")
const VITORIA := [Color("e8e2d0"), Color("c9d6e0"), Color("f2d16b"), Color("e8a0a0")]
const TREE := Color("2f7a3a")
const GRAY_SKY := Color("b9c0c8")
const GRAY_SKY_LOW := Color("d3d7dc")
const SMOG := Color("9aa1aa")
const RIVER := Color("6f7f6a")
const RIVER_LIGHT := Color("8a9a84")
const CONCRETE := Color("8c8f96")
const TOWER_GLASS := [Color("6fa8c9"), Color("4f86a8"), Color("8fc0d8"), Color("3d6f8f")]
const TOWER_FRAME := Color("2b3f52")
const RAIN := Color(0.85, 0.9, 1.0, 0.35)
const DUSK_SKY := [Color("3d3a5e"), Color("6a5a7e"), Color("b07a7e"), Color("e0a07a")]
const SKYLINE := Color("3a3550")
const SKYLINE_LIT := Color("f2c97a")

var theme := "serra"
var _cam_x := -1.0
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	var cam := get_viewport().get_camera_2d()
	var x := 0.0
	if cam:
		x = floorf(cam.get_screen_center_position().x)
	# No Carnaval a multidão e as luzes se mexem o tempo todo.
	if x != _cam_x or theme in ["carnaval", "marginal", "terraco"] or theme in BgNE.ANIMATED:
		_cam_x = x
		queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	match theme:
		"cidade":
			_sky(size)
			_hills(size, 0.15, 112.0, 34.0, 0.011, 1.0, FAR, false)
			_churches(size, 300)
			_houses(size, HOUSE_WALLS, 0.4)
		"mina":
			_cave(size)
		"estacao":
			_sunset(size)
		"calcadao":
			_rio(size, false)
		"praia":
			_rio(size, true)
		"pelourinho":
			_sky(size)
			_houses(size, PELO_WALLS, 0.4)
			_ribbons(size)
		"baia":
			_baia(size)
		"farol":
			_farol(size)
		"carnaval":
			_carnaval(size)
		"ponte":
			_ponte(size)
		"penha":
			_penha(size)
		"marginal":
			_marginal(size)
		"farialima":
			_farialima(size)
		"terraco":
			_terraco(size)
		var t when BgNE.THEMES.has(t):
			BgNE.draw(self, t, size)
		_:
			_sky(size)
			_hills(size, 0.15, 112.0, 34.0, 0.011, 1.0, FAR, false)
			_churches(size, 520)
			_hills(size, 0.35, 138.0, 22.0, 0.02, 2.0, MID, false)
			_hills(size, 0.6, 160.0, 14.0, 0.035, 3.0, NEAR, true)


# Número pseudoaleatório fixo para cada índice (o cenário não muda entre partidas).
func _rand(i: int, salt: int) -> int:
	return absi((i * 73856093) ^ (salt * 19349663)) % 1000


func _sky(size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), SKY)
	draw_rect(Rect2(0, 96, size.x, size.y - 96), SKY_LOW)
	var off := floorf(_cam_x * 0.05)
	var spacing := 150
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 4):
		var x := i * spacing - off + 20
		var y := 24 + _rand(i, 1) % 30
		draw_rect(Rect2(x, y, 34, 6), CLOUD)
		draw_rect(Rect2(x + 6, y - 4, 16, 4), CLOUD)
		draw_rect(Rect2(x + 4, y + 6, 24, 2), CLOUD)


func _hill_y(wx: float, base: float, amp: float, freq: float, seed: float) -> float:
	var n := 0.6 * sin(wx * freq + seed) + 0.4 * sin(wx * freq * 2.3 + seed * 1.7)
	return floorf(base - amp * 0.5 - amp * 0.5 * n)


func _hills(size: Vector2, factor: float, base: float, amp: float, freq: float,
		seed: float, col: Color, berries: bool) -> void:
	var off := floorf(_cam_x * factor)
	for x in int(size.x):
		var wx := x + off
		var y := _hill_y(wx, base, amp, freq, seed)
		draw_rect(Rect2(x, y, 1, size.y - y), col)
		# Pés de café com frutinhas vermelhas no morro da frente.
		if berries and int(wx) % 7 == 0:
			draw_rect(Rect2(x, y + 3, 1, 1), BERRY)


## Igrejinha de duas torres, no estilo de Ouro Preto, nas serras do fundo.
func _churches(size: Vector2, spacing: int) -> void:
	var off := floorf(_cam_x * 0.15)
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var wx := i * spacing + 260
		var x := wx - off
		if x < -40 or x > size.x + 40:
			continue
		var ground := _hill_y(wx + 12, 112.0, 34.0, 0.011, 1.0) + 2
		draw_rect(Rect2(x, ground - 14, 24, 14), CHURCH)
		draw_rect(Rect2(x - 2, ground - 22, 6, 22), CHURCH)
		draw_rect(Rect2(x + 20, ground - 22, 6, 22), CHURCH)
		draw_rect(Rect2(x - 2, ground - 24, 6, 2), CHURCH_TRIM)
		draw_rect(Rect2(x + 20, ground - 24, 6, 2), CHURCH_TRIM)
		draw_rect(Rect2(x + 4, ground - 18, 16, 4), CHURCH_TRIM)
		draw_rect(Rect2(x + 10, ground - 7, 4, 7), DOOR)


## Casario colonial colorido, com telhado e janelas.
func _houses(size: Vector2, walls: Array, factor: float) -> void:
	var off := floorf(_cam_x * factor)
	var spacing := 52
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x := int(i * spacing - off)
		var w := 40 + _rand(i, 2) % 12
		var h := 30 + _rand(i, 3) % 22
		var base := 150 - _rand(i, 4) % 10
		var wall: Color = walls[_rand(i, 5) % walls.size()]
		draw_rect(Rect2(x, base - h, w, h + 40), wall)
		draw_rect(Rect2(x - 2, base - h - 5, w + 4, 5), ROOF)
		draw_rect(Rect2(x, base - h - 8, w, 3), ROOF)
		# janelas com moldura branca
		for wx in range(x + 5, x + w - 8, 12):
			draw_rect(Rect2(wx - 1, base - h + 5, 8, 10), CHURCH)
			draw_rect(Rect2(wx, base - h + 6, 6, 8), WINDOW)
		draw_rect(Rect2(x + w / 2 - 4, base - 12, 8, 12 + 40), DOOR)


func _cave(size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), CAVE)
	# Textura da parede de rocha ao fundo.
	var off := floorf(_cam_x * 0.2)
	var spacing := 24
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		for j in 7:
			var x := i * spacing - off + _rand(i, j) % 10
			var y := j * 26 + _rand(j, i) % 12
			draw_rect(Rect2(x, y, 10 + _rand(i + j, 6) % 10, 6), CAVE_ROCK)
	# Escoras de madeira com lampião.
	off = floorf(_cam_x * 0.5)
	spacing = 128
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + 4):
		var x := i * spacing - off
		draw_rect(Rect2(x, 30, 6, size.y), BEAM)
		draw_rect(Rect2(x + 70, 30, 6, size.y), BEAM)
		draw_rect(Rect2(x - 4, 26, 84, 6), BEAM)
		draw_circle(Vector2(x + 38, 40), 12.0, Color(1.0, 0.85, 0.3, 0.12))
		draw_rect(Rect2(x + 36, 32, 4, 2), INK)
		draw_rect(Rect2(x + 35, 34, 6, 6), LAMP)


func _sunset(size: Vector2) -> void:
	var band := size.y / SUNSET.size()
	for i in SUNSET.size():
		draw_rect(Rect2(0, i * band * 0.75, size.x, size.y), SUNSET[i])
	draw_circle(Vector2(240.0 - floorf(_cam_x * 0.02), 112.0), 18.0, SUN)
	_hills(size, 0.15, 118.0, 30.0, 0.012, 4.0, DUSK_FAR, false)
	_hills(size, 0.35, 146.0, 16.0, 0.02, 5.0, DUSK_MID, false)
	# Postes de telégrafo com fios ao longo da ferrovia.
	var off := floorf(_cam_x * 0.6)
	var spacing := 90
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 6):
		var x := i * spacing - off
		draw_rect(Rect2(x, 104, 3, size.y), POLE)
		draw_rect(Rect2(x - 6, 108, 15, 2), POLE)
		var nx := x + spacing
		for k in 12:
			var t := k / 12.0
			var sag := sin(t * PI) * 6.0
			draw_rect(Rect2(x + t * spacing, 109 + sag, spacing / 12.0 + 1, 1), POLE)
		if nx > size.x + 100:
			break


## Rio: céu, Pão de Açúcar com bondinho, mar e areia; coqueiros ou guarda-sóis na frente.
func _rio(size: Vector2, umbrellas: bool) -> void:
	_sky(size)
	# Pão de Açúcar e o Morro da Urca, repetidos bem ao fundo.
	var off := floorf(_cam_x * 0.1)
	var spacing := 640
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var cx := i * spacing + 230 - off
		if cx < -120 or cx > size.x + 120:
			continue
		for x in range(int(cx) - 70, int(cx) + 30):
			var h := maxf(_bump(x, cx, 20.0, 66.0), _bump(x, cx - 48, 30.0, 30.0))
			if h > 0.0:
				draw_rect(Rect2(x, 122 - h, 1, h), SUGARLOAF)
		# Cabo e cabine do bondinho.
		for k in 24:
			var t := k / 24.0
			draw_rect(Rect2(cx - 48 + t * 48, 92 - t * 36 + sin(t * PI) * 4.0, 2, 1), INK)
		draw_rect(Rect2(cx - 26, 76, 4, 3), Color("d64545"))
	# Mar com reflexos.
	draw_rect(Rect2(0, 122, size.x, size.y - 122), SEA)
	var woff := floorf(_cam_x * 0.2)
	for j in 5:
		for i in range(-1, int(size.x / 40) + 2):
			var x := i * 40 - fmod(woff + j * 13, 40.0)
			draw_rect(Rect2(x, 126 + j * 6, 10 + j * 2, 1), SEA_LIGHT)
	draw_rect(Rect2(0, 156, size.x, size.y - 156), SAND_BG)
	# Coqueiros ou guarda-sóis.
	off = floorf(_cam_x * 0.6)
	spacing = 110 if umbrellas else 150
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + 5):
		var x := i * spacing - off + _rand(i, 7) % 30
		if umbrellas:
			var col: Color = UMBRELLAS[_rand(i, 8) % UMBRELLAS.size()]
			draw_rect(Rect2(x, 140, 1, 22), INK)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - 14, 144), Vector2(x, 136), Vector2(x + 14, 144)]), col)
			draw_rect(Rect2(x - 14, 144, 28, 1), INK)
		else:
			for k in 10:
				draw_rect(Rect2(x + k * 0.6, 160 - k * 5, 3, 6), TRUNK)
			var top := Vector2(x + 6, 108)
			for leaf in [Vector2(-14, 6), Vector2(14, 6), Vector2(-10, -4), Vector2(10, -4), Vector2(0, -7)]:
				for k in 6:
					var pnt: Vector2 = top + leaf * (k / 6.0) + Vector2(0, (k * k) * 0.25)
					draw_rect(Rect2(pnt.round(), Vector2(3, 2)), LEAF)


## Morro arredondado: altura na coluna x.
func _bump(x: float, cx: float, half_w: float, h: float) -> float:
	var d := (x - cx) / half_w
	if absf(d) >= 1.0:
		return 0.0
	return h * sqrt(1.0 - d * d)


## Fitas coloridas penduradas de um lado ao outro da rua do Pelourinho.
func _ribbons(size: Vector2) -> void:
	var off := floorf(_cam_x * 0.5)
	var spacing := 96
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x0 := i * spacing - off
		var y0 := 70.0 + _rand(i, 9) % 16
		for k in 24:
			var t := k / 24.0
			var y := y0 + sin(t * PI) * 14.0
			draw_rect(Rect2(x0 + t * spacing, y, 4, 1), INK)
			if k % 2 == 0:
				var col: Color = RIBBONS[(i + k) % RIBBONS.size()]
				draw_rect(Rect2(x0 + t * spacing + 1, y + 1, 2, 5 + _rand(i * 31 + k, 2) % 4), col)


## Baía de Todos os Santos vista da Cidade Alta: mar, saveiros, a encosta verde
## e a torre do elevador ligando a cidade de cima com a de baixo.
func _baia(size: Vector2) -> void:
	_sky(size)
	draw_rect(Rect2(0, 110, size.x, size.y - 110), BAY)
	var woff := floorf(_cam_x * 0.08)
	for j in 6:
		for i in range(-1, int(size.x / 36) + 2):
			var x := i * 36 - fmod(woff + j * 11, 36.0)
			draw_rect(Rect2(x, 114 + j * 9, 8 + j * 2, 1), BAY_LIGHT)
	# Saveiros com vela branca.
	var off := floorf(_cam_x * 0.12)
	var spacing := 170
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 4):
		var x := i * spacing - off + _rand(i, 10) % 60
		var y := 124 + _rand(i, 11) % 18
		draw_rect(Rect2(x, y, 14, 3), Color("8a4a2a"))
		draw_rect(Rect2(x + 6, y - 14, 1, 14), INK)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + 7, y - 13), Vector2(x + 7, y - 2), Vector2(x + 15, y - 2)]), Color.WHITE)
	# Encosta verde e a torre do elevador.
	off = floorf(_cam_x * 0.3)
	spacing = 420
	first = int(floor(off / spacing)) - 1
	for x in int(size.x):
		var wx := x + off
		var y := _hill_y(wx, 150.0, 14.0, 0.015, 7.0)
		draw_rect(Rect2(x, y, 1, 156 - y), CLIFF)
		draw_rect(Rect2(x, 156, 1, size.y - 156), CLIFF_DARK)
	for i in range(first, first + 3):
		var x := i * spacing - off + 200
		if x < -60 or x > size.x + 60:
			continue
		# Torre com faixas verticais e o prédio de cima.
		draw_rect(Rect2(x, 40, 18, 116), ELEVATOR)
		for k in range(3, 18, 5):
			draw_rect(Rect2(x + k, 48, 1, 104), ELEVATOR_SHADE)
		draw_rect(Rect2(x - 10, 28, 38, 16), ELEVATOR)
		draw_rect(Rect2(x - 10, 42, 38, 2), ELEVATOR_SHADE)
		for k in range(-6, 26, 6):
			draw_rect(Rect2(x + k, 32, 3, 5), WINDOW)
		draw_rect(Rect2(x - 44, 140, 40, 16), Color("e0c9a0"))   # mercado lá embaixo
		draw_rect(Rect2(x - 46, 136, 44, 4), ROOF)
		for k in range(-40, -8, 8):
			draw_rect(Rect2(x + k, 145, 4, 7), DOOR)


## Pôr do sol na Barra: o farol branco de faixa preta em cima do forte, e o mar dourado.
func _farol(size: Vector2) -> void:
	var band := size.y / SUNSET.size()
	for i in SUNSET.size():
		draw_rect(Rect2(0, i * band * 0.75, size.x, size.y), SUNSET[i])
	var sun_x := 230.0 - floorf(_cam_x * 0.02)
	draw_circle(Vector2(sun_x, 114.0), 20.0, SUN)
	draw_rect(Rect2(0, 118, size.x, size.y - 118), Color("3a4f8a"))
	for j in 6:
		var w := 30 - j * 4
		draw_rect(Rect2(sun_x - w / 2.0 + (j % 2) * 3, 121 + j * 5, w, 1), SUN)
	var off := floorf(_cam_x * 0.25)
	var spacing := 520
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x := i * spacing - off + 120
		if x < -80 or x > size.x + 80:
			continue
		# Forte
		draw_rect(Rect2(x - 40, 120, 80, 30), FORT)
		draw_rect(Rect2(x - 40, 120, 80, 3), FORT_DARK)
		for k in range(-40, 40, 10):
			draw_rect(Rect2(x + k, 116, 6, 4), FORT)
		# Farol
		draw_rect(Rect2(x - 6, 70, 12, 50), Color.WHITE)
		draw_rect(Rect2(x - 6, 82, 12, 7), INK)
		draw_rect(Rect2(x - 8, 66, 16, 4), INK)
		draw_rect(Rect2(x - 4, 58, 8, 8), Color("ffe08a"))
		draw_rect(Rect2(x - 5, 55, 10, 3), Color("d64545"))
		# Facho de luz girando.
		var a := sin(_cam_x * 0.01 + i)
		draw_colored_polygon(PackedVector2Array([Vector2(x, 62),
				Vector2(x + 90 * a, 50), Vector2(x + 90 * a, 70)]), Color(1.0, 0.95, 0.6, 0.18))
	draw_rect(Rect2(0, 150, size.x, size.y - 150), Color("2b2a4a"))


## Noite de Carnaval: prédios com janelas acesas, cordões de luz e a multidão pulando.
func _carnaval(size: Vector2) -> void:
	var band := size.y / NIGHT.size()
	for i in NIGHT.size():
		draw_rect(Rect2(0, i * band * 0.6, size.x, size.y), NIGHT[i])
	# Estrelas
	for i in 30:
		var x := (_rand(i, 12) * 7 - floorf(_cam_x * 0.02))
		x = fposmod(x, size.x)
		draw_rect(Rect2(x, _rand(i, 13) % 70, 1, 1), Color(1, 1, 1, 0.6))
	# Prédios da orla
	var off := floorf(_cam_x * 0.2)
	var spacing := 46
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x := i * spacing - off
		var w := 30 + _rand(i, 14) % 14
		var h := 40 + _rand(i, 15) % 60
		draw_rect(Rect2(x, 150 - h, w, h + 30), NIGHT_BUILDING)
		for wy in range(150 - h + 4, 146, 7):
			for wx in range(int(x) + 3, int(x + w) - 3, 6):
				if _rand(wx * 13 + wy, 16) % 3 != 0:
					draw_rect(Rect2(wx, wy, 3, 3), WINDOW_LIT)
	# Cordões de luzinhas piscando.
	off = floorf(_cam_x * 0.5)
	spacing = 120
	first = int(floor(off / spacing)) - 1
	var blink := int(_time * 4.0)
	for i in range(first, first + int(size.x / spacing) + 3):
		var x0 := i * spacing - off
		for k in 20:
			var t := k / 20.0
			var y := 60.0 + sin(t * PI) * 18.0
			draw_rect(Rect2(x0 + t * spacing, y, 6, 1), INK)
			if k % 2 == 0:
				var col: Color = RIBBONS[(k / 2 + i + blink) % RIBBONS.size()]
				draw_rect(Rect2(x0 + t * spacing + 2, y + 1, 2, 2), col)
	# Multidão pulando atrás da corda.
	off = floorf(_cam_x * 0.7)
	for x in range(-8, int(size.x) + 8, 7):
		var wx := int(x + off)
		var hop := absf(sin(_time * 7.0 + wx * 0.7)) * 4.0
		var y := 140.0 - hop - _rand(wx, 17) % 5
		draw_rect(Rect2(x - fmod(off, 7.0), y, 6, 40), CROWD)
		draw_rect(Rect2(x - fmod(off, 7.0) + 1, y - 5, 4, 5), CROWD)
		if _rand(wx, 18) % 4 == 0:   # braço pra cima
			draw_rect(Rect2(x - fmod(off, 7.0) + 5, y - 10, 1, 8), CROWD)


## O morro de granito com o convento branco lá em cima (só cenário, bem longe).
func _convento(x: float, base: float, scale: float) -> void:
	var w := 70.0 * scale
	var h := 60.0 * scale
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - w, base), Vector2(x - w * 0.55, base - h * 0.6), Vector2(x - w * 0.2, base - h),
		Vector2(x + w * 0.25, base - h), Vector2(x + w * 0.6, base - h * 0.55), Vector2(x + w, base)]), GRANITE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x + w * 0.25, base - h), Vector2(x + w * 0.6, base - h * 0.55), Vector2(x + w, base),
		Vector2(x + w * 0.4, base)]), GRANITE_DARK)
	# Mata subindo o morro
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - w * 1.3, base), Vector2(x - w * 0.7, base - h * 0.35), Vector2(x - w * 0.3, base - h * 0.2),
		Vector2(x, base - h * 0.1), Vector2(x + w * 0.5, base - h * 0.25), Vector2(x + w * 1.3, base)]), CLIFF_DARK)
	# Convento
	var top := base - h
	draw_rect(Rect2(x - 14 * scale, top - 10 * scale, 26 * scale, 10 * scale), CONVENT)
	draw_rect(Rect2(x + 6 * scale, top - 18 * scale, 7 * scale, 18 * scale), CONVENT)
	draw_rect(Rect2(x + 5 * scale, top - 20 * scale, 9 * scale, 2 * scale), ROOF)
	draw_rect(Rect2(x - 15 * scale, top - 12 * scale, 28 * scale, 2 * scale), ROOF)
	for k in 3:
		draw_rect(Rect2(x + (-11 + k * 6) * scale, top - 7 * scale, 2 * scale, 3 * scale), WINDOW)
	draw_rect(Rect2(x + 8 * scale, top - 15 * scale, 3 * scale, 3 * scale), WINDOW)


## Baía de Vitória: o morro com o convento do outro lado, os prédios da ilha
## e a Terceira Ponte cruzando a água bem alta.
func _ponte(size: Vector2) -> void:
	_sky(size)
	draw_rect(Rect2(0, 118, size.x, size.y - 118), SEA)
	var woff := floorf(_cam_x * 0.08)
	for j in 6:
		for i in range(-1, int(size.x / 40) + 2):
			var x := i * 40 - fmod(woff + j * 13, 40.0)
			draw_rect(Rect2(x, 122 + j * 9, 9 + j * 2, 1), SEA_LIGHT)
	# Morro da Penha lá longe
	var off := floorf(_cam_x * 0.05)
	var spacing := 640
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		_convento(i * spacing - off + 250, 120.0, 0.9)
	# Prédios da ilha
	off = floorf(_cam_x * 0.12)
	spacing = 28
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		if _rand(i, 20) % 7 < 2:
			continue
		var x := i * spacing - off
		var h := 14 + _rand(i, 21) % 26
		draw_rect(Rect2(x, 120 - h, 20, h), VITORIA[_rand(i, 22) % VITORIA.size()])
		for wy in range(120 - h + 3, 117, 5):
			draw_rect(Rect2(x + 3, wy, 14, 1), WINDOW)
	# A ponte: pista em arco, bem alta no vão central, com pilares até a água.
	off = floorf(_cam_x * 0.25)
	spacing = 900
	var span := 700.0
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x0 := i * spacing - off
		if x0 > size.x or x0 + span < 0:
			continue
		for k in range(0, int(span), 2):
			var t := k / span
			var y := 112.0 - sin(t * PI) * 46.0
			var sx := x0 + k
			if sx < -2 or sx > size.x + 2:
				continue
			draw_rect(Rect2(sx, y, 2, 4), BRIDGE)
			draw_rect(Rect2(sx, y + 4, 2, 1), BRIDGE_DARK)
			if k % 60 == 0:
				draw_rect(Rect2(sx, y + 5, 4, 140 - y), BRIDGE_DARK)


## Subindo para a Penha: mata atlântica, o mar lá embaixo e o convento no topo do morro.
func _penha(size: Vector2) -> void:
	_sky(size)
	draw_rect(Rect2(0, 112, size.x, size.y - 112), SEA)
	var off := floorf(_cam_x * 0.06)
	var spacing := 560
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		_convento(i * spacing - off + 220, 132.0, 1.4)
	_hills(size, 0.3, 140.0, 18.0, 0.02, 4.0, MID, false)
	# Copas das árvores da mata
	off = floorf(_cam_x * 0.5)
	spacing = 22
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x := i * spacing - off
		var y := 150.0 - _rand(i, 23) % 14
		var r := 9.0 + _rand(i, 24) % 5
		draw_rect(Rect2(x - 1, y, 3, 40), TRUNK)
		draw_circle(Vector2(x, y), r, TREE)
		draw_circle(Vector2(x - 3, y - 3), r * 0.5, NEAR)
	draw_rect(Rect2(0, 158, size.x, size.y - 158), TREE)


## Garoa fininha caindo na diagonal.
func _garoa(size: Vector2, amount: int) -> void:
	for i in amount:
		var x := fposmod(_rand(i, 30) * 1.3 - _time * 40.0 - _cam_x * 0.9, size.x + 20.0) - 10.0
		var y := fposmod(_rand(i, 31) * 0.7 + _time * 160.0, size.y + 20.0) - 10.0
		draw_rect(Rect2(x, y, 1, 4), RAIN)


## Fileira de prédios de concreto com janelinhas (o "mar de prédios" de longe).
func _city(size: Vector2, factor: float, base: float, col: Color, win: Color, salt: int) -> void:
	var off := floorf(_cam_x * factor)
	var spacing := 24
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x := i * spacing - off
		var w := 16 + _rand(i, salt) % 10
		var h := 20 + _rand(i, salt + 1) % 50
		draw_rect(Rect2(x, base - h, w, h + 60), col)
		if _rand(i, salt + 2) % 4 == 0:
			draw_rect(Rect2(x + w / 2.0, base - h - 8, 1, 8), col)   # antena
		for wy in range(int(base - h) + 3, int(base) - 2, 5):
			for wx in range(int(x) + 2, int(x + w) - 2, 4):
				if _rand(wx * 7 + wy, salt + 3) % 3 == 0:
					draw_rect(Rect2(wx, wy, 2, 2), win)


## Marginal: céu cinza, prédios ao longe, o rio e a outra pista cheia de faróis.
func _marginal(size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), GRAY_SKY)
	draw_rect(Rect2(0, 80, size.x, size.y - 80), GRAY_SKY_LOW)
	_city(size, 0.08, 112.0, SMOG, GRAY_SKY_LOW, 40)
	_city(size, 0.15, 122.0, CONCRETE, Color("c9ccd2"), 44)
	# Pista do outro lado do rio, com os faróis acesos parados.
	draw_rect(Rect2(0, 122, size.x, 6), Color("4a4a56"))
	var off := floorf(_cam_x * 0.2)
	for i in range(int(off / 10) - 1, int((off + size.x) / 10) + 2):
		var x := i * 10 - off
		if _rand(i, 48) % 3 != 0:
			draw_rect(Rect2(x, 124, 3, 2), Color("d64545") if _rand(i, 49) % 2 == 0 else Color("fff3b0"))
	# O rio
	draw_rect(Rect2(0, 128, size.x, size.y - 128), RIVER)
	var woff := floorf(_cam_x * 0.3)
	for j in 5:
		for i in range(-1, int(size.x / 44) + 2):
			var x := i * 44 - fmod(woff + j * 17, 44.0)
			draw_rect(Rect2(x, 132 + j * 8, 10, 1), RIVER_LIGHT)
	# Placas verdes da via expressa
	off = floorf(_cam_x * 0.5)
	var spacing := 360
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x := i * spacing - off + 100
		draw_rect(Rect2(x, 70, 2, 80), Color("5c6670"))
		draw_rect(Rect2(x + 40, 70, 2, 80), Color("5c6670"))
		draw_rect(Rect2(x - 4, 60, 50, 16), INK)
		draw_rect(Rect2(x - 3, 61, 48, 14), Color("2a7a3a"))
		draw_rect(Rect2(x + 2, 65, 22, 2), Color.WHITE)
		draw_rect(Rect2(x + 2, 69, 30, 2), Color.WHITE)
		draw_rect(Rect2(x + 36, 64, 5, 7), Color.WHITE)
	_garoa(size, 40)


## Faria Lima: torres de vidro espelhado com os caixilhos escuros.
func _farialima(size: Vector2) -> void:
	_sky(size)
	_city(size, 0.08, 120.0, Color("9ab3c8"), Color("c9d6e0"), 50)
	var off := floorf(_cam_x * 0.3)
	var spacing := 70
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x := i * spacing - off + _rand(i, 51) % 14
		var w := 40 + _rand(i, 52) % 16
		var top := 20 + _rand(i, 53) % 50
		var glass: Color = TOWER_GLASS[_rand(i, 54) % TOWER_GLASS.size()]
		draw_rect(Rect2(x - 1, top - 1, w + 2, size.y), TOWER_FRAME)
		draw_rect(Rect2(x, top, w, size.y), glass)
		for gy in range(top + 6, int(size.y), 6):
			draw_rect(Rect2(x, gy, w, 1), TOWER_FRAME)
		for gx in range(int(x) + 8, int(x + w), 8):
			draw_rect(Rect2(gx, top, 1, size.y), TOWER_FRAME)
		# Reflexo do céu na diagonal
		for k in 12:
			draw_rect(Rect2(x + 4 + k * 2, top + 4 + k * 3, 3, 2), Color(1, 1, 1, 0.25))
		if _rand(i, 55) % 2 == 0:
			draw_rect(Rect2(x + w / 2.0 - 1, top - 10, 2, 10), TOWER_FRAME)   # mastro
	# Arvorezinhas do canteiro
	off = floorf(_cam_x * 0.6)
	for i in range(int(off / 48) - 1, int((off + size.x) / 48) + 2):
		var x := i * 48 - off
		draw_rect(Rect2(x, 150, 2, 20), TRUNK)
		draw_circle(Vector2(x + 1, 148), 7.0, LEAF)


## Terraço no fim da tarde: o mar de prédios até o horizonte, antenas e garoa.
func _terraco(size: Vector2) -> void:
	var band := size.y / DUSK_SKY.size()
	for i in DUSK_SKY.size():
		draw_rect(Rect2(0, i * band * 0.7, size.x, size.y), DUSK_SKY[i])
	draw_circle(Vector2(240.0 - floorf(_cam_x * 0.02), 104.0), 14.0, Color("ffd08a"))
	_city(size, 0.06, 118.0, Color("4a4466"), SKYLINE_LIT, 60)
	_city(size, 0.15, 138.0, SKYLINE, SKYLINE_LIT, 64)
	# Torres de antena com luz vermelha piscando
	var off := floorf(_cam_x * 0.1)
	var spacing := 300
	var first := int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x := i * spacing - off + 160
		for k in 10:
			draw_rect(Rect2(x - 4 + k * 0.4, 30 + k * 9, 8 - k * 0.8, 1), Color("2b2640"))
		draw_rect(Rect2(x - 1, 30, 2, 90), Color("2b2640"))
		if int(_time * 2.0 + i) % 2 == 0:
			draw_rect(Rect2(x - 1, 27, 3, 3), Color("ff4a4a"))
	_garoa(size, 60)
