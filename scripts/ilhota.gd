extends AnimatableBody2D
## Ilhota de areia no meio da lagoa (Lençóis Maranhenses): a água sobe e cobre a
## ilhota, depois baixa e ela volta. Pisca antes de sumir. A origem é o canto de cima.

const Art := preload("res://scripts/art.gd")

const UP_TIME := 3.0
const BLINK_TIME := 0.9
const DOWN_TIME := 2.0

var phase := 0.0
var _t := 0.0
var _shape: CollisionShape2D
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 8)
	_shape.shape = rect
	_shape.position = Vector2(8, 4)
	_shape.one_way_collision = true
	add_child(_shape)
	_sprite = Sprite2D.new()
	_sprite.texture = Art.tex("ilhota")
	_sprite.centered = false
	add_child(_sprite)
	_t = phase


func _physics_process(delta: float) -> void:
	_t = fmod(_t + delta, UP_TIME + BLINK_TIME + DOWN_TIME)
	var up := _t < UP_TIME + BLINK_TIME
	_shape.disabled = not up
	if not up:
		_sprite.visible = true
		_sprite.texture = Art.tex("ilhota_alagada")
	elif _t > UP_TIME:
		_sprite.texture = Art.tex("ilhota")
		_sprite.visible = int(_t * 12.0) % 2 == 0
	else:
		_sprite.texture = Art.tex("ilhota")
		_sprite.visible = true
