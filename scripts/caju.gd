extends "res://scripts/walker.gd"
## Inimigo do Rio Grande do Norte: caju maduro pendurado no cajueiro. Quando o
## jogador passa embaixo, ele despenca e sai andando atrás dele com a castanha.

var _hanging := true


func _setup() -> void:
	sprite_name = "caju"
	size = Vector2(10, 12)
	speed = 30.0
	stomp_line = 6.0
	faces_left = false


func _behave(delta: float) -> void:
	if _hanging:
		var p := _player()
		if p and absf(p.global_position.x - global_position.x) < 22.0 and p.global_position.y > global_position.y:
			_hanging = false
			Sfx.play("bump")
		return
	if is_on_floor():
		var px := _player().global_position.x if _player() else global_position.x
		if absf(px - global_position.x) > 8.0:
			dir = 1 if px > global_position.x else -1
	_walk(delta, speed)


func _animate() -> void:
	_sprite.texture = Art.tex("caju_0" if _hanging or not is_on_floor() else "caju_%d" % (int(_t * 6.0) % 2))
	_sprite.flip_h = dir > 0
