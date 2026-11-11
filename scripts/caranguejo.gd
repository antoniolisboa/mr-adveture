extends "res://scripts/walker.gd"
## Inimigo de Sergipe: caranguejo do mangue andando de lado. De vez em quando para e
## abre as pinças. Dá para pisar, e com a pinça dá para agarrar e arremessar.

var _pause := 0.0


func _setup() -> void:
	sprite_name = "caranguejo"
	size = Vector2(14, 8)
	speed = 42.0
	stomp_line = 4.0
	anim_fps = 8.0


func _behave(delta: float) -> void:
	_pause -= delta
	if _pause < -2.0:
		_pause = 0.7
	_walk(delta, 0.0 if _pause > 0.0 else speed)


func _animate() -> void:
	_sprite.texture = Art.tex("caranguejo_%d" % (1 if _pause > 0.0 else int(_t * anim_fps) % 2))
