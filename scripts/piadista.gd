extends "res://scripts/walker.gd"
## Inimigo do Ceará: piadista de praia. Anda devagar e, quando vê o jogador, conta
## uma piada (balão voador). Quem é atingido fica rindo parado um pouquinho:
## não tira vida, mas atrapalha na hora errada.

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const JOKES := ["É PAVÊ?", "SABE DA ÚLTIMA?", "KKKKKK", "PERA, ESSA É BOA!", "ÉGUA, MACHO!"]

var _cooldown := 1.0


func _setup() -> void:
	sprite_name = "piadista"
	size = Vector2(10, 14)
	speed = 20.0
	stomp_line = 8.0


func _behave(delta: float) -> void:
	var p := _player()
	_cooldown -= delta
	if p and absf(p.global_position.x - global_position.x) < 140.0 and absf(p.global_position.y - global_position.y) < 40.0:
		dir = 1 if p.global_position.x > global_position.x else -1
		_walk(delta, 0.0)
		if _cooldown <= 0.0:
			_cooldown = 2.4
			var s := EnemyShot.new()
			s.label = JOKES[randi() % JOKES.size()]
			s.joke = true
			s.reflectable = false
			s.fall_gravity = 0.0
			s.position = global_position + Vector2(dir * 12, -12)
			s.velocity = Vector2(dir * 85.0, 0.0)
			get_parent().add_child(s)
			Sfx.play("piada")
	else:
		_walk(delta, speed)
