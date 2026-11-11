extends AnimatableBody2D
## Capivara do Parque Barigui (Paraná): não liga para nada. Anda bem devagar de um
## lado para o outro e dá para subir nas costas dela, como uma plataforma.
## Não machuca e não morre. Ocupa 2 blocos; a origem fica no canto de cima do bloco.

const INK := Color("2b1d2e")
const FUR := Color("8a6a4a")
const FUR_DARK := Color("6a4e36")
const FUR_LIGHT := Color("a8865e")
const ORANGE := Color("f07a2a")

const RANGE := 40.0
const SPEED := 12.0

var _start := Vector2.ZERO
var _x := 0.0
var _dir := 1.0
var _t := 0.0
var _orange := false            # algumas capivaras andam com uma laranja na cabeça


func _ready() -> void:
	collision_layer = 1
	sync_to_physics = true
	_start = position
	_orange = int(position.x / 16.0) % 3 == 0
	_dir = 1.0 if int(position.x / 16.0) % 2 == 0 else -1.0
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 10)
	cs.shape = rect
	cs.position = Vector2(16, 10)
	add_child(cs)


func _physics_process(delta: float) -> void:
	_t += delta
	_x += _dir * SPEED * delta
	if absf(_x) > RANGE:
		_x = clampf(_x, -RANGE, RANGE)
		_dir = -_dir
	position = (_start + Vector2(_x, 0)).round()
	queue_redraw()


func _draw() -> void:
	var f := _dir
	var step := 1.0 if int(_t * 4.0) % 2 == 0 else 0.0
	# Pernas curtinhas
	for lx in [6.0, 11.0, 21.0, 26.0]:
		var up := step if int(lx) % 2 == 0 else 1.0 - step
		draw_rect(Rect2(lx - 1, 13, 4, 3 - up), INK)
		draw_rect(Rect2(lx, 13, 2, 2 - up), FUR_DARK)
	# Corpo de barril
	draw_rect(Rect2(1, 4, 30, 10), INK)
	draw_rect(Rect2(2, 5, 28, 8), FUR)
	draw_rect(Rect2(3, 5, 26, 2), FUR_LIGHT)
	# Cabeça quadradona para o lado que anda
	var hx := 26.0 if f > 0 else -2.0
	draw_rect(Rect2(hx - 1, 2, 10, 10), INK)
	draw_rect(Rect2(hx, 3, 8, 8), FUR)
	draw_rect(Rect2(hx + (6 if f > 0 else 0), 7, 2, 3), FUR_DARK)     # focinho
	draw_rect(Rect2(hx + (3 if f > 0 else 3), 5, 2, 1), INK)           # olho sonolento
	draw_rect(Rect2(hx + (1 if f > 0 else 5), 1, 2, 2), FUR_DARK)      # orelhinha
	if _orange:
		draw_rect(Rect2(14, -2, 6, 6), INK)
		draw_rect(Rect2(15, -1, 4, 4), ORANGE)
		draw_rect(Rect2(16, -3, 2, 2), Color("3c8d2f"))
