extends CharacterBody2D
## Boss da Bahia: o Trio Elétrico Desgovernado. Um caminhão de som sem motorista,
## com faróis no lugar dos olhos e caixas de som no teto. A origem fica nos pés.
##
## Ciclo: anda pela arena soltando notas musicais (as baixas pedem pulo, as altas
## passam por cima de quem fica no chão) -> bate na parede -> "O SOM CAIU!": para,
## solta fumaça e a música some -> vira e recomeça. Com metade da vida acelera e
## faz chover confete. Dá para pular por cima dele.
## Pisão tira 2 de vida, rasteira tira 1.

signal defeated

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const Debris := preload("res://scripts/debris.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const BOSS_NAME := "TRIO ELÉTRICO DESGOVERNADO"
const ANNOUNCE := "SAI DA FRENTE, É O TRIO!"
const MAX_HP := 8
const GRAVITY := 900.0
const INVULN_TIME := 0.8
const HALF_W := 30.0
const HEIGHT := 40.0

const INK := Color("2b1d2e")
const BODY := Color("2b5fb4")
const BODY_DARK := Color("1d3f7a")
const STRIPE := Color("f7d038")
const STRIPE2 := Color("d64545")
const SPEAKER := Color("3a3a44")
const CONE := Color("9aa4b0")
const LIGHT := Color("fff3b0")
const TIRE := Color("1f1a22")
const SMOKE := Color("b8b8c0")
const LAMPS := [Color("d64545"), Color("f7d038"), Color("2a9d4a"), Color("2bb3c0"), Color("f07a2a")]

var hp := MAX_HP
var dead := false
var stomp_line := 30.0
var facing := -1
var arena_left := 0.0
var arena_right := 10000.0

var _state := "sleep"           # sleep -> intro -> drive -> pane -> drive ...
var _timer := 0.0
var _shot_timer := 0.0
var _confetti_timer := 0.0
var _high_note := false
var _invuln := 0.0
var _t := 0.0
var _wheel := 0.0
var _puffs: Array = []          # [posição local, idade]
var _rng := RandomNumberGenerator.new()
var _bubble: Node2D
var _bubble_time := 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(HALF_W * 2.0, HEIGHT)
	cs.shape = rect
	cs.position = Vector2(0, -HEIGHT / 2.0)
	add_child(cs)
	_bubble = PixelText.new()
	_bubble.align = 1
	_bubble.shadow = false
	_bubble.color = INK
	_bubble.position = Vector2(0, -62)
	_bubble.visible = false
	add_child(_bubble)


func start() -> void:
	_state = "intro"
	_timer = 1.4
	Sfx.play("buzina")
	_shout("TIRA O PÉ DO CHÃO!")
	Game.boss_hp_changed.emit(hp, MAX_HP)


func _angry() -> bool:
	return hp <= MAX_HP / 2


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _shout(text: String) -> void:
	_bubble.text = text
	_bubble.visible = true
	_bubble_time = 1.3


func _physics_process(delta: float) -> void:
	_t += delta
	if _invuln > 0.0:
		_invuln -= delta
	_bubble_time -= delta
	_bubble.visible = _bubble_time > 0.0 and not dead
	_update_puffs(delta)
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
			if _timer <= 0.0:
				_start_drive()
		"drive":
			var speed := 70.0 if _angry() else 45.0
			velocity.x = facing * speed
			_shot_timer -= delta
			if _shot_timer <= 0.0:
				_shot_timer = 1.0 if _angry() else 1.5
				_shoot_note()
			if _angry():
				_confetti_timer -= delta
				if _confetti_timer <= 0.0:
					_confetti_timer = 0.45
					_drop_confetti()
			# Chegou na parede da arena: o som cai.
			if (facing < 0 and position.x <= arena_left + HALF_W + 2.0) \
					or (facing > 0 and position.x >= arena_right - HALF_W - 2.0):
				_start_pane()
		"pane":
			velocity.x = 0.0
			_timer -= delta
			if int(_t * 10.0) % 3 == 0:
				_puffs.append([Vector2(_rng.randf_range(-20.0, 20.0), -HEIGHT - 4.0), 0.0])
			if _timer <= 0.0:
				facing = -facing
				Music.play(Game.music + "_boss")
				_start_drive()
	move_and_slide()
	_wheel += velocity.x * delta
	queue_redraw()


func _start_drive() -> void:
	_state = "drive"
	_shot_timer = 0.6
	_confetti_timer = 0.2


func _start_pane() -> void:
	_state = "pane"
	_timer = 2.4 if not _angry() else 1.8
	velocity.x = 0.0
	Music.stop()
	Sfx.play("pane")
	_shout("O SOM CAIU!")


## Nota musical das caixas de som, rente ao chão (pule) ou na altura da cabeça (fique no chão).
func _shoot_note() -> void:
	var n := EnemyShot.new()
	n.kind = "nota"
	n.reflectable = false
	n.fall_gravity = 0.0
	var y := -30.0 if _high_note else -6.0
	_high_note = not _high_note if not _angry() else _rng.randf() < 0.5
	n.position = position + Vector2(facing * (HALF_W + 4.0), y)
	n.velocity = Vector2(facing * 130.0, 0.0)
	get_parent().add_child(n)
	Sfx.play("som")


func _drop_confetti() -> void:
	var c := EnemyShot.new()
	c.kind = "confete"
	c.reflectable = false
	c.fall_gravity = 160.0
	c.position = Vector2(_rng.randf_range(arena_left + 8.0, arena_right - 8.0), position.y - 150.0)
	c.velocity = Vector2(_rng.randf_range(-20.0, 20.0), 20.0)
	get_parent().add_child(c)


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
		_shout(["EITA!", "VIXE!", "OXE!", "AI, PAINHO!"][_rng.randi() % 4])


func _break_apart() -> void:
	dead = true
	collision_layer = 0
	Sfx.play("boss_break")
	var parts := [
		[Vector2(-18, -44), SPEAKER, Vector2(12, 10)],
		[Vector2(0, -44), SPEAKER, Vector2(12, 10)],
		[Vector2(18, -44), SPEAKER, Vector2(12, 10)],
		[Vector2(-20, -4), TIRE, Vector2(8, 8)],
		[Vector2(20, -4), TIRE, Vector2(8, 8)],
		[Vector2(0, -20), BODY, Vector2(16, 10)],
		[Vector2(-10, -26), STRIPE, Vector2(10, 4)],
	]
	for part in parts:
		var d := Debris.new()
		d.position = position + part[0]
		d.color = part[1]
		d.size = part[2]
		d.velocity = Vector2(_rng.randf_range(-140.0, 140.0), _rng.randf_range(-340.0, -160.0))
		get_parent().add_child(d)
	for i in 12:
		var c := EnemyShot.new()
		c.kind = "confete"
		c.reflectable = false
		c.fall_gravity = 300.0
		c.position = position + Vector2(0, -40)
		c.velocity = Vector2(_rng.randf_range(-120.0, 120.0), _rng.randf_range(-260.0, -120.0))
		get_parent().add_child(c)
		c.collision_mask = 1      # confete da festa final não machuca
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_interval(0.8)
	tw.tween_callback(func(): defeated.emit())
	tw.tween_callback(queue_free)


func _update_puffs(delta: float) -> void:
	for p in _puffs:
		p[1] += delta
		p[0].y -= 18.0 * delta
	_puffs = _puffs.filter(func(p): return p[1] < 0.9)


# --- Desenho (frente para a esquerda; espelhado quando vai para a direita) ---

func _part(r: Rect2, col: Color) -> void:
	draw_rect(r.grow(1.0), INK)
	draw_rect(r, col)


func _draw() -> void:
	for p in _puffs:
		var s: float = 3.0 + p[1] * 6.0
		draw_rect(Rect2(p[0] - Vector2(s, s) / 2.0, Vector2(s, s)), Color(SMOKE, 1.0 - p[1]))
	if _bubble.visible:
		var w: int = _bubble.text.length() * 4 + 5
		draw_rect(Rect2(-w / 2.0 - 1, -63, w + 2, 11), INK)
		draw_rect(Rect2(-w / 2.0, -62, w, 9), Color.WHITE)
		draw_rect(Rect2(-2, -52, 4, 3), Color.WHITE)
	if dead and modulate.a <= 0.0:
		return
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 1:
		return

	var playing := _state == "drive" or _state == "intro"
	var beat := playing and int(_t * 4.0) % 2 == 0
	var bounce := 1.0 if beat else 0.0
	draw_set_transform(Vector2(0, -bounce), 0.0, Vector2(-facing, 1))

	# Rodas
	for x in [-20.0, 18.0]:
		draw_circle(Vector2(x, -6), 6.0, INK)
		draw_circle(Vector2(x, -6), 5.0, TIRE)
		var a := -_wheel / 6.0 * -facing
		draw_rect(Rect2(Vector2(x, -6) + Vector2(cos(a), sin(a)) * 2.5 - Vector2(1, 1), Vector2(2, 2)), CONE)
	# Carroceria
	_part(Rect2(-30, -32, 60, 22), BODY)
	draw_rect(Rect2(-30, -24, 60, 3), STRIPE)
	draw_rect(Rect2(-30, -20, 60, 2), STRIPE2)
	draw_rect(Rect2(-30, -12, 60, 2), BODY_DARK)
	# Cara na frente: faróis-olhos e grade-boca.
	var p := _player()
	var look := 0.0
	if p:
		look = clampf((p.global_position.y - global_position.y + 20.0) / 40.0, -1.0, 1.0)
	_part(Rect2(-29, -31, 7, 6), LIGHT)
	draw_rect(Rect2(-29, -29 + look, 3, 3), INK)
	if _angry():
		draw_rect(Rect2(-30, -33, 9, 2), INK)
	_part(Rect2(-29, -20, 6, 7), SPEAKER)
	for y in [-19, -17, -15]:
		draw_rect(Rect2(-29, y, 6, 1), CONE)
	# Caixas de som no teto, pulsando no ritmo.
	for i in 3:
		var x := -26 + i * 18
		_part(Rect2(x, -46, 16, 13), SPEAKER)
		var r := 4.0 + (1.0 if beat else 0.0)
		draw_circle(Vector2(x + 8, -40), r, CONE)
		draw_circle(Vector2(x + 8, -40), 1.5, INK)
	# Luzinhas piscando na beira do teto.
	for i in 8:
		var col: Color = LAMPS[(i + int(_t * 6.0)) % LAMPS.size()]
		if _state == "pane":
			col = Color("5c6670")
		draw_rect(Rect2(-29 + i * 8, -34, 3, 2), col)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
