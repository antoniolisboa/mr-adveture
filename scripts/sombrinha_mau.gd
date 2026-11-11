extends "res://scripts/walker.gd"
## Inimigo de Pernambuco: sombrinha de frevo que fugiu do passista e pula sozinha
## atrás de quem passa. Espera um pouquinho no chão e salta na direção do jogador.

var _wait := 0.6


func _setup() -> void:
	sprite_name = "sombrinha_mau"
	size = Vector2(14, 10)
	stomp_line = 4.0
	faces_left = false


func _behave(delta: float) -> void:
	velocity.y = minf(velocity.y + gravity * delta, 320.0)
	if is_on_floor():
		velocity.x = 0.0
		_wait -= delta
		if _wait <= 0.0:
			var px := _player().global_position.x if _player() else global_position.x
			dir = 1 if px > global_position.x else -1
			velocity = Vector2(dir * 62.0, -240.0)
			_wait = 0.7
	move_and_slide()


func _animate() -> void:
	_sprite.texture = Art.tex("sombrinha_mau_%d" % (0 if is_on_floor() else 1))
