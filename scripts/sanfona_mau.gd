extends "res://scripts/walker.gd"
## Inimigo da Paraíba: sanfona que saiu andando sozinha do forró. Anda, para,
## estica o fole (fica mais larga) e encolhe de novo.

var _breath := 0.0


func _setup() -> void:
	sprite_name = "sanfona_mau"
	size = Vector2(14, 12)
	speed = 34.0
	stomp_line = 6.0


func _behave(delta: float) -> void:
	_breath += delta
	var open := fmod(_breath, 2.4) > 1.6
	(get_child(0).shape as RectangleShape2D).size.x = 24.0 if open else 14.0
	_walk(delta, 0.0 if open else speed)


func _animate() -> void:
	_sprite.texture = Art.tex("sanfona_mau_%d" % (1 if fmod(_breath, 2.4) > 1.6 else 0))
	_sprite.flip_h = dir > 0
