extends CharacterBody2D
## Boss do Rio: o Vendedor de Mate, com galão nas costas e saco de biscoito.
## Anda pela arena gritando, arremessa biscoitos (a raquete rebate) e de vez em
## quando para e espirra jatos de mate rente ao chão (é preciso pular).
## Pisão tira 2 de vida; pão de queijo, raquetada ou biscoito rebatido tiram 1.

signal defeated

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const Debris := preload("res://scripts/debris.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const BOSS_NAME := "VENDEDOR DE MATE"
const ANNOUNCE := "OLHA O MATE!"
const MAX_HP := 6
const GRAVITY := 900.0
const INVULN_TIME := 0.8

const INK := Color("2b1d2e")
const SKIN := Color("c68642")
const SHIRT := Color("f07a2a")
const SHORTS := Color("f4f1e8")
const TANK := Color("c9d1d9")
const TANK_DARK := Color("8a96a3")
const BAG := Color("f7d038")
const BAG_STRIPE := Color("d64545")

var hp := MAX_HP
var dead := false
var stomp_line := 30.0
var facing := -1
var arena_left := 0.0
var arena_right := 10000.0

var _state := "sleep"
var _timer := 0.0
var _throw_timer := 0.0
var _laps := 0
var _drops_left := 0
var _invuln := 0.0
var _t := 0.0
var _walk_dir := -1
var _rng := RandomNumberGenerator.new()
var _bubble: Node2D
var _bubble_time := 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(18, 38)
	cs.shape = rect
	cs.position = Vector2(0, -19)
	add_child(cs)
	_bubble = PixelText.new()
	_bubble.align = 1
	_bubble.shadow = false
	_bubble.color = INK
	_bubble.position = Vector2(0, -60)
	_bubble.visible = false
	add_child(_bubble)


func start() -> void:
	_state = "intro"
	_timer = 1.4
	_shout(ANNOUNCE)
	Game.boss_hp_changed.emit(hp, MAX_HP)


func _angry() -> bool:
	return hp <= MAX_HP / 2


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _shout(text: String) -> void:
	_bubble.text = text
	_bubble.visible = true
	_bubble_time = 1.2
	Sfx.play("shout")


func _physics_process(delta: float) -> void:
	_t += delta
	if _invuln > 0.0:
		_invuln -= delta
	_bubble_time -= delta
	_bubble.visible = _bubble_time > 0.0 and not dead
	if dead:
		return

	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	match _state:
		"sleep", "intro":
			velocity.x = 0.0
			if _state == "intro":
				_timer -= delta
				if _timer <= 0.0:
					_state = "walk"
		"walk":
			var speed := 80.0 if _angry() else 50.0
			velocity.x = _walk_dir * speed
			facing = _walk_dir
			var target := arena_left + 24.0 if _walk_dir < 0 else arena_right - 24.0
			if (_walk_dir < 0 and position.x <= target) or (_walk_dir > 0 and position.x >= target):
				_walk_dir = -_walk_dir
				_laps += 1
				if _laps % 2 == 0:
					_state = "windup"
					_timer = 0.7
					_face_player()
					_shout("GELADINHO!")
			_throw_timer -= delta
			if _throw_timer <= 0.0:
				_throw_timer = 0.85 if _angry() else 1.3
				_throw_biscoito()
		"windup":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_state = "spray"
				_drops_left = 5 if _angry() else 4
				_timer = 0.0
		"spray":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				if _drops_left > 0:
					_spray_drop()
					_drops_left -= 1
					_timer = 0.32
				else:
					_state = "walk"
					_throw_timer = 0.6
	move_and_slide()
	queue_redraw()


func _face_player() -> void:
	var p := _player()
	if p:
		facing = 1 if p.global_position.x > global_position.x else -1


func _throw_biscoito() -> void:
	var p := _player()
	if not p:
		return
	var b := EnemyShot.new()
	b.kind = "biscoito_tiro"
	b.position = position + Vector2(facing * 8, -34)
	var flight := 0.9
	var target_x := p.global_position.x + _rng.randf_range(-12.0, 12.0)
	b.velocity = Vector2((target_x - b.position.x) / flight, -b.fall_gravity * flight * 0.5)
	get_parent().add_child(b)
	Sfx.play("throw")


func _spray_drop() -> void:
	var d := EnemyShot.new()
	d.kind = "gota"
	d.reflectable = false
	d.fall_gravity = 0.0
	d.position = position + Vector2(facing * 12, -7)
	d.velocity = Vector2(facing * 150.0, 0.0)
	get_parent().add_child(d)
	Sfx.play("splash")


func stomp() -> void:
	_take_damage(2)


func knock() -> void:
	_take_damage(1)


func _take_damage(amount: int) -> void:
	if dead or _invuln > 0.0 or _state == "sleep":
		return
	hp = maxi(hp - amount, 0)
	_invuln = INVULN_TIME
	Sfx.play("boss_hit")
	Game.boss_hp_changed.emit(hp, MAX_HP)
	if hp == 0:
		_break_apart()
	else:
		_shout(["AI!", "Ô, MERMÃO!", "QUE ISSO?!"][_rng.randi() % 3])


func _break_apart() -> void:
	dead = true
	collision_layer = 0
	Sfx.play("boss_break")
	var parts := [
		[Vector2(8, -28), TANK, Vector2(8, 16)],
		[Vector2(-12, -18), BAG, Vector2(6, 8)],
		[Vector2(0, -38), SHIRT, Vector2(12, 4)],
		[Vector2(-4, -6), Color("f6eedb"), Vector2(4, 4)],
		[Vector2(4, -6), Color("f6eedb"), Vector2(4, 4)],
		[Vector2(0, -12), Color("f6eedb"), Vector2(4, 4)],
	]
	for part in parts:
		var d := Debris.new()
		d.position = position + part[0]
		d.color = part[1]
		d.size = part[2]
		d.velocity = Vector2(_rng.randf_range(-120.0, 120.0), _rng.randf_range(-320.0, -160.0))
		get_parent().add_child(d)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_interval(0.8)
	tw.tween_callback(func(): defeated.emit())
	tw.tween_callback(queue_free)


# --- Desenho (virado para a esquerda; espelhado quando olha para a direita) ---

func _part(r: Rect2, col: Color) -> void:
	draw_rect(r.grow(1.0), INK)
	draw_rect(r, col)


func _draw() -> void:
	if _bubble.visible:
		var w: int = _bubble.text.length() * 4 + 5
		draw_rect(Rect2(-w / 2.0 - 1, -61, w + 2, 11), INK)
		draw_rect(Rect2(-w / 2.0, -60, w, 9), Color.WHITE)
		draw_rect(Rect2(-2, -50, 4, 3), Color.WHITE)
	if dead and modulate.a <= 0.0:
		return
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 1:
		return

	var shake := 0.0
	if _state == "windup":
		shake = 1.0 if int(_t * 30.0) % 2 == 0 else -1.0
	draw_set_transform(Vector2(shake, 0), 0.0, Vector2(-facing, 1))

	var step := int(_t * 8.0) % 2 if _state == "walk" else 0
	# Galão nas costas
	_part(Rect2(5, -38, 9, 22), TANK)
	draw_rect(Rect2(5, -34, 9, 2), TANK_DARK)
	draw_rect(Rect2(5, -22, 9, 2), TANK_DARK)
	draw_rect(Rect2(7, -41, 5, 3), TANK_DARK)
	# Pernas e chinelos
	_part(Rect2(-5, -12, 3, 10 - step), SKIN)
	_part(Rect2(2, -12, 3, 10 - (1 - step)), SKIN)
	draw_rect(Rect2(-7, -2 - step, 6, 2), INK)
	draw_rect(Rect2(1, -2 - (1 - step), 6, 2), INK)
	# Bermuda e camisa
	_part(Rect2(-7, -18, 14, 7), SHORTS)
	_part(Rect2(-8, -31, 16, 14), SHIRT)
	draw_rect(Rect2(-1, -31, 2, 14), Color("c85a1a"))
	# Saco de biscoito na mão da frente
	_part(Rect2(-11, -28, 3, 9), SKIN)
	_part(Rect2(-16, -22, 7, 9), BAG)
	draw_rect(Rect2(-16, -19, 7, 1), BAG_STRIPE)
	draw_rect(Rect2(-16, -16, 7, 1), BAG_STRIPE)
	# Cabeça com boné, bigode e boca
	_part(Rect2(-6, -41, 11, 10), SKIN)
	_part(Rect2(-7, -44, 12, 4), SHIRT)
	draw_rect(Rect2(-11, -41, 5, 2), SHIRT)
	draw_rect(Rect2(-4, -38, 2, 2), INK)
	draw_rect(Rect2(-6, -34, 6, 2), INK)
	if _bubble.visible:
		draw_rect(Rect2(-5, -32, 3, 2), Color("8e2a20"))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
