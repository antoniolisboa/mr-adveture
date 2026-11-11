extends "res://scripts/walker.gd"
## Inimigo da Paraíba: rojão de São João fincado no chão. Quando o jogador chega
## perto, o pavio chia, ele sobe zunindo e estoura lá em cima em faíscas que caem.
## Parado, dá para pisar (apaga o pavio) ou derrubar com o giro da sanfona.

const EnemyShot := preload("res://scripts/enemy_shot.gd")

var _fuse := -1.0               # -1 = esperando; >= 0 = chiando
var _flying := false


func _setup() -> void:
	sprite_name = "rojao"
	size = Vector2(6, 14)
	stomp_line = 10.0
	gravity = 0.0


func _behave(delta: float) -> void:
	var p := _player()
	if _flying:
		velocity = Vector2(0, -260.0)
		move_and_slide()
		if global_position.y < _start_y - 110.0 or is_on_ceiling():
			_explode()
		return
	if _fuse < 0.0:
		if p and absf(p.global_position.x - global_position.x) < 64.0 and absf(p.global_position.y - global_position.y) < 80.0:
			_fuse = 0.0
			Sfx.play("sizzle")
	else:
		_fuse += delta
		if _fuse > 0.55:
			_flying = true
			collision_layer = 0
			Sfx.play("rojao")


var _start_y := 0.0


func _after_ready() -> void:
	_start_y = global_position.y


func _animate() -> void:
	_sprite.texture = Art.tex("rojao_%d" % (1 if _fuse >= 0.0 and int(_t * 16.0) % 2 == 0 or _flying else 0))
	_sprite.position.x = (1.0 if int(_t * 30.0) % 2 == 0 else -1.0) if _fuse >= 0.0 and not _flying else 0.0


func _explode() -> void:
	Sfx.play("estouro")
	for i in 5:
		var s := EnemyShot.new()
		s.kind = "faisca"
		s.reflectable = false
		s.fall_gravity = 300.0
		s.position = global_position
		var a := -PI / 2.0 + (i - 2) * 0.55
		s.velocity = Vector2(cos(a), sin(a)) * 90.0
		get_parent().add_child(s)
	queue_free()


func can_stomp() -> bool:
	return not _flying
