extends CharacterBody2D
## Boss do Espírito Santo: a Panela de Moqueca Gigante. Uma panela de barro capixaba
## (preta, feita à mão) com cara de brava, defendendo a moqueca dela. A origem fica nos pés.
##
## Ciclo: "ferve" (treme, a tampa bate, sai vapor; em cima está quente demais para
## pisar) -> a tampa POCA e voam tomates e postas de peixe -> "pula" duas vezes atrás do
## jogador; cada pouso espirra moqueca rente ao chão para os dois lados -> "cansa"
## (a tampa fica torta e ela esfria: hora de pisar). Com metade da vida joga mais coisa
## e pula três vezes. Pisão tira 2 de vida (fora da fervura), panelada tira 1.

signal defeated

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const Debris := preload("res://scripts/debris.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const BOSS_NAME := "PANELA DE MOQUECA GIGANTE"
const ANNOUNCE := "MOQUECA É CAPIXABA, O RESTO É PEIXADA!"
const MAX_HP := 8
const GRAVITY := 900.0
const INVULN_TIME := 0.8
const HALF_W := 30.0
const HEIGHT := 40.0

const INK := Color("2b1d2e")
const CLAY := Color("43352e")
const CLAY_LIGHT := Color("75604f")
const CLAY_DARK := Color("2e2420")
const MOQUECA := Color("e8622a")
const COENTRO := Color("3c8d2f")
const FISH := Color("f4f1e8")
const EYE := Color("ffffff")
const STEAM := Color("dfe6ee")

var hp := MAX_HP
var dead := false
var stomp_line := 30.0
var facing := -1
var arena_left := 0.0
var arena_right := 10000.0

var _state := "sleep"           # sleep -> intro -> ferve -> pula -> cansa -> ferve ...
var _timer := 0.0
var _hops := 0
var _was_on_floor := true
var _invuln := 0.0
var _t := 0.0
var _lid_pop := 0.0             # tampa voando depois que a panela "poca"
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
	_bubble.position = Vector2(0, -66)
	_bubble.visible = false
	add_child(_bubble)


func start() -> void:
	_state = "intro"
	_timer = 1.4
	_shout("TÁ QUASE NO PONTO!")
	Game.boss_hp_changed.emit(hp, MAX_HP)


func _angry() -> bool:
	return hp <= MAX_HP / 2


func _hot() -> bool:
	return _state == "ferve"


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
	_lid_pop = maxf(_lid_pop - delta * 2.5, 0.0)
	_update_puffs(delta)
	if dead:
		queue_redraw()
		return

	velocity.y = minf(velocity.y + GRAVITY * delta, 420.0)
	match _state:
		"sleep", "intro":
			velocity.x = 0.0
			if _state == "intro":
				_timer -= delta
				if _timer <= 0.0:
					_start_ferve()
		"ferve":
			velocity.x = 0.0
			_timer -= delta
			if int(_t * 12.0) % 2 == 0:
				_puffs.append([Vector2(_rng.randf_range(-24.0, 24.0), -42.0), 0.0])
			if _timer <= 0.0:
				_pocar()
				_state = "pula"
				_hops = 3 if _angry() else 2
				_timer = 0.5
		"pula":
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
				_timer -= delta
				if _timer <= 0.0:
					if _hops > 0:
						_hop()
					else:
						_start_cansa()
		"cansa":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_start_ferve()
	move_and_slide()
	position.x = clampf(position.x, arena_left + HALF_W, arena_right - HALF_W)
	# Pousou de um pulo: espirra moqueca para os dois lados.
	if is_on_floor() and not _was_on_floor and _state == "pula":
		_land()
	_was_on_floor = is_on_floor()
	queue_redraw()


func _start_ferve() -> void:
	_state = "ferve"
	_timer = 1.3 if _angry() else 1.8
	Sfx.play("ferve")
	_shout("VAI POCAR!")


func _start_cansa() -> void:
	_state = "cansa"
	_timer = 1.5 if _angry() else 2.1
	_shout(["UFA, QUE CALOR...", "FALTOU URUCUM...", "PERA, DEIXA ESFRIAR..."][_rng.randi() % 3])


## A tampa poca e a moqueca voa em arco na direção do jogador.
func _pocar() -> void:
	Sfx.play("pocar")
	_lid_pop = 1.0
	var p := _player()
	var target_x := p.global_position.x if p else position.x - 80.0
	var count := 5 if _angry() else 3
	for i in count:
		var s := EnemyShot.new()
		s.kind = "tomate" if i % 2 == 0 else "posta"
		s.reflectable = false
		s.fall_gravity = 500.0
		s.position = position + Vector2(0, -46)
		var flight := 1.0 + i * 0.12
		var spread := (i - (count - 1) / 2.0) * 22.0
		var vx := clampf((target_x + spread - s.position.x) / flight, -200.0, 200.0)
		s.velocity = Vector2(vx, -250.0 - i * 15.0)
		get_parent().add_child(s)


func _hop() -> void:
	_hops -= 1
	var p := _player()
	if p:
		facing = 1 if p.global_position.x > position.x else -1
	velocity = Vector2(facing * (115.0 if _angry() else 85.0), -310.0)
	_was_on_floor = false
	_timer = 0.35


func _land() -> void:
	Sfx.play("crash")
	for d in [-1, 1]:
		var r := EnemyShot.new()
		r.kind = "respingo"
		r.reflectable = false
		r.fall_gravity = 0.0
		r.position = position + Vector2(d * (HALF_W + 2.0), -6)
		r.velocity = Vector2(d * 120.0, 0.0)
		get_parent().add_child(r)


func stomp() -> void:
	if _hot():
		# Em cima da panela fervendo não dá para pisar: queima o pé.
		var p := _player()
		if p:
			p.hurt()
		_shout("TÁ QUENTE, Ó!")
		return
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
		_shout(["AI, QUEIMEI!", "TÁ SALGADO!", "Ô LOCO!", "RESPEITA A PANELA!"][_rng.randi() % 4])


func _break_apart() -> void:
	dead = true
	collision_layer = 0
	Sfx.play("boss_break")
	var parts := [
		[Vector2(-20, -30), CLAY, Vector2(14, 12)],
		[Vector2(0, -24), CLAY, Vector2(16, 14)],
		[Vector2(20, -30), CLAY, Vector2(14, 12)],
		[Vector2(-12, -8), CLAY_DARK, Vector2(12, 8)],
		[Vector2(12, -8), CLAY_DARK, Vector2(12, 8)],
		[Vector2(0, -42), CLAY_LIGHT, Vector2(24, 5)],
		[Vector2(-33, -28), CLAY, Vector2(6, 6)],
		[Vector2(33, -28), CLAY, Vector2(6, 6)],
	]
	for part in parts:
		var d := Debris.new()
		d.position = position + part[0]
		d.color = part[1]
		d.size = part[2]
		d.velocity = Vector2(_rng.randf_range(-140.0, 140.0), _rng.randf_range(-340.0, -160.0))
		get_parent().add_child(d)
	# A moqueca que sobra voa para todo lado (essa não machuca).
	for i in 8:
		var s := EnemyShot.new()
		s.kind = ["tomate", "posta", "respingo"][i % 3]
		s.reflectable = false
		s.fall_gravity = 400.0
		s.position = position + Vector2(0, -36)
		s.velocity = Vector2(_rng.randf_range(-130.0, 130.0), _rng.randf_range(-280.0, -140.0))
		get_parent().add_child(s)
		s.collision_mask = 1
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_interval(0.8)
	tw.tween_callback(func(): defeated.emit())
	tw.tween_callback(queue_free)


func _update_puffs(delta: float) -> void:
	for p in _puffs:
		p[1] += delta
		p[0].y -= 22.0 * delta
	_puffs = _puffs.filter(func(p): return p[1] < 0.8)


# --- Desenho -------------------------------------------------------------

func _part(r: Rect2, col: Color) -> void:
	draw_rect(r.grow(1.0), INK)
	draw_rect(r, col)


func _draw() -> void:
	for p in _puffs:
		var s: float = 3.0 + p[1] * 7.0
		draw_rect(Rect2(p[0] - Vector2(s, s) / 2.0, Vector2(s, s)), Color(STEAM, 0.9 - p[1]))
	if _bubble.visible:
		var w: int = _bubble.text.length() * 4 + 5
		draw_rect(Rect2(-w / 2.0 - 1, -67, w + 2, 11), INK)
		draw_rect(Rect2(-w / 2.0, -66, w, 9), Color.WHITE)
		draw_rect(Rect2(-2, -56, 4, 3), Color.WHITE)
	if dead and modulate.a <= 0.0:
		return
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 1:
		return

	var shake := 0.0
	if _state == "ferve":
		shake = 1.0 if int(_t * 24.0) % 2 == 0 else -1.0
	draw_set_transform(Vector2(shake, 0), 0.0, Vector2.ONE)

	# Corpo da panela: boca larga, fundo mais estreito e as duas alças.
	_part(Rect2(-26, -8, 52, 8), CLAY_DARK)
	_part(Rect2(-30, -34, 60, 27), CLAY)
	draw_rect(Rect2(-25, -31, 3, 20), CLAY_LIGHT)
	draw_rect(Rect2(-21, -31, 1, 14), CLAY_LIGHT)
	_part(Rect2(-37, -30, 6, 6), CLAY)
	_part(Rect2(31, -30, 6, 6), CLAY)
	_part(Rect2(-32, -37, 64, 4), CLAY_DARK)
	draw_rect(Rect2(-32, -37, 64, 1), CLAY_LIGHT)

	# Cara: olhos que seguem o jogador, sobrancelha brava com metade da vida.
	var p := _player()
	var look := Vector2.ZERO
	if p:
		var d: Vector2 = p.global_position - global_position
		look = Vector2(clampf(d.x / 60.0, -1.0, 1.0) * 2.0, clampf((d.y + 20.0) / 40.0, -1.0, 1.0) * 2.0).round()
	for x in [-14.0, 6.0]:
		_part(Rect2(x, -28, 8, 8), EYE)
		draw_rect(Rect2(Vector2(x + 3, -25) + look, Vector2(2, 2)), INK)
		if _angry():
			draw_rect(Rect2(x - 1, -31 if x < 0 else -30, 10, 2), INK)
	if _hot():
		_part(Rect2(-5, -17, 10, 6), MOQUECA)        # boca aberta, bufando
	elif _state == "cansa":
		draw_rect(Rect2(-6, -14, 12, 1), INK)          # cansada
		draw_rect(Rect2(20, -22, 2, 3), Color("7fd0f0"))   # gota de suor
	else:
		draw_rect(Rect2(-7, -15, 14, 2), INK)

	# Moqueca aparecendo quando a tampa sai do lugar.
	var lid_off := Vector2.ZERO
	if _state == "cansa":
		lid_off = Vector2(12, 2)
	elif _hot():
		lid_off = Vector2(0, -1.0 - float(int(_t * 16.0) % 2) * 2.0)
	if _lid_pop > 0.0:
		lid_off = Vector2(0, -26.0 * sin(_lid_pop * PI) - 2.0)
	if _state == "cansa" or lid_off.y < -2.5:
		draw_rect(Rect2(-29, -39, 58, 2), MOQUECA)
		draw_rect(Rect2(-18, -40, 6, 2), FISH)
		draw_rect(Rect2(4, -40, 5, 2), FISH)
		draw_rect(Rect2(-6, -40, 2, 1), COENTRO)
		draw_rect(Rect2(14, -40, 2, 1), COENTRO)
	# Tampa com o pegador.
	_part(Rect2(Vector2(-28, -43) + lid_off, Vector2(56, 5)), CLAY)
	draw_rect(Rect2(Vector2(-28, -43) + lid_off, Vector2(56, 1)), CLAY_LIGHT)
	_part(Rect2(Vector2(-4, -47) + lid_off, Vector2(8, 3)), CLAY_DARK)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
