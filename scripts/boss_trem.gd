extends CharacterBody2D
## Boss de Minas: O Trem, uma locomotiva feita de tudo que mineiro chama de "trem"
## (chaminé de panela, queijo no teto, bigode na frente). A origem fica nos pés.
##
## Ciclo: espera e arremessa trens -> apita e se prepara -> dispara pela arena ->
## bate na parede e fica tonto -> vira e recomeça.
## Pisão tira 2 de vida, pão de queijo tira 1. Com metade da vida fica mais rápido.

signal defeated

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const Debris := preload("res://scripts/debris.gd")

const BOSS_NAME := "O TREM"
const ANNOUNCE := "UAI! É O TREM!"
const MAX_HP := 6
const GRAVITY := 900.0
const INVULN_TIME := 0.8

const INK := Color("2b1d2e")
const RED := Color("c0392b")
const RED_DARK := Color("8e2a20")
const WOOD := Color("8a6a3f")
const GRAY := Color("9aa4b0")
const GRAY_DARK := Color("5c6670")
const GLASS := Color("9fd8ff")
const WHITE := Color("ffffff")
const CHEESE := Color("fbe3a0")
const CRUST := Color("e0a03c")
const STAR := Color("f7d038")

var hp := MAX_HP
var dead := false
var stomp_line := 20.0          # os pés do jogador precisam estar acima disso para valer pisão
var facing := -1                # -1 = virado para a esquerda
var arena_left := 0.0
var arena_right := 10000.0

var _state := "sleep"
var _timer := 0.0
var _throw_timer := 0.0
var _throws_left := 0
var _invuln := 0.0
var _t := 0.0
var _roll := 0.0
var _puffs: Array = []          # [posição no mundo, idade]
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(44, 28)
	cs.shape = rect
	cs.position = Vector2(0, -14)
	add_child(cs)


func start() -> void:
	_state = "intro"
	_timer = 1.4
	Sfx.play("whistle")
	Game.boss_hp_changed.emit(hp, MAX_HP)


func _angry() -> bool:
	return hp <= MAX_HP / 2


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	_t += delta
	_update_puffs(delta)
	if _invuln > 0.0:
		_invuln -= delta
	if dead:
		queue_redraw()
		return

	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	match _state:
		"sleep":
			velocity.x = 0.0
		"intro":
			velocity.x = 0.0
			_timer -= delta
			_smoke(0.08)
			if _timer <= 0.0:
				_enter_wait()
		"wait":
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			_timer -= delta
			_throw_timer -= delta
			if _throws_left > 0 and _throw_timer <= 0.0:
				_throw_junk()
				_throws_left -= 1
				_throw_timer = 0.35 if _angry() else 0.5
			if _timer <= 0.0:
				_state = "windup"
				_timer = 0.6
				_face_player()
				Sfx.play("whistle")
		"windup":
			velocity.x = 0.0
			_timer -= delta
			_smoke(0.05)
			if _timer <= 0.0:
				_state = "charge"
		"charge":
			var top_speed := 190.0 if _angry() else 140.0
			velocity.x = move_toward(velocity.x, facing * top_speed, 500.0 * delta)
			_smoke(0.06)
		"stunned":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_enter_wait()

	var was_charging := _state == "charge"
	move_and_slide()
	if was_charging and is_on_wall():
		_state = "stunned"
		_timer = 1.3
		velocity.x = 0.0
		Sfx.play("crash")

	_roll += velocity.x * delta
	queue_redraw()


func _enter_wait() -> void:
	_state = "wait"
	_face_player()
	_timer = 1.2 if _angry() else 1.6
	_throws_left = 3 if _angry() else 2
	_throw_timer = 0.3


func _face_player() -> void:
	var p := _player()
	if p:
		facing = 1 if p.global_position.x > global_position.x else -1


## Arremessa um "trem" (panela, xícara ou queijinho) em arco na direção do jogador.
func _throw_junk() -> void:
	var p := _player()
	if not p:
		return
	var j := EnemyShot.new()
	j.kind = ["panela", "xicara", "queijinho"][_rng.randi() % 3]
	j.position = position + Vector2(-12 * -facing, -40)
	var flight := 1.0
	var target_x := p.global_position.x + _rng.randf_range(-16.0, 16.0)
	j.velocity = Vector2((target_x - j.position.x) / flight, -j.fall_gravity * flight * 0.5)
	get_parent().add_child(j)
	Sfx.play("throw")


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


func _break_apart() -> void:
	dead = true
	collision_layer = 0
	Sfx.play("boss_break")
	var parts := [
		[Vector2(-16, -5), INK, Vector2(10, 10)],
		[Vector2(-3, -5), INK, Vector2(10, 10)],
		[Vector2(12, -5), INK, Vector2(10, 10)],
		[Vector2(-12, -32), GRAY, Vector2(8, 8)],
		[Vector2(14, -39), CHEESE, Vector2(8, 4)],
		[Vector2(-10, -20), RED, Vector2(14, 10)],
		[Vector2(4, -20), RED_DARK, Vector2(10, 8)],
		[Vector2(15, -24), WOOD, Vector2(12, 12)],
		[Vector2(-18, -18), INK, Vector2(10, 2)],
	]
	for part in parts:
		var d := Debris.new()
		d.position = position + part[0]
		d.color = part[1]
		d.size = part[2]
		d.velocity = Vector2(_rng.randf_range(-120.0, 120.0), _rng.randf_range(-320.0, -160.0))
		get_parent().add_child(d)
	var tw := create_tween()
	tw.tween_interval(1.4)
	tw.tween_callback(func(): defeated.emit())
	tw.tween_callback(queue_free)


# --- Fumaça ---------------------------------------------------------------

var _smoke_acc := 0.0

func _smoke(every: float) -> void:
	_smoke_acc += get_physics_process_delta_time()
	if _smoke_acc >= every:
		_smoke_acc = 0.0
		_puffs.append([global_position + Vector2(-12 * -facing, -40), 0.0])


func _update_puffs(delta: float) -> void:
	for p in _puffs:
		p[1] += delta
		p[0] += Vector2(-facing * 10.0, -28.0) * delta
	_puffs = _puffs.filter(func(p): return p[1] < 0.8)


# --- Desenho (virado para a esquerda; espelhado quando olha para a direita) ---

func _draw() -> void:
	for p in _puffs:
		var a: float = p[1]
		draw_circle((p[0] - global_position).round(), 2.0 + a * 5.0, Color(1, 1, 1, 0.8 - a))
	if dead:
		return
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 1:
		return

	var shake := 0.0
	if _state in ["windup", "stunned"]:
		shake = 1.0 if int(_t * 30.0) % 2 == 0 else -1.0
	draw_set_transform(Vector2(shake, 0), 0.0, Vector2(-facing, 1))

	# Chaminé de panela
	draw_rect(Rect2(-17, -37, 10, 2), INK)
	draw_rect(Rect2(-16, -36, 8, 9), INK)
	draw_rect(Rect2(-15, -35, 6, 8), GRAY)
	draw_rect(Rect2(-17, -36, 10, 1), GRAY_DARK)
	draw_rect(Rect2(-21, -33, 5, 2), INK)
	# Caldeira com cara
	draw_rect(Rect2(-23, -28, 30, 16), INK)
	draw_rect(Rect2(-22, -27, 28, 14), RED)
	draw_rect(Rect2(-8, -27, 2, 14), RED_DARK)
	draw_rect(Rect2(0, -27, 2, 14), RED_DARK)
	draw_rect(Rect2(-26, -28, 4, 16), INK)
	draw_rect(Rect2(-25, -27, 2, 14), GRAY_DARK)
	if _state == "stunned":
		# Olhos em X
		for ex in [-21, -15]:
			draw_rect(Rect2(ex, -25, 1, 1), INK)
			draw_rect(Rect2(ex + 2, -25, 1, 1), INK)
			draw_rect(Rect2(ex + 1, -24, 1, 1), INK)
			draw_rect(Rect2(ex, -23, 1, 1), INK)
			draw_rect(Rect2(ex + 2, -23, 1, 1), INK)
	else:
		draw_rect(Rect2(-21, -25, 4, 4), WHITE)
		draw_rect(Rect2(-15, -25, 4, 4), WHITE)
		draw_rect(Rect2(-21, -24, 2, 2), INK)
		draw_rect(Rect2(-15, -24, 2, 2), INK)
		draw_rect(Rect2(-21, -26, 4, 1), INK)
		draw_rect(Rect2(-15, -26, 4, 1), INK)
	# Bigode
	draw_rect(Rect2(-22, -19, 10, 2), INK)
	draw_rect(Rect2(-23, -18, 2, 2), INK)
	draw_rect(Rect2(-12, -18, 2, 2), INK)
	# Cabine de madeira
	draw_rect(Rect2(6, -35, 18, 23), INK)
	draw_rect(Rect2(7, -34, 16, 21), WOOD)
	draw_rect(Rect2(10, -31, 9, 7), INK)
	draw_rect(Rect2(11, -30, 7, 5), GLASS)
	draw_rect(Rect2(4, -37, 22, 3), INK)
	# Queijo no teto
	draw_rect(Rect2(10, -42, 10, 5), INK)
	draw_rect(Rect2(11, -41, 8, 3), CHEESE)
	draw_rect(Rect2(11, -38, 8, 1), CRUST)
	# Chassi e limpa-trilhos
	draw_rect(Rect2(-24, -13, 48, 4), INK)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24, -12), Vector2(-31, -3), Vector2(-24, -3)]), GRAY_DARK)
	# Rodas com biela
	var angle := _roll / 5.0 * -facing
	var crank := Vector2(cos(angle), sin(angle)) * 3.0
	for wx in [-16, -3, 12]:
		draw_circle(Vector2(wx, -5), 5.0, INK)
		draw_circle(Vector2(wx, -5), 3.0, GRAY)
		draw_rect(Rect2((Vector2(wx, -5) + crank).round() - Vector2(1, 1), Vector2(2, 2)), INK)
	draw_rect(Rect2(Vector2(-16, -6) + crank.round(), Vector2(28, 2)), GRAY_DARK)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Estrelinhas de tontura
	if _state == "stunned":
		for i in 3:
			var a := _t * 6.0 + i * TAU / 3.0
			draw_rect(Rect2(Vector2(cos(a) * 12.0, -50 + sin(a) * 3.0).round(), Vector2(2, 2)), STAR)
