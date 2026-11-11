extends CharacterBody2D
## O herói (ele ou ela). A origem do nó fica nos pés.

const Art := preload("res://scripts/art.gd")
const Projectile := preload("res://scripts/projectile.gd")
const PlayerShot := preload("res://scripts/player_shot.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const RUN_SPEED := 100.0
const GROUND_ACCEL := 900.0
const AIR_ACCEL := 650.0
const FRICTION := 1100.0
const GRAVITY := 900.0
const MAX_FALL := 320.0
const JUMP_VELOCITY := -310.0
const JUMP_CUT := 0.45          # soltar o pulo cedo = pulo mais baixo
const STOMP_BOUNCE := -220.0
const COYOTE_TIME := 0.1        # ainda dá para pular logo depois de sair da borda
const JUMP_BUFFER := 0.12       # aperto de pulo um pouco antes de tocar o chão vale
const INVULN_TIME := 1.5
const MAX_PROJECTILES := 2
const SWING_TIME := 0.22
const SWING_COOLDOWN := 0.35
const SHIELD_TIME := 0.6        # quanto tempo a panela de barro fica levantada
const SHIELD_COOLDOWN := 0.25
const DASH_SPEED := 230.0       # arrancada de patinete
const DASH_TIME := 0.7
const DASH_COOLDOWN := 0.4
const GLIDE_FALL := 40.0        # sombrinha de frevo aberta: cai devagar
const UMBRELLA_BOUNCE := -330.0 # ... e quica mais alto no pisão
const BUGGY_SPEED := 150.0
const BUGGY_JUMP := -340.0
const EMOCAO_JUMP := -430.0     # "com emoção": pulo enorme de buggy
const REGGAE_GRAVITY := 520.0   # disco de reggae: pulo alto e lento
const REGGAE_JUMP := -300.0
const REGGAE_FALL := 190.0
const WATER_GRAVITY := 260.0
const WATER_FALL := 70.0
const STROKE := -130.0          # braçada debaixo d'água
const SNORKEL_STROKE := -165.0
const SWIM_SPEED := 70.0
const SNORKEL_SWIM := 115.0
const AIR_TIME := 7.0           # segundos de fôlego sem snorkel
const HEAT_TIME := 16.0         # segundos de sol de meio-dia até passar mal
const HEAT_SHADE := 4.0         # segundos de sombra para esfriar de tudo
const AEREO_JUMP := -290.0      # prancha de surfe: segundo pulo no ar
const SHEEP_BOUNCE := -430.0    # pisão na lã da ovelha
const LASSO_RANGE := 112.0      # alcance do laço na diagonal
const LASSO_GRAB := 84.0        # alcance do laço reto (laçar inimigo)
const LASSO_PULL := 270.0
const LASSO_COOLDOWN := 0.45

var fall_limit := 1000.0
var camera_limits := Rect2i(0, 0, 10000, 1000)
var facing := 1
var dead := false
var frozen := false             # true no fim da fase
var camera: Camera2D

var _coyote := 0.0
var _jump_buffer := 0.0
var _invuln := 0.0
var _anim_time := 0.0
var _sprite: Sprite2D
var _hurt_area: Area2D
var _swing_area: Area2D
var _swing_shape: CollisionShape2D
var _racket: Sprite2D
var _racket_back: Sprite2D      # segundo rastro da rasteira (lado de trás)
var _swing_kind := "raquete"    # "raquete" (frente, rebate), "rasteira" (dois lados) ou "panela" (escudo)
var _swing := 0.0
var _swing_total := SWING_TIME
var _dash := 0.0                # tempo que falta da arrancada de patinete
var _dash_cooldown := 0.0
var _scooter: Sprite2D
var _umbrella: Sprite2D         # sombrinha aberta em cima da cabeça
var _buggy: Sprite2D
var _held: Sprite2D             # inimigo agarrado pela pinça, em cima da cabeça
var _held_tex: Texture2D = null
var _gliding := false
var _in_water := false
var _swim_dash := 0.0
var _stun := 0.0                # rindo de piada: não consegue fazer nada
var _stun_text: Node2D
var _swing_cooldown := 0.0
var _air_jump := false          # já usou o pulo aéreo da prancha
var _board: Sprite2D            # prancha debaixo dos pés no pulo aéreo
var _board_time := 0.0
var _rope: Line2D               # corda do laço
var _rope_tip: Sprite2D
var _rope_target := Vector2.ZERO
var _rope_time := 0.0
var _pull := 0.0                # tempo que falta sendo puxado pelo laço
var _lasso_cooldown := 0.0
# Altura dos pés nos dois últimos quadros. A área de contato chega com um quadro
# de atraso, então o pisão é decidido pela posição de antes do contato.
var _feet_prev := 0.0
var _feet_prev2 := 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	add_child(_box_shape(Vector2(10, 14)))

	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	add_child(_sprite)

	# Área que encosta nos inimigos (camada 3).
	_hurt_area = Area2D.new()
	_hurt_area.collision_layer = 0
	_hurt_area.collision_mask = 4
	_hurt_area.add_child(_box_shape(Vector2(10, 14)))
	add_child(_hurt_area)

	# Raquetada: pega inimigos (camada 3) e projéteis inimigos (camada 5).
	_swing_area = Area2D.new()
	_swing_area.collision_layer = 0
	_swing_area.collision_mask = 4 | 16
	_swing_area.monitoring = false
	_swing_shape = CollisionShape2D.new()
	var swing_rect := RectangleShape2D.new()
	swing_rect.size = Vector2(22, 22)
	_swing_shape.shape = swing_rect
	_swing_shape.position = Vector2(12, -10)
	_swing_area.add_child(_swing_shape)
	add_child(_swing_area)
	_racket = Sprite2D.new()
	_racket.visible = false
	add_child(_racket)
	_racket_back = Sprite2D.new()
	_racket_back.visible = false
	add_child(_racket_back)
	_scooter = Sprite2D.new()
	_scooter.texture = Art.tex("patinete_ride")
	_scooter.position = Vector2(0, -1)
	_scooter.visible = false
	add_child(_scooter)
	_umbrella = _extra_sprite("sombrinha_open", Vector2(0, -22))
	_buggy = _extra_sprite("buggy_ride", Vector2(0, -4))
	_held = _extra_sprite("", Vector2(0, -24))
	_board = _extra_sprite("prancha_ride", Vector2(0, 1))
	_rope = Line2D.new()
	_rope.width = 1.0
	_rope.default_color = Color("e8d8b0")
	_rope.visible = false
	add_child(_rope)
	_rope_tip = _extra_sprite("laco_ponta", Vector2.ZERO)
	_stun_text = PixelText.new()
	_stun_text.align = 1
	_stun_text.text = "KKKK"
	_stun_text.color = Color("fbe3a0")
	_stun_text.position = Vector2(0, -30)
	_stun_text.visible = false
	add_child(_stun_text)

	var cam := Camera2D.new()
	camera = cam
	cam.limit_left = camera_limits.position.x
	cam.limit_top = camera_limits.position.y
	cam.limit_right = camera_limits.end.x
	cam.limit_bottom = camera_limits.end.y
	cam.position = Vector2(0, -16)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 10.0
	add_child(cam)
	cam.make_current()
	_animate(0.0)


func _extra_sprite(tex: String, pos: Vector2) -> Sprite2D:
	var sp := Sprite2D.new()
	if tex != "":
		sp.texture = Art.tex(tex)
	sp.position = pos
	sp.visible = false
	add_child(sp)
	return sp


func _box_shape(size: Vector2) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	cs.position = Vector2(0, -size.y / 2)
	return cs


func _physics_process(delta: float) -> void:
	if dead:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		position += velocity * delta
		return

	var level := get_parent()
	var water_top: float = level.water_top() if level.has_method("water_top") else INF
	_in_water = global_position.y - 4.0 > water_top
	var head_under := global_position.y - 13.0 > water_top
	_stun -= delta
	var stunned := _stun > 0.0
	_stun_text.visible = stunned
	var dir := 0.0 if frozen or stunned else Input.get_axis("left", "right")
	_dash_cooldown -= delta
	_swim_dash -= delta
	# Arrancada de patinete: vai reto para a frente; virar para trás corta a arrancada.
	_dash -= delta
	if dir * facing < 0.0 or frozen or Game.power != "patinete":
		_dash = 0.0
	if Game.power != "pinca":
		_held_tex = null
	_scooter.visible = _dash > 0.0
	_scooter.flip_h = facing < 0
	_buggy.visible = Game.power == "buggy" and not _in_water
	_buggy.flip_h = facing < 0
	_held.visible = _held_tex != null
	_held.texture = _held_tex
	var run := RUN_SPEED
	if Game.power == "buggy":
		run = BUGGY_SPEED
	if _in_water:
		run = SNORKEL_SWIM if Game.power == "snorkel" else SWIM_SPEED
	if _pull > 0.0:
		pass                      # o laço está puxando
	elif _dash > 0.0:
		velocity.x = facing * DASH_SPEED
	elif _swim_dash > 0.0 and _in_water:
		velocity.x = facing * 200.0
	elif dir != 0.0:
		facing = 1 if dir > 0.0 else -1
		var accel := GROUND_ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, dir * run, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	var grav := GRAVITY
	var max_fall := MAX_FALL
	if Game.power == "reggae":
		grav = REGGAE_GRAVITY
		max_fall = REGGAE_FALL
	if _in_water:
		grav = WATER_GRAVITY
		max_fall = WATER_FALL
	_gliding = Game.power == "sombrinha" and not is_on_floor() and not _in_water \
			and not frozen and not stunned and Input.is_action_pressed("attack") and velocity.y > 0.0
	_umbrella.visible = _gliding
	if _gliding:
		max_fall = GLIDE_FALL
	if is_on_floor():
		_coyote = COYOTE_TIME
	elif _pull <= 0.0:
		_coyote -= delta
		velocity.y = minf(velocity.y + grav * delta, max_fall)

	if not frozen and not stunned:
		if Input.is_action_just_pressed("jump"):
			_jump_buffer = JUMP_BUFFER
		else:
			_jump_buffer -= delta
		if _jump_buffer > 0.0 and _in_water:
			# Na água: braçada para cima; com a cabeça de fora, pula para fora.
			if not head_under or _coyote > 0.0:
				velocity.y = JUMP_VELOCITY
				Sfx.play("jump")
			else:
				velocity.y = SNORKEL_STROKE if Game.power == "snorkel" else STROKE
				Sfx.play("nado")
			_jump_buffer = 0.0
			_coyote = 0.0
		elif _jump_buffer > 0.0 and _coyote > 0.0:
			velocity.y = _jump_speed()
			Sfx.play("jump")
			_jump_buffer = 0.0
			_coyote = 0.0
		if Input.is_action_just_released("jump") and velocity.y < 0.0 and not _in_water:
			velocity.y *= JUMP_CUT

	_update_air(delta, water_top, head_under)
	_update_heat(delta, level)

	_feet_prev2 = _feet_prev
	_feet_prev = global_position.y
	_update_lasso(delta)
	# Minuano: o vento empurra (menos com o pé no chão).
	var gust: float = level.wind_now() if level.has_method("wind_now") and _pull <= 0.0 and not frozen else 0.0
	if is_on_floor():
		gust *= 0.6
	velocity.x += gust
	move_and_slide()
	if not is_on_wall():
		velocity.x -= gust
	if is_on_floor():
		_air_jump = false

	# Cabeçada em caixa de poder.
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_normal().y > 0.5:
			var other := col.get_collider()
			if other and other.has_method("bump"):
				other.bump()

	if not frozen:
		if Input.is_action_just_pressed("attack") and not stunned:
			_attack()
		_check_enemies()

	if global_position.y > fall_limit:
		die(false)

	if _invuln > 0.0:
		_invuln -= delta
	_update_swing(delta)
	_animate(delta)


func _jump_speed() -> float:
	match Game.power:
		"buggy":
			return BUGGY_JUMP
		"reggae":
			return REGGAE_JUMP
	return JUMP_VELOCITY


## Fôlego debaixo d'água (Alagoas). Com snorkel não acaba nunca.
func _update_air(delta: float, water_top: float, head_under: bool) -> void:
	if water_top == INF:
		Game.air = 1.0
		return
	if head_under and Game.power != "snorkel":
		Game.air -= delta / AIR_TIME
		if Game.air <= 0.0:
			Game.air = 0.5
			Sfx.play("splash")
			hurt()
	elif not head_under:
		Game.air = minf(Game.air + delta * 0.8, 1.0)


## Calor do meio-dia (Piauí): no sol esquenta, na sombra esfria. Com o leque esquenta
## na metade do tempo, e abanar (X) refresca na hora.
func _update_heat(delta: float, level: Node) -> void:
	if not level.get("heat_on"):
		Game.heat = 0.0
		return
	if _shaded(level):
		Game.heat = maxf(Game.heat - delta / HEAT_SHADE, 0.0)
	else:
		Game.heat += delta / (HEAT_TIME * (2.0 if Game.power == "leque" else 1.0))
	if Game.heat >= 1.0:
		Game.heat = 0.45
		Sfx.play("sizzle")
		hurt()


## Tem algum bloco até 6 andares acima da cabeça? (marquise, árvore, ponte)
func _shaded(level: Node) -> bool:
	var col := int(floor(global_position.x / 16.0))
	var row := int(floor((global_position.y - 16.0) / 16.0))
	for r in range(row, row - 6, -1):
		if level.is_solid(col, r):
			return true
	return false


## Piada boa demais (Ceará): fica parado rindo um pouquinho. Não tira vida.
func laugh(time: float) -> void:
	if dead or _stun > 0.0:
		return
	_stun = time
	Sfx.play("risada")


func _check_enemies() -> void:
	for body in _hurt_area.get_overlapping_bodies():
		if not body.has_method("stomp") or body.dead:
			continue
		# Caindo e com os pés acima da "linha de pisão" do inimigo = pisão.
		var line: float = body.stomp_line
		var can_stomp: bool = not body.has_method("can_stomp") or body.can_stomp()
		if velocity.y > 0.0 and can_stomp and minf(_feet_prev2, global_position.y) < body.global_position.y - line:
			body.stomp()
			Sfx.play("stomp")
			var bounce := UMBRELLA_BOUNCE if Game.power == "sombrinha" else STOMP_BOUNCE
			velocity.y = JUMP_VELOCITY if Input.is_action_pressed("jump") else bounce
			if body.get("bouncy"):
				velocity.y = SHEEP_BOUNCE      # lã fofa de ovelha
			_air_jump = false
		elif body.has_method("steal") and not body.has_loot() and Game.power != "" and _invuln <= 0.0:
			body.steal(Game.power)             # o quati levou o item!
			Game.set_power("")
			_invuln = 1.0
		elif body.has_method("harmless") and body.harmless():
			continue
		elif blocks(body.global_position) or _dash > 0.0:
			body.knock()      # bateu na panela ou foi atropelado pelo patinete
		elif _invuln <= 0.0:
			hurt()


## true se a panela de barro está levantada do lado de onde vem o golpe.
func blocks(from: Vector2) -> bool:
	return _swing > 0.0 and _swing_kind == "panela" and (from.x - global_position.x) * facing > -4.0


func hurt() -> void:
	if dead or _invuln > 0.0:
		return
	if Game.power != "":
		Game.set_power("")
		_invuln = INVULN_TIME
		Sfx.play("hurt")
	else:
		die(true)


func die(hop: bool) -> void:
	if dead:
		return
	dead = true
	_dash = 0.0
	_scooter.visible = false
	_buggy.visible = false
	_umbrella.visible = false
	_held_tex = null
	_held.visible = false
	_board.visible = false
	_rope.visible = false
	_rope_tip.visible = false
	_pull = 0.0
	_stun = 0.0
	_stun_text.visible = false
	z_index = 20
	velocity = Vector2(0, -260 if hop else 0)
	_sprite.visible = hop
	_sprite.flip_v = true
	Sfx.play("die")
	Game.player_died.emit()


func _attack() -> void:
	match Game.power:
		"pao":
			_throw()
		"raquete":
			_start_swing("raquete")
		"berimbau":
			_start_swing("rasteira")
		"barro":
			_start_swing("panela")
		"patinete":
			if _dash_cooldown <= 0.0:
				_dash = DASH_TIME
				_dash_cooldown = DASH_TIME + DASH_COOLDOWN
				Sfx.play("patinete")
		"sombrinha":
			if not is_on_floor():
				Sfx.play("sombrinha")
		"sanfona":
			_start_swing("giro")
		"buggy":
			if is_on_floor() and not _in_water:
				velocity.y = EMOCAO_JUMP
				_coyote = 0.0
				Sfx.play("emocao")
		"microfone":
			_launch("piada", 1)
		"reggae":
			_launch("disco", 1)
		"leque":
			_start_swing("leque")
			Game.heat = maxf(Game.heat - 0.25, 0.0)
		"snorkel":
			if _in_water and _swim_dash < -0.3:
				_swim_dash = 0.3
				Sfx.play("splash")
		"pinca":
			_pinch()
		"pinhao":
			_launch("pinhao", 2)
		"prancha":
			if not is_on_floor() and not _air_jump and not _in_water and _coyote <= 0.0:
				_air_jump = true
				velocity.y = AEREO_JUMP
				_board_time = 0.4
				Sfx.play("aereo")
		"laco":
			_lasso()


## Piada do microfone ou disco de reggae.
func _launch(kind: String, max_count: int) -> void:
	var n := 0
	for p in get_tree().get_nodes_in_group("player_shots"):
		if p.kind == kind:
			n += 1
	if n >= max_count:
		return
	var s := PlayerShot.new()
	s.kind = kind
	s.dir = facing
	s.shooter = self
	s.position = position + Vector2(facing * 10, -9)
	get_parent().add_child(s)
	Sfx.play("piada" if kind == "piada" else "throw")


## Laço: primeiro procura um inimigo reto na frente (laçou, derrubou). Se não tem,
## joga o laço na diagonal para cima; se pegar num bloco, puxa o personagem até lá.
func _lasso() -> void:
	if _lasso_cooldown > 0.0 or _pull > 0.0:
		return
	_lasso_cooldown = LASSO_COOLDOWN
	Sfx.play("laco")
	var space := get_world_2d().direct_space_state
	var hand := global_position + Vector2(facing * 4, -10)
	# Inimigo na frente? (o mundo na frente bloqueia o laço)
	var low := global_position + Vector2(facing * 4, -5)       # altura dos inimigos baixinhos
	var q := PhysicsRayQueryParameters2D.create(low, low + Vector2(facing * LASSO_GRAB, 0), 1 | 4)
	q.exclude = [get_rid()]
	var hit := space.intersect_ray(q)
	if not hit.is_empty() and hit["collider"].has_method("knock") and not hit["collider"].dead:
		hit["collider"].knock()
		_show_rope(hit["position"], 0.2)
		return
	var dir := Vector2(facing * 0.72, -0.7).normalized()
	q = PhysicsRayQueryParameters2D.create(hand, hand + dir * LASSO_RANGE, 1)
	q.exclude = [get_rid()]
	hit = space.intersect_ray(q)
	if hit.is_empty():
		_show_rope(hand + dir * LASSO_RANGE, 0.2)
		return
	_show_rope(hit["position"], 0.6)
	_pull = 0.6
	velocity = (hit["position"] - hand).normalized() * LASSO_PULL
	_coyote = 0.0


func _show_rope(target: Vector2, time: float) -> void:
	_rope_target = target
	_rope_time = time


func _update_lasso(delta: float) -> void:
	_lasso_cooldown -= delta
	_rope_time -= delta
	_board_time -= delta
	_board.visible = _board_time > 0.0 and Game.power == "prancha"
	if Game.power != "laco":
		_pull = 0.0
		_rope_time = 0.0
	if _pull > 0.0:
		_pull -= delta
		var hand := global_position + Vector2(facing * 4, -10)
		var to := _rope_target - hand
		# Chegou (ou bateu em alguma coisa): solta e dá um impulso para subir no bloco.
		if to.length() < 12.0 or _pull <= 0.0 or is_on_ceiling() or is_on_wall():
			_pull = 0.0
			_rope_time = 0.0
			velocity = Vector2(facing * 80.0, -250.0)
		else:
			velocity = to.normalized() * LASSO_PULL
	_rope.visible = _rope_time > 0.0
	_rope_tip.visible = _rope.visible
	if _rope.visible:
		_rope.points = PackedVector2Array([Vector2(facing * 4, -10), _rope_target - global_position])
		_rope_tip.position = _rope_target - global_position


## Pinça de caranguejo: agarra o inimigo da frente; com ele na mão, X arremessa.
## Sem ninguém por perto, dá um beliscão.
func _pinch() -> void:
	if _held_tex:
		var s := PlayerShot.new()
		s.kind = "arremesso"
		s.dir = facing
		s.shooter = self
		s.texture = _held_tex
		s.position = position + Vector2(facing * 8, -22)
		get_parent().add_child(s)
		_held_tex = null
		Sfx.play("throw")
		return
	var q := PhysicsShapeQueryParameters2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(22, 18)
	q.shape = r
	q.transform = Transform2D(0.0, global_position + Vector2(facing * 12, -8))
	q.collision_mask = 4
	for hit in get_world_2d().direct_space_state.intersect_shape(q, 8):
		var b = hit["collider"]
		if b.has_method("stomp") and not b.dead and not b.has_signal("defeated") and b.get("grabbable") != false:
			var tex: Texture2D = null
			for c in b.get_children():
				if c is Sprite2D and c.texture:
					tex = c.texture
					break
			if tex == null:
				b.knock()
				return
			b.dead = true
			b.collision_layer = 0
			b.queue_free()
			_held_tex = tex
			Sfx.play("pinca")
			return
	_start_swing("pinca")


## Raquetada (na frente, rebate projéteis) ou rasteira de capoeira (rente ao chão,
## pega os dois lados ao mesmo tempo).
func _start_swing(kind: String) -> void:
	if _swing_cooldown > 0.0:
		return
	_swing_kind = kind
	_swing_total = SHIELD_TIME if kind == "panela" else SWING_TIME
	_swing = _swing_total
	_swing_cooldown = _swing_total + SHIELD_COOLDOWN if kind == "panela" else SWING_COOLDOWN
	var rect := _swing_shape.shape as RectangleShape2D
	if kind == "giro":
		_swing_total = 0.4
		_swing = 0.4
		_swing_cooldown = 0.5
		rect.size = Vector2(40, 18)
		_swing_shape.position = Vector2(0, -9)
		Sfx.play("sanfona")
	elif kind == "leque":
		rect.size = Vector2(30, 22)
		_swing_shape.position = Vector2(16 * facing, -10)
		Sfx.play("leque")
	elif kind == "pinca":
		_swing_total = 0.16
		_swing = 0.16
		rect.size = Vector2(16, 14)
		_swing_shape.position = Vector2(12 * facing, -8)
		Sfx.play("pinca")
	elif kind == "panela":
		rect.size = Vector2(12, 20)
		_swing_shape.position = Vector2(11 * facing, -9)
		Sfx.play("panela")
	elif kind == "rasteira":
		rect.size = Vector2(46, 14)
		_swing_shape.position = Vector2(0, -6)
		Sfx.play("rasteira")
	else:
		rect.size = Vector2(22, 22)
		_swing_shape.position = Vector2(12 * facing, -10)
		Sfx.play("swing")
	_swing_area.monitoring = true


func _update_swing(delta: float) -> void:
	_swing_cooldown -= delta
	if _swing <= 0.0:
		_racket.visible = false
		_racket_back.visible = false
		return
	_swing -= delta
	var first_half := _swing > _swing_total / 2.0
	_racket.visible = true
	_racket_back.visible = false
	if _swing_kind == "giro":
		# Giro de forró: a sanfona dá a volta no corpo.
		var side := 1 if int(_swing * 25.0) % 2 == 0 else -1
		_racket.rotation = 0.0
		_racket.texture = Art.tex("sanfona_aberta" if side > 0 else "sanfona")
		_racket.flip_h = side < 0
		_racket.position = Vector2(side * 10, -8)
	elif _swing_kind == "leque" or _swing_kind == "pinca":
		_racket.rotation = 0.0
		_racket.texture = Art.tex("leque_aberto" if _swing_kind == "leque" else "pinca_golpe")
		_racket.flip_h = facing < 0
		_racket.position = Vector2(facing * 10, -10 if _swing_kind == "leque" else -8)
		if _swing_kind == "leque":
			_racket_back.visible = true
			_racket_back.texture = Art.tex("vento")
			_racket_back.flip_h = facing < 0
			_racket_back.position = Vector2(facing * (20 + (1.0 - _swing / _swing_total) * 10.0), -10)
	elif _swing_kind == "panela":
		# A panela acompanha o lado para onde o personagem olha.
		_swing_shape.position = Vector2(11 * facing, -9)
		_racket.texture = Art.tex("panela_barro")
		_racket.flip_h = false
		_racket.position = Vector2(facing * 10, -9)
		_racket.rotation = facing * PI / 2.0     # boca da panela virada para a frente
	elif _swing_kind == "rasteira":
		_racket.rotation = 0.0
		# O rastro vai para a frente na primeira metade e para trás na segunda.
		var front := first_half
		_racket.texture = Art.tex("rasteira")
		_racket.flip_h = (facing < 0) == front
		_racket.position = Vector2(facing * (13 if front else -13), -3)
		_racket_back.visible = not front
		_racket_back.texture = Art.tex("rasteira")
		_racket_back.flip_h = facing < 0
		_racket_back.position = Vector2(facing * 13, -3)
	else:
		_racket.rotation = 0.0
		_racket.texture = Art.tex("swing_0" if first_half else "swing_1")
		_racket.flip_h = facing < 0
		_racket.position = Vector2(facing * (6 if first_half else 12), -14 if first_half else -9)
	for body in _swing_area.get_overlapping_bodies():
		if body.has_method("knock") and not body.dead:
			body.knock()
	if _swing_kind == "raquete":
		for area in _swing_area.get_overlapping_areas():
			if area.has_method("reflect"):
				area.reflect(facing)
	elif _swing_kind == "panela":
		for area in _swing_area.get_overlapping_areas():
			if area.has_method("block"):
				area.block()
	if _swing <= 0.0:
		_swing_area.monitoring = false
		_racket.visible = false
		_racket.rotation = 0.0
		_racket_back.visible = false


func _throw() -> void:
	if get_tree().get_nodes_in_group("projectiles").size() >= MAX_PROJECTILES:
		return
	var p := Projectile.new()
	p.dir = facing
	p.position = position + Vector2(facing * 8, -9)
	get_parent().add_child(p)
	Sfx.play("throw")


func _animate(delta: float) -> void:
	_anim_time += delta
	var frame := "idle"
	if not is_on_floor():
		frame = "jump"
	elif absf(velocity.x) > 5.0:
		frame = "run1" if int(_anim_time * 10.0) % 2 == 0 else "run2"
	var tex_id := "player_%s_%s_%s" % [Game.character, frame, Game.power if Game.power != "" else "none"]
	_sprite.texture = Art.tex(tex_id)
	_sprite.flip_h = facing < 0
	if _swing > 0.0 and _swing_kind == "giro":
		_sprite.flip_h = int(_swing * 25.0) % 2 == 0
	_sprite.position.x = (1.0 if int(_anim_time * 20.0) % 2 == 0 else -1.0) if _stun > 0.0 else 0.0
	_sprite.visible = _invuln <= 0.0 or int(_invuln * 20.0) % 2 == 0
