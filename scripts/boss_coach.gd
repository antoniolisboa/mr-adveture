extends CharacterBody2D
## Boss de São Paulo: o Coach Quântico, de colete, microfone de cabeça e átomos girando
## em volta. É um tipo, não uma pessoa. A origem fica nos pés.
##
## Ciclo: "palestra" (anda e dispara palavras em balões: as baixas pedem pulo, as altas
## passam por cima) -> "teleporte" (some e aparece do outro lado: "QUÂNTICO!") -> a cada
## dois teleportes, "imersão": vira três (superposição!). Os clones piscam de vez em quando;
## acertar um clone faz ele sumir, acertar o verdadeiro acaba com a imersão.
## Pisão tira 2 de vida, golpe tira 1. Com metade da vida fala mais rápido e faz mais clones.
## O mesmo script desenha os clones (is_clone = true).

signal defeated

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const Debris := preload("res://scripts/debris.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const BOSS_NAME := "COACH QUÂNTICO"
const ANNOUNCE := "BEM-VINDO À SUA ZONA DE DESCONFORTO!"
const MAX_HP := 10
const GRAVITY := 900.0
const INVULN_TIME := 0.8
const HALF_W := 9.0
const HEIGHT := 44.0
const WORDS := ["SINERGIA", "MINDSET", "ENTREGA", "PROPÓSITO", "DISRUPÇÃO", "ESCALA", "FOCO", "RESILIÊNCIA"]

const INK := Color("2b1d2e")
const SKIN := Color("e0a47a")
const HAIR := Color("5a3a22")
const SHIRT := Color("9fd0e8")
const VEST := Color("1f3a5f")
const PANTS := Color("3a3a44")
const TEETH := Color("ffffff")
const ATOM := Color("7fe0ff")

var hp := MAX_HP
var dead := false
var stomp_line := 32.0
var facing := -1
var arena_left := 0.0
var arena_right := 10000.0
var is_clone := false
var boss: Node2D                # nos clones: quem é o verdadeiro

var _state := "sleep"           # sleep -> intro -> palestra -> teleporte -> (imersao) -> palestra ...
var _timer := 0.0
var _shot_timer := 0.0
var _high := false
var _teleports := 0
var _fade := 1.0                # 0 = sumido (teleporte)
var _tp_target := 0.0
var _clones: Array = []
var _invuln := 0.0
var _t := 0.0
var _talk := 0.0
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
	_bubble.position = Vector2(0, -64)
	_bubble.visible = false
	add_child(_bubble)
	_rng.randomize()
	if is_clone:
		_state = "palestra"
		_shot_timer = _rng.randf_range(0.8, 1.8)
		_t = _rng.randf() * 3.0


func start() -> void:
	_state = "intro"
	_timer = 1.4
	_shout("VOCÊ É SEU MAIOR CONCORRENTE!")
	Game.boss_hp_changed.emit(hp, MAX_HP)


func _angry() -> bool:
	return hp <= MAX_HP / 2


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _shout(text: String) -> void:
	_bubble.text = text
	_bubble.visible = true
	_bubble_time = 1.4


func _physics_process(delta: float) -> void:
	_t += delta
	_talk -= delta
	if _invuln > 0.0:
		_invuln -= delta
	_bubble_time -= delta
	_bubble.visible = _bubble_time > 0.0 and not dead and _fade > 0.5
	if dead:
		queue_redraw()
		return

	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	var p := _player()
	if p and _state != "teleporte":
		facing = 1 if p.global_position.x > position.x else -1
	match _state:
		"sleep":
			velocity.x = 0.0
		"intro":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_start_palestra()
		"palestra", "imersao":
			# Anda devagar para lá e para cá, como quem está no palco.
			velocity.x = sin(_t * 1.3) * 28.0
			_shot_timer -= delta
			if _shot_timer <= 0.0:
				var base := 0.8 if _angry() else 1.1
				_shot_timer = base * (1.8 if is_clone or _state == "imersao" else 1.0)
				_say_word()
			if not is_clone:
				_timer -= delta
				if _timer <= 0.0:
					if _state == "imersao":
						_end_imersao()
					_start_teleporte()
		"teleporte":
			# Some em 0,4 s, muda de lugar e aparece em mais 0,4 s.
			velocity.x = 0.0
			var before := _timer
			_timer -= delta
			if before > 0.4 and _timer <= 0.4:
				position.x = _tp_target
				Sfx.play("teleporte")
				_shout("QUÂNTICO!")
			if _timer > 0.4:
				_fade = (_timer - 0.4) / 0.4
			elif _timer > 0.0:
				_fade = 1.0 - _timer / 0.4
			else:
				_fade = 1.0
				collision_layer = 4
				_teleports += 1
				if _teleports % 2 == 0:
					_start_imersao()
				else:
					_start_palestra()
	move_and_slide()
	position.x = clampf(position.x, arena_left + HALF_W + 2.0, arena_right - HALF_W - 2.0)
	queue_redraw()


func _start_palestra() -> void:
	_state = "palestra"
	_timer = 4.0
	_shot_timer = 0.5


func _start_teleporte() -> void:
	_state = "teleporte"
	_timer = 0.8
	collision_layer = 0
	Sfx.play("teleporte")
	# Aparece do lado da arena mais longe do jogador.
	var p := _player()
	var px: float = p.global_position.x if p else (arena_left + arena_right) / 2.0
	var mid := (arena_left + arena_right) / 2.0
	_tp_target = arena_right - 40.0 if px < mid else arena_left + 40.0


## Superposição: ele e os clones espalhados pela arena; ele fica num lugar sorteado.
func _start_imersao() -> void:
	_state = "imersao"
	_timer = 6.0
	_shot_timer = 0.8
	_shout("IMERSÃO!")
	Sfx.play("teleporte")
	var count := 3 if _angry() else 2
	var spots: Array = []
	for i in count + 1:
		spots.append(arena_left + 30.0 + (arena_right - arena_left - 60.0) * i / count)
	var mine := _rng.randi() % spots.size()
	for i in spots.size():
		if i == mine:
			position.x = spots[i]
			continue
		var c = get_script().new()
		c.is_clone = true
		c.boss = self
		c.position = Vector2(spots[i], position.y)
		c.arena_left = arena_left
		c.arena_right = arena_right
		get_parent().add_child(c)
		_clones.append(c)


func _end_imersao() -> void:
	for c in _clones:
		if is_instance_valid(c) and not c.dead:
			c.vanish()
	_clones.clear()


func _say_word() -> void:
	var s := EnemyShot.new()
	s.label = WORDS[_rng.randi() % WORDS.size()]
	s.reflectable = true
	s.fall_gravity = 0.0
	var y := -30.0 if _high else -6.0
	_high = not _high if not _angry() else _rng.randf() < 0.5
	s.position = position + Vector2(facing * 14.0, y)
	s.velocity = Vector2(facing * 115.0, 0.0)
	get_parent().add_child(s)
	_talk = 0.35
	Sfx.play("fala")


## Clone: some num "puf".
func vanish() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	Sfx.play("puf")
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)


func stomp() -> void:
	if is_clone:
		vanish()
		return
	_take_damage(2)


func knock() -> void:
	if is_clone:
		vanish()
		return
	_take_damage(1)


func _take_damage(amount: int) -> void:
	if dead or _invuln > 0.0 or _state == "sleep" or _fade < 1.0:
		return
	hp = maxi(hp - amount, 0)
	_invuln = INVULN_TIME
	Sfx.play("boss_hit")
	Game.boss_hp_changed.emit(hp, MAX_HP)
	if _state == "imersao":
		_end_imersao()
		_start_palestra()
		_timer = 1.5
	if hp == 0:
		_break_apart()
	else:
		_shout(["ISSO É UM FEEDBACK?", "VOU RESSIGNIFICAR!", "FAZ PARTE DA JORNADA!",
				"ANOTA ESSE INSIGHT!"][_rng.randi() % 4])


func _break_apart() -> void:
	dead = true
	collision_layer = 0
	_end_imersao()
	Sfx.play("boss_break")
	_bubble_time = 2.0
	_bubble.text = "GRATIDÃO..."
	var parts := [
		[Vector2(-6, -26), VEST, Vector2(8, 12)],
		[Vector2(6, -26), VEST, Vector2(8, 12)],
		[Vector2(0, -40), HAIR, Vector2(12, 5)],
		[Vector2(6, -38), INK, Vector2(6, 2)],
		[Vector2(0, -10), PANTS, Vector2(10, 8)],
	]
	for part in parts:
		var d := Debris.new()
		d.position = position + part[0]
		d.color = part[1]
		d.size = part[2]
		d.velocity = Vector2(_rng.randf_range(-140.0, 140.0), _rng.randf_range(-320.0, -160.0))
		get_parent().add_child(d)
	# As palavras caem no chão (já não machucam ninguém).
	for i in 6:
		var s := EnemyShot.new()
		s.label = WORDS[i]
		s.reflectable = false
		s.fall_gravity = 350.0
		s.position = position + Vector2(0, -30)
		s.velocity = Vector2(_rng.randf_range(-110.0, 110.0), _rng.randf_range(-240.0, -120.0))
		get_parent().add_child(s)
		s.collision_mask = 1
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_interval(0.6)
	tw.tween_callback(func(): defeated.emit())
	tw.tween_callback(queue_free)


# --- Desenho (frente para a direita; espelhado quando olha para a esquerda) ---

func _part(r: Rect2, col: Color) -> void:
	draw_rect(r.grow(1.0), INK)
	draw_rect(r, col)


func _draw() -> void:
	if _bubble.visible:
		var w: int = _bubble.text.length() * 4 + 5
		draw_rect(Rect2(-w / 2.0 - 1, -65, w + 2, 11), INK)
		draw_rect(Rect2(-w / 2.0, -64, w, 9), Color.WHITE)
		draw_rect(Rect2(-2, -54, 4, 3), Color.WHITE)
	if dead and modulate.a <= 0.0:
		return
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 1:
		return
	var alpha := _fade
	# O clone "falha" de vez em quando, como imagem com defeito.
	if is_clone and fmod(_t, 1.6) < 0.18:
		alpha = 0.35
	var a := func(c: Color) -> Color: return Color(c, c.a * alpha)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var step := int(_t * 4.0) % 2 if absf(velocity.x) > 5.0 else 0
	# Pernas e sapatos
	draw_rect(Rect2(-6, -17, 5, 15 + step), a.call(INK))
	draw_rect(Rect2(1, -17, 5, 15 + 1 - step), a.call(INK))
	draw_rect(Rect2(-5, -16, 3, 13 + step), a.call(PANTS))
	draw_rect(Rect2(2, -16, 3, 14 - step), a.call(PANTS))
	draw_rect(Rect2(-7, -2, 7, 2), a.call(INK))
	draw_rect(Rect2(1, -2, 7, 2), a.call(INK))
	# Tronco: camisa clara e colete
	draw_rect(Rect2(-9, -33, 18, 17), a.call(INK))
	draw_rect(Rect2(-8, -32, 16, 15), a.call(SHIRT))
	draw_rect(Rect2(-8, -32, 5, 15), a.call(VEST))
	draw_rect(Rect2(3, -32, 5, 15), a.call(VEST))
	draw_rect(Rect2(-3, -24, 6, 7), a.call(VEST))
	# Braços: um para cima apontando quando fala
	draw_rect(Rect2(-12, -31, 3, 12), a.call(INK))
	draw_rect(Rect2(-11, -30, 1, 10), a.call(SHIRT))
	if _talk > 0.0:
		draw_rect(Rect2(9, -42, 3, 12), a.call(INK))
		draw_rect(Rect2(10, -41, 1, 10), a.call(SHIRT))
		draw_rect(Rect2(9, -45, 3, 3), a.call(SKIN))
	else:
		draw_rect(Rect2(9, -31, 3, 12), a.call(INK))
		draw_rect(Rect2(10, -30, 1, 10), a.call(SHIRT))
	# Cabeça, topete e sorrisão
	draw_rect(Rect2(-7, -46, 14, 13), a.call(INK))
	draw_rect(Rect2(-6, -45, 12, 11), a.call(SKIN))
	draw_rect(Rect2(-7, -49, 13, 5), a.call(HAIR))
	draw_rect(Rect2(-2, -51, 9, 3), a.call(HAIR))
	draw_rect(Rect2(1, -42, 2, 2), a.call(INK))
	draw_rect(Rect2(-4, -42, 2, 2), a.call(INK))
	draw_rect(Rect2(-3, -38, 8, 2), a.call(TEETH if _talk <= 0.0 else INK))
	# Microfone de cabeça
	draw_rect(Rect2(-7, -43, 1, 6), a.call(INK))
	draw_rect(Rect2(-7, -37, 5, 1), a.call(INK))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Átomos girando em volta (o lado "quântico").
	for i in 3:
		var ang := _t * 3.0 + i * TAU / 3.0
		var pos := Vector2(cos(ang) * 16.0, -26.0 + sin(ang) * 6.0 * (1 if i % 2 == 0 else -1))
		draw_rect(Rect2(pos - Vector2(1, 1), Vector2(3, 3)), a.call(ATOM))
