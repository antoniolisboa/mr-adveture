extends AnimatableBody2D
## Carro no trânsito parado da Marginal: anda um pouquinho, para, anda de novo.
## Dá para subir no teto. Ocupa 2 blocos de largura; a origem fica no canto
## superior esquerdo do bloco onde ele foi posto no mapa.

const INK := Color("2b1d2e")
const GLASS := Color("9fd0e8")
const TIRE := Color("1f1a22")
const LIGHT := Color("fff3b0")
const BRAKE := Color("d64545")
const COLORS := [Color("d64545"), Color("f2f2f2"), Color("2b5fb4"), Color("9aa4b0"), Color("f7d038"), Color("2a2a30")]

const STEP := 40.0             # quanto anda de cada vez
const MOVE_TIME := 1.2
const WAIT_TIME := 1.8

var _start := Vector2.ZERO
var _t := 0.0
var _color: Color
var _braking := true


func _ready() -> void:
	collision_layer = 1
	sync_to_physics = true
	_start = position
	_color = COLORS[absi(int(position.x / 16.0)) % COLORS.size()]
	_t = fmod(position.x * 0.13, MOVE_TIME + WAIT_TIME)
	for r in [Rect2(0, 6, 32, 10), Rect2(6, -2, 20, 8)]:
		var cs := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = r.size
		cs.shape = rect
		cs.position = r.position + r.size / 2.0
		add_child(cs)


func _physics_process(delta: float) -> void:
	_t += delta
	# Anda STEP para a frente, para; anda STEP para trás (manobrando), para.
	var cycle := (MOVE_TIME + WAIT_TIME) * 2.0
	var c := fmod(_t, cycle)
	var k := 0.0
	var half := MOVE_TIME + WAIT_TIME
	if c < MOVE_TIME:
		k = smoothstep(0.0, 1.0, c / MOVE_TIME)
	elif c < half:
		k = 1.0
	elif c < half + MOVE_TIME:
		k = 1.0 - smoothstep(0.0, 1.0, (c - half) / MOVE_TIME)
	_braking = not (c < MOVE_TIME or (c >= half and c < half + MOVE_TIME))
	position = (_start + Vector2(STEP * k, 0)).round()
	queue_redraw()


func _draw() -> void:
	# Teto e vidros
	draw_rect(Rect2(5, -3, 22, 10), INK)
	draw_rect(Rect2(6, -2, 20, 8), _color)
	draw_rect(Rect2(8, 0, 7, 5), GLASS)
	draw_rect(Rect2(17, 0, 7, 5), GLASS)
	# Lataria
	draw_rect(Rect2(-1, 5, 34, 9), INK)
	draw_rect(Rect2(0, 6, 32, 7), _color)
	draw_rect(Rect2(0, 9, 32, 1), Color(0, 0, 0, 0.2))
	draw_rect(Rect2(29, 7, 3, 2), LIGHT)
	draw_rect(Rect2(0, 7, 2, 2), BRAKE if _braking else Color("8e1a10"))
	# Rodas
	for x in [7.0, 25.0]:
		draw_circle(Vector2(x, 14), 3.0, INK)
		draw_circle(Vector2(x, 14), 2.0, TIRE)
