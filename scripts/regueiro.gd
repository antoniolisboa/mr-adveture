extends "res://scripts/walker.gd"
## Inimigo do Maranhão: regueiro de São Luís dançando agarradinho com ninguém.
## Dois passinhos para a frente, um para trás, no ritmo lento do reggae.
## De vez em quando dá um pulinho.


func _setup() -> void:
	sprite_name = "regueiro"
	size = Vector2(10, 14)
	speed = 26.0
	stomp_line = 8.0
	anim_fps = 2.5


func _behave(delta: float) -> void:
	var beat := fmod(_t, 2.4)
	var spd := speed if beat < 1.6 else -speed * 0.8
	_walk(delta, spd)
	if is_on_floor() and fmod(_t, 4.8) < delta:
		velocity.y = -200.0
