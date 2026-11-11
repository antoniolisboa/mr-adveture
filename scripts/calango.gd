extends "res://scripts/walker.gd"
## Inimigo do Piauí: calango do sertão. Dá uma corridinha rápida, para, balança a
## cabeça (faz flexão no chão quente) e corre de novo.

var _run := 0.0


func _setup() -> void:
	sprite_name = "calango"
	size = Vector2(14, 6)
	speed = 125.0
	stomp_line = 3.0
	anim_fps = 14.0


func _behave(delta: float) -> void:
	_run += delta
	var phase := fmod(_run, 1.6)
	if phase < 0.5:
		_walk(delta, speed)
	else:
		_walk(delta, 0.0)
		_sprite.position.y = sprite_y - (1.0 if int(_t * 8.0) % 2 == 0 else 0.0)


func _animate() -> void:
	var moving := fmod(_run, 1.6) < 0.5
	_sprite.texture = Art.tex("calango_%d" % (int(_t * anim_fps) % 2 if moving else 0))
	_sprite.flip_h = dir > 0
