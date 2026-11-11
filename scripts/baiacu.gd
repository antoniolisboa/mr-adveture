extends "res://scripts/walker.gd"
## Inimigo de Alagoas: baiacu nadando de um lado para o outro. Quando o jogador chega
## perto, ele incha todo espinhento (aí não dá para pisar) e depois desincha.
## Fica sempre debaixo d'água: se a maré baixa, ele desce junto.

var _home_x := 0.0
var _home_y := 0.0
var _puff := 0.0


func _setup() -> void:
	sprite_name = "baiacu"
	size = Vector2(12, 10)
	speed = 30.0
	gravity = 0.0
	stomp_line = 6.0


func _after_ready() -> void:
	collision_mask = 0
	_home_x = global_position.x
	_home_y = global_position.y


func _behave(delta: float) -> void:
	var p := _player()
	if p and p.global_position.distance_to(global_position) < 40.0 and _puff <= -1.0:
		_puff = 1.6
		Sfx.play("bolha")
	_puff -= delta
	stompable = _puff <= 0.0
	(get_child(0).shape as RectangleShape2D).size = Vector2(18, 16) if _puff > 0.0 else size
	if _puff <= 0.0:
		position.x += dir * speed * delta
		if absf(position.x - _home_x) > 40.0:
			dir = 1 if position.x < _home_x else -1
	var level := get_parent()
	var y := _home_y + sin(_t * 2.0) * 3.0
	if level.has_method("water_top"):
		y = maxf(y, level.water_top() + 14.0)
	position.y = move_toward(position.y, y, 40.0 * delta)


func _animate() -> void:
	if _puff > 0.0:
		_sprite.texture = Art.tex("baiacu_cheio")
	else:
		_sprite.texture = Art.tex("baiacu_%d" % (int(_t * 4.0) % 2))
	_sprite.flip_h = dir > 0
