extends CanvasLayer
## Interface na tela: biscoitos, poder atual, nome da fase e mensagens.

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")
const Powers := preload("res://scripts/powers.gd")

var _biscoitos: Node2D
var _power: Node2D
var _banner: Node2D
var _panel: ColorRect
var _message: Node2D
var _boss_name: Node2D
var _boss_bar_bg: ColorRect
var _boss_bar: ColorRect
var _object: Sprite2D           # objeto do caramelo ganho ao completar a região
var _meter: Node2D              # barra de fôlego (Alagoas) ou de calor (Piauí)
var _meter_label: Node2D


func _ready() -> void:
	layer = 10

	var icon := Sprite2D.new()
	icon.texture = Art.tex("biscoito")
	icon.centered = false
	icon.position = Vector2(2, -2)
	add_child(icon)

	_biscoitos = _text(Vector2(18, 1))
	_power = _text(Vector2(317, 1))
	_power.align = 2
	_power.color = Color("fbe3a0")

	_banner = _text(Vector2(160, 60))
	_banner.align = 1
	_banner.pixel = 2
	_banner.visible = false

	_panel = ColorRect.new()
	_panel.color = Color(0.1, 0.07, 0.12, 0.85)
	_panel.position = Vector2(30, 48)
	_panel.size = Vector2(260, 84)
	_panel.visible = false
	add_child(_panel)
	_message = _text(Vector2(160, 58))
	_message.align = 1
	_message.visible = false

	_boss_name = _text(Vector2(160, 160))
	_boss_name.align = 1
	_boss_name.text = "O TREM"
	_boss_bar_bg = ColorRect.new()
	_boss_bar_bg.color = Color("2b1d2e")
	_boss_bar_bg.position = Vector2(110, 171)
	_boss_bar_bg.size = Vector2(100, 6)
	add_child(_boss_bar_bg)
	_boss_bar = ColorRect.new()
	_boss_bar.color = Color("d64545")
	_boss_bar.position = Vector2(111, 172)
	_boss_bar.size = Vector2(98, 4)
	add_child(_boss_bar)
	show_boss(-1, 0)

	_meter_label = _text(Vector2(2, 12))
	_meter = Node2D.new()
	_meter.draw.connect(_draw_meter)
	add_child(_meter)

	Game.hud_changed.connect(refresh)
	Game.boss_hp_changed.connect(show_boss)
	Game.announce.connect(show_banner)
	refresh()


func _text(pos: Vector2) -> Node2D:
	var t := PixelText.new()
	t.position = pos
	add_child(t)
	return t


func _process(_delta: float) -> void:
	_meter_label.visible = Game.heat > 0.01 or Game.air < 0.999
	_meter_label.text = "CALOR" if Game.heat > 0.01 else "FÔLEGO"
	_meter.queue_redraw()


func _draw_meter() -> void:
	if not _meter_label.visible:
		return
	var heat := Game.heat > 0.01
	var v := Game.heat if heat else Game.air
	var col := Color("f07a2a") if heat else Color("7fd0f0")
	if (heat and v > 0.75) or (not heat and v < 0.3):
		col = Color("d64545") if int(Time.get_ticks_msec() / 150) % 2 == 0 else col
	_meter.draw_rect(Rect2(30, 13, 52, 6), Color("2b1d2e"))
	_meter.draw_rect(Rect2(31, 14, 50.0 * clampf(v, 0.0, 1.0), 4), col)


func refresh() -> void:
	_biscoitos.text = "%02d/%02d" % [Game.biscoitos, Game.total_biscoitos]
	_power.text = Powers.POWERS[Game.power]["hud"] if Game.power != "" else ""


func show_boss(hp: int, max_hp: int) -> void:
	var on := hp >= 0
	_boss_name.visible = on
	_boss_bar_bg.visible = on
	_boss_bar.visible = on
	if on:
		_boss_name.text = Game.boss_name
		_boss_bar.size.x = 98.0 * hp / max_hp


func show_banner(text: String) -> void:
	_banner.text = text
	_banner.visible = true
	await get_tree().create_timer(2.5).timeout
	if is_instance_valid(_banner):
		_banner.visible = false


func hide_message() -> void:
	_panel.visible = false
	_message.visible = false
	if _object:
		_object.visible = false


func show_message(text: String) -> void:
	_banner.visible = false
	_panel.visible = true
	_message.visible = true
	_message.text = text
	# O painel cresce conforme o número de linhas e fica centrado na tela.
	var lines := text.count("\n") + 1
	var h := lines * PixelText.LINE_HEIGHT + 18
	var extra := 22 if _object and _object.visible else 0
	_panel.size.y = h + extra
	_panel.position.y = roundf((180 - h - extra) / 2.0)
	_message.position.y = _panel.position.y + 8 + extra
	if extra > 0:
		_object.position = Vector2(160, _panel.position.y + 14)


## Mostra o objeto do caramelo em cima da mensagem, girando devagar de alegria.
func show_object(sprite: String) -> void:
	if _object == null:
		_object = Sprite2D.new()
		_object.scale = Vector2(2, 2)
		add_child(_object)
	_object.texture = Art.tex(sprite)
	_object.visible = true
	var tw := create_tween().set_loops()
	tw.tween_property(_object, "rotation", 0.25, 0.4)
	tw.tween_property(_object, "rotation", -0.25, 0.4)
