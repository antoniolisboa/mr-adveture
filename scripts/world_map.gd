extends Node2D
## Mapa do Brasil: escolha do estado e da fase.
## Estados prontos aparecem em amarelo, concluídos em verde e os ainda não feitos em cinza.

signal chosen(state_data, fase: int)
signal back

const States := preload("res://levels/states.gd")
const PixelText := preload("res://scripts/pixel_text.gd")
const Art := preload("res://scripts/art.gd")

const SEA := Color("1f5f8f")
const LAND := Color("5bbf3a")
const LAND_EDGE := Color("2b1d2e")
const LOCKED := Color("6b7280")
const READY := Color("f7d038")
const DONE := Color("2a9d4a")
const PANEL := Color(0.1, 0.07, 0.12, 0.8)

const MAP_SCALE := 3.5
const MAP_ORIGIN := Vector2(8, 22)

var selected := 0      # índice em _playable
var fase := 0
var _playable: Array = []
var _t := 0.0
var _labels := {}


func _ready() -> void:
	for s in States.STATES:
		if s["data"] != null:
			_playable.append(s)
	_playable.sort_custom(func(a, b): return a["lon"] < b["lon"])

	_label("title", Vector2(160, 4), 1, Color.WHITE).text = "ESCOLHA O ESTADO"
	_label("name", Vector2(166, 28), 1, READY)
	_label("info", Vector2(166, 42), 1, Color.WHITE)
	_label("fase", Vector2(166, 84), 1, Color("fbe3a0"))
	_label("done", Vector2(166, 110), 1, Color("9be38a"))
	_label("help", Vector2(166, 132), 1, Color.WHITE).text = \
			"ESQ/DIR: ESTADO\nCIMA/BAIXO: FASE\nENTER: JOGAR   ESC: VOLTAR"
	var ready_count := _playable.size()
	_labels["title"].align = 1
	_label("count", Vector2(314, 170), 1, Color.WHITE).text = \
			"%d DE %d ESTADOS PRONTOS" % [ready_count, States.STATES.size()]
	_labels["count"].align = 2
	_label("objects", Vector2(6, 170), 1, Color("fbe3a0")).text = "OBJETOS:"
	_refresh()


func _label(key: String, pos: Vector2, px: int, col: Color) -> Node2D:
	var t := PixelText.new()
	t.position = pos
	t.pixel = px
	t.color = col
	add_child(t)
	_labels[key] = t
	return t


func _state() -> Dictionary:
	return _playable[selected]


func _refresh() -> void:
	var s := _state()
	var data = s["data"]
	_labels["name"].text = s["name"]
	var region := States.region_of(s["id"])
	var region_done := 0
	for id in region["states"]:
		if Game.completed.has(id):
			region_done += 1
	_labels["info"].text = "FASES: %d\nITEM: %s\nBOSS: %s\nREGIÃO %s: %d DE %d" % [data.LEVELS.size(),
			data.POWER_NAME, data.BOSS_NAME, region["name"], region_done, region["states"].size()]
	_labels["fase"].text = "FASE %d: %s" % [fase + 1, data.LEVELS[fase].NAME]
	_labels["done"].text = "CONCLUÍDO!" if Game.completed.has(s["id"]) else ""
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	if _t < 0.2:
		return   # o Enter da tela anterior não vale aqui
	if Input.is_action_just_pressed("left"):
		selected = (selected - 1 + _playable.size()) % _playable.size()
		fase = 0
		_refresh()
		Sfx.play("bump")
	elif Input.is_action_just_pressed("right"):
		selected = (selected + 1) % _playable.size()
		fase = 0
		_refresh()
		Sfx.play("bump")
	elif Input.is_action_just_pressed("menu_up") or Input.is_action_just_pressed("menu_down"):
		var n: int = _state()["data"].LEVELS.size()
		fase = (fase + (1 if Input.is_action_just_pressed("menu_down") else -1) + n) % n
		_refresh()
	elif Input.is_action_just_pressed("confirm"):
		chosen.emit(_state()["data"], fase)
		return
	elif Input.is_action_just_pressed("back"):
		back.emit()
		return
	queue_redraw()


func _to_map(lon: float, lat: float) -> Vector2:
	return (MAP_ORIGIN + Vector2(lon + 75.0, 5.5 - lat) * MAP_SCALE).round()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), SEA)
	var pts := PackedVector2Array()
	for p in States.OUTLINE:
		pts.append(_to_map(p.x, p.y))
	draw_colored_polygon(pts, LAND)
	pts.append(pts[0])
	draw_polyline(pts, LAND_EDGE, 1.0)

	var current_id: String = _state()["id"]
	for s in States.STATES:
		var p := _to_map(s["lon"], s["lat"])
		var col := LOCKED
		if s["data"] != null:
			col = DONE if Game.completed.has(s["id"]) else READY
		draw_rect(Rect2(p - Vector2(1, 1), Vector2(3, 3)), LAND_EDGE)
		draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), col)
		if s["id"] == current_id and int(_t * 4.0) % 2 == 0:
			draw_rect(Rect2(p - Vector2(4, 4), Vector2(9, 9)), Color.WHITE, false, 1.0)

	draw_rect(Rect2(158, 20, 156, 142), PANEL)
	# Coleção de objetos do caramelo: apagado = região ainda não completa.
	for i in States.REGIONS.size():
		var r: Dictionary = States.REGIONS[i]
		var pos := Vector2(42 + i * 14, 166)
		var got: bool = Game.objects.has(r["id"])
		draw_rect(Rect2(pos - Vector2(1, 1), Vector2(14, 14)), Color(0, 0, 0, 0.35))
		draw_texture(Art.tex(r["sprite"]), pos, Color.WHITE if got else Color(0, 0, 0, 0.45))
