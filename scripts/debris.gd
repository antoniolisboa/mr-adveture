extends Node2D
## Pedaço que voa quando o boss se desmancha.

var velocity := Vector2.ZERO
var color := Color.WHITE
var size := Vector2(4, 4)
var _life := 1.6


func _ready() -> void:
	z_index = 10


func _physics_process(delta: float) -> void:
	velocity.y += 700.0 * delta
	position += velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-size / 2.0, size).abs(), color)
