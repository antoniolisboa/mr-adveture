extends "res://scripts/walker.gd"
## Inimigo de Santa Catarina (a Ilha da Magia): bruxinha de vassoura das histórias
## de Florianópolis. Voa em ondinha de um lado para o outro e, quando passa por cima
## do jogador, solta um feitiço que cai. Morre com pisão ou golpe.

const EnemyShot := preload("res://scripts/enemy_shot.gd")

const RANGE := 80.0

var _home := Vector2.ZERO
var _cool := 0.0


func _setup() -> void:
	sprite_name = "bruxinha"
	size = Vector2(14, 10)
	speed = 40.0
	stomp_line = 5.0
	gravity = 0.0
	anim_fps = 6.0
	sprite_y = -8.0


func _after_ready() -> void:
	_home = global_position
	collision_mask = 0


func _behave(delta: float) -> void:
	_cool -= delta
	global_position.x += dir * speed * delta
	global_position.y = _home.y + sin(_t * 3.0) * 10.0
	if absf(global_position.x - _home.x) > RANGE:
		dir = 1 if _home.x > global_position.x else -1
	var p := _player()
	if p and not p.dead and _cool <= 0.0 and absf(p.global_position.x - global_position.x) < 10.0 \
			and p.global_position.y > global_position.y:
		_cool = 1.6
		var s := EnemyShot.new()
		s.kind = "feitico"
		s.reflectable = true
		s.fall_gravity = 260.0
		s.position = global_position + Vector2(0, 2)
		s.velocity = Vector2(0, 20)
		get_parent().add_child(s)
		Sfx.play("feitico")
