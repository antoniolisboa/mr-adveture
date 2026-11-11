extends Node2D
## Monta uma fase a partir do mapa em texto (ver levels/minas_gerais_1.gd).

const Art := preload("res://scripts/art.gd")
const Background := preload("res://scripts/background.gd")
const Player := preload("res://scripts/player.gd")
const Queijo := preload("res://scripts/queijo.gd")
const PowerBox := preload("res://scripts/power_box.gd")
const Pickup := preload("res://scripts/pickup.gd")
const Checkpoint := preload("res://scripts/checkpoint.gd")
const Goal := preload("res://scripts/goal.gd")
const BossArena := preload("res://scripts/boss_arena.gd")
const Xicara := preload("res://scripts/xicara.gd")
const ExitSign := preload("res://scripts/exit_sign.gd")
const Pombo := preload("res://scripts/pombo.gd")
const Frescobolista := preload("res://scripts/frescobolista.gd")
const Pimenta := preload("res://scripts/pimenta.gd")
const Foliao := preload("res://scripts/foliao.gd")
const Elevator := preload("res://scripts/elevator.gd")
const Robalo := preload("res://scripts/robalo.gd")
const Gaivota := preload("res://scripts/gaivota.gd")
const PatineteMau := preload("res://scripts/patinete_mau.gd")
const Coachinho := preload("res://scripts/coachinho.gd")
const Carro := preload("res://scripts/carro.gd")
const Ilhota := preload("res://scripts/ilhota.gd")

## Inimigos do Nordeste: caractere do mapa -> script (todos baseados em scripts/walker.gd).
const NE_ENEMIES := {
	"U": preload("res://scripts/sombrinha_mau.gd"),
	"D": preload("res://scripts/rojao.gd"),
	"N": preload("res://scripts/sanfona_mau.gd"),
	"B": preload("res://scripts/buggy_mau.gd"),
	"Z": preload("res://scripts/caju.gd"),
	"M": preload("res://scripts/piadista.gd"),
	"I": preload("res://scripts/regueiro.gd"),
	"u": preload("res://scripts/onda_calor.gd"),
	"c": preload("res://scripts/calango.gd"),
	"o": preload("res://scripts/ourico.gd"),
	"p": preload("res://scripts/baiacu.gd"),
	"k": preload("res://scripts/caranguejo.gd"),
}

## Chão dos temas do Nordeste: tema -> [bloco de dentro, bloco da superfície].
const THEME_TILES := {
	"olinda": ["ground", "cobble_top"],
	"altose": ["ground", "cobble_top"],
	"arraial": ["ground", "terra_top"],
	"dunas": ["sand", "sand"],
	"lencois": ["duna", "duna_top"],
	"saoluis": ["ground", "cobble_top"],
	"boi": ["ground", "terra_top"],
	"teresina": ["ground", "asfalto_top"],
	"capivara": ["pedra_top", "pedra_top"],
	"estaiada": ["concreto", "concreto_top"],
	"maragogi": ["sand", "coral_top"],
	"gales": ["sand", "coral_top"],
	"atalaia": ["ground", "calcadao_top"],
	"passarela": ["tabua", "tabua_top"],
	"jangada": ["sand", "sand"],
	"beiramar": ["ground", "calcadao_top"],
	"morrocareca": ["sand", "sand"],
	"parquedopovo": ["ground", "terra_top"],
}

const TILE := 16
const SOLID := "#=X"

var rows: Array = []
var cols := 0
var total_biscoitos := 0
var player: CharacterBody2D
var theme := "serra"
var goal_style := "casinha"
var boss_id := "trem"
var elevator_rise := 4
var lagoon := false             # lagoa azul no fundo dos buracos (Lençóis Maranhenses)
var heat_on := false            # sol de meio-dia (Piauí): barra de calor
var water_row := -1             # linha onde começa a água (-1 = sem água)
var tide := 0.0                 # maré: quantos blocos a água baixa
var tide_period := 12.0
var _time := 0.0


func build(data) -> void:
	rows = data.ROWS
	theme = data.THEME
	var consts: Dictionary = data.get_script_constant_map()
	goal_style = consts.get("GOAL", "casinha")
	boss_id = consts.get("BOSS", "trem")
	elevator_rise = consts.get("ELEVATOR_RISE", 4)
	heat_on = consts.get("HEAT", false)
	lagoon = consts.get("LAGOON", false)
	water_row = consts.get("WATER_ROW", -1)
	tide = consts.get("TIDE", 0.0)
	tide_period = consts.get("TIDE_PERIOD", 12.0)
	for r in rows:
		cols = maxi(cols, r.length())

	var bg_layer := CanvasLayer.new()
	bg_layer.layer = -10
	var bg := Background.new()
	bg.theme = theme
	bg_layer.add_child(bg)
	add_child(bg_layer)

	_build_collision()
	_spawn_entities()
	if water_row >= 0:
		var water := Node2D.new()
		water.z_index = 6
		water.draw.connect(_draw_water.bind(water))
		add_child(water)
		set_meta("water_node", water)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if water_row >= 0:
		get_meta("water_node").queue_redraw()


## Altura (em pixels) da superfície da água agora; INF = fase sem água.
## Com maré, a água desce até "tide" blocos e volta a subir.
func water_top() -> float:
	if water_row < 0:
		return INF
	var low := 0.5 - 0.5 * cos(_time * TAU / tide_period)
	return (water_row + tide * low) * TILE


func _draw_water(node: Node2D) -> void:
	var top := water_top()
	var h := rows.size() * TILE - top + 64
	node.draw_rect(Rect2(0, top, cols * TILE, h), Color(0.25, 0.75, 0.85, 0.38))
	var cam := get_viewport().get_camera_2d()
	var cx := cam.get_screen_center_position().x if cam else 160.0
	var x0 := int(cx - 176.0)
	for x in range(x0 - x0 % 8, x0 + 360, 8):
		var wave := 1.0 if int(x / 8.0 + _time * 3.0) % 2 == 0 else 0.0
		node.draw_rect(Rect2(x, top - wave, 6, 1), Color(0.85, 1.0, 1.0, 0.8))


func cell(x: int, y: int) -> String:
	if y < 0 or y >= rows.size():
		return "."
	var r: String = rows[y]
	if x < 0 or x >= r.length():
		return "."
	return r[x]


func is_solid(x: int, y: int) -> bool:
	return SOLID.contains(cell(x, y))


func _draw() -> void:
	if lagoon:
		var bottom := rows.size() - 1
		for x in cols:
			if not is_solid(x, bottom):
				draw_rect(Rect2(x * TILE, bottom * TILE - 4, TILE, TILE + 40), Color("3fa8d0"))
				draw_rect(Rect2(x * TILE, bottom * TILE - 4, TILE, 1), Color("bfefff"))
	for y in rows.size():
		for x in cols:
			var tex_name := ""
			match cell(x, y):
				"#":
					tex_name = _ground_tile(x, y)
				"=":
					tex_name = "stone"
				"X":
					tex_name = "crate"
			if tex_name != "":
				draw_texture(Art.tex(tex_name), Vector2(x * TILE, y * TILE))


## Visual do chão conforme o tema: grama, calçamento de pedra ou rocha da mina.
func _ground_tile(x: int, y: int) -> String:
	if THEME_TILES.has(theme):
		var t: Array = THEME_TILES[theme]
		return t[0] if cell(x, y - 1) == "#" else t[1]
	match theme:
		"mina":
			return "rock"
		"praia", "farol":
			return "sand"
		"ponte":
			return "concreto" if cell(x, y - 1) == "#" else "concreto_top"
		"marginal":
			return "concreto" if cell(x, y - 1) == "#" else "pista_top"
		"farialima":
			return "concreto" if cell(x, y - 1) == "#" else "ciclovia_top"
		"terraco":
			return "concreto" if cell(x, y - 1) == "#" else "deck_top"
	if cell(x, y - 1) == "#":
		return "ground"
	match theme:
		"cidade", "pelourinho", "baia":
			return "cobble_top"
		"carnaval":
			return "asfalto_top"
		"calcadao":
			return "calcadao_top"
	return "ground_top"


## Junta os blocos sólidos de cada linha em retângulos de colisão.
func _build_collision() -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	add_child(body)
	for y in rows.size():
		var x := 0
		while x < cols:
			if is_solid(x, y):
				var start := x
				while x < cols and is_solid(x, y):
					x += 1
				_add_rect(body, Rect2(start * TILE, y * TILE, (x - start) * TILE, TILE))
			else:
				x += 1
	# Paredes invisíveis nas bordas da fase.
	var h := (rows.size() + 8) * TILE
	_add_rect(body, Rect2(-TILE, -4 * TILE, TILE, h))
	_add_rect(body, Rect2(cols * TILE, -4 * TILE, TILE, h))


func _add_rect(body: StaticBody2D, r: Rect2) -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.position + r.size / 2.0
	body.add_child(cs)


func _spawn_entities() -> void:
	var start := Vector2(32, 32)
	var arena := {}
	for y in rows.size():
		for x in cols:
			var feet := Vector2(x * TILE + 8, (y + 1) * TILE)
			var center := Vector2(x * TILE + 8, y * TILE + 8)
			match cell(x, y):
				"P":
					start = feet
				"Q":
					_spawn(Queijo.new(), feet)
				"H":
					_spawn(Xicara.new(), feet)
				"V":
					_spawn(Pombo.new(), feet)
				"J":
					_spawn(Frescobolista.new(), feet)
				"K":
					_spawn(Pimenta.new(), feet)
				"O":
					_spawn(Foliao.new(), feet)
				"R":
					_spawn(Robalo.new(), feet)
				"W":
					_spawn(Gaivota.new(), feet)
				"S":
					_spawn(PatineteMau.new(), feet)
				"Y":
					_spawn(Coachinho.new(), feet)
				"A":
					_spawn(Carro.new(), Vector2(x * TILE, y * TILE))
				"L":
					var il := Ilhota.new()
					il.phase = float(x % 5) * 0.7
					_spawn(il, Vector2(x * TILE, y * TILE))
				"E":
					var e := Elevator.new()
					e.rise_tiles = elevator_rise
					_spawn(e, Vector2(x * TILE, y * TILE + 8))
				"F":
					_spawn(ExitSign.new(), feet)
				"?":
					_spawn(PowerBox.new(), Vector2(x * TILE, y * TILE))
				"C":
					_spawn(Checkpoint.new(), feet)
				"G":
					var goal := Goal.new()
					goal.style = goal_style
					_spawn(goal, feet)
				"[":
					arena["left"] = x
				"]":
					arena["right"] = x
				"T":
					arena["boss"] = feet
					arena["floor_row"] = y
				var ch when NE_ENEMIES.has(ch):
					_spawn(NE_ENEMIES[ch].new(), feet)
				"b":
					total_biscoitos += 1
					if not Game.collected.has(Vector2i(x, y)):
						var p := Pickup.new()
						p.cell = Vector2i(x, y)
						_spawn(p, center)

	player = Player.new()
	player.position = start if Game.checkpoint == Vector2.INF else Game.checkpoint
	player.fall_limit = rows.size() * TILE + 48
	player.camera_limits = Rect2i(0, 0, cols * TILE, rows.size() * TILE)
	add_child(player)

	if arena.has("left") and arena.has("right") and arena.has("boss"):
		var a := BossArena.new()
		a.level = self
		a.left_col = arena["left"]
		a.right_col = arena["right"]
		a.boss_pos = arena["boss"]
		a.gate_bottom_row = arena["floor_row"]
		a.boss_id = boss_id
		add_child(a)


func _spawn(node: Node2D, pos: Vector2) -> void:
	node.position = pos
	add_child(node)
