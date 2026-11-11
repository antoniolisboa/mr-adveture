extends "res://scripts/walker.gd"
## Inimigo do Rio Grande do Norte: buggy sem motorista descendo as dunas
## "com emoção". Corre e vira na parede e na beirada.


func _setup() -> void:
	sprite_name = "buggy_mau"
	size = Vector2(20, 10)
	speed = 90.0
	stomp_line = 5.0
	anim_fps = 12.0
