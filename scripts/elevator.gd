extends AnimatableBody2D
## Plataforma que sobe e desce, como a cabine do Elevador Lacerda.
## A origem fica no canto superior esquerdo da posição de baixo.

const INK := Color("2b1d2e")
const FLOOR := Color("9aa4b0")
const FLOOR_DARK := Color("5c6670")
const STRIPE := Color("f7d038")
const CABLE := Color("2b1d2e")

const WIDTH := 32
const TRAVEL_TIME := 2.4       # segundos para subir (ou descer)
const WAIT_TIME := 1.0         # parada em cima e embaixo

var rise_tiles := 4            # quantos blocos sobe
var _bottom := Vector2.ZERO
var _t := 0.0


func _ready() -> void:
	collision_layer = 1
	sync_to_physics = true
	_bottom = position
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(WIDTH, 8)
	cs.shape = rect
	cs.position = Vector2(WIDTH / 2.0, 4)
	cs.one_way_collision = true      # dá para subir nela pulando por baixo
	add_child(cs)


func _physics_process(delta: float) -> void:
	_t += delta
	var cycle := (TRAVEL_TIME + WAIT_TIME) * 2.0
	var c := fmod(_t, cycle)
	var k := 0.0                     # 0 = embaixo, 1 = em cima
	if c < WAIT_TIME:
		k = 0.0
	elif c < WAIT_TIME + TRAVEL_TIME:
		k = smoothstep(0.0, 1.0, (c - WAIT_TIME) / TRAVEL_TIME)
	elif c < WAIT_TIME * 2.0 + TRAVEL_TIME:
		k = 1.0
	else:
		k = 1.0 - smoothstep(0.0, 1.0, (c - WAIT_TIME * 2.0 - TRAVEL_TIME) / TRAVEL_TIME)
	position = (_bottom - Vector2(0, rise_tiles * 16.0 * k)).round()
	queue_redraw()


func _draw() -> void:
	# Cabos até o topo do percurso.
	var top := _bottom.y - rise_tiles * 16.0 - 24.0 - position.y
	draw_rect(Rect2(4, top, 1, -top), CABLE)
	draw_rect(Rect2(WIDTH - 5, top, 1, -top), CABLE)
	draw_rect(Rect2(0, 0, WIDTH, 8), INK)
	draw_rect(Rect2(1, 1, WIDTH - 2, 6), FLOOR)
	draw_rect(Rect2(1, 5, WIDTH - 2, 2), FLOOR_DARK)
	for x in range(2, WIDTH - 2, 6):
		draw_rect(Rect2(x, 1, 3, 2), STRIPE)
