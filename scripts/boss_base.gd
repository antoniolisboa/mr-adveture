extends CharacterBody2D
## Base dos bosses do Nordeste: vida, piscada de dano, balão de fala, barra de vida,
## explosão em pedaços no fim. Cada boss muda os valores em _setup(), decide o que
## fazer em _think() e se desenha em _draw_body(). A origem fica nos pés.
##
## Interface usada pela arena (scripts/boss_arena.gd) e pelo teste:
## signal defeated, BOSS_NAME, ANNOUNCE, hp, dead, _state, start(), arena_left/right.

signal defeated

const EnemyShot := preload("res://scripts/enemy_shot.gd")
const Debris := preload("res://scripts/debris.gd")
const PixelText := preload("res://scripts/pixel_text.gd")
const Art := preload("res://scripts/art.gd")

const INK := Color("2b1d2e")

var max_hp := 8
var hp := 8
var dead := false
var stomp_line := 20.0
var facing := -1
var arena_left := 0.0
var arena_right := 10000.0
var half_w := 16.0
var height := 32.0
var bubble_y := -60.0
var gravity := 900.0
var invuln_time := 0.8
var stomp_damage := 2
var knock_anytime := false      # true = golpe tira vida em qualquer momento
var debris_colors: Array = [Color("8a6a3f")]

var _state := "sleep"
var _timer := 0.0
var _invuln := 0.0
var _t := 0.0
var _rng := RandomNumberGenerator.new()
var _bubble: Node2D
var _bubble_time := 0.0
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	_setup()
	hp = max_hp
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(half_w * 2.0, height)
	_shape.shape = rect
	_shape.position = Vector2(0, -height / 2.0)
	add_child(_shape)
	_bubble = PixelText.new()
	_bubble.align = 1
	_bubble.shadow = false
	_bubble.color = INK
	_bubble.position = Vector2(0, bubble_y)
	_bubble.visible = false
	add_child(_bubble)


func _setup() -> void:
	pass


func start() -> void:
	_state = "intro"
	_timer = 1.4
	Game.boss_hp_changed.emit(hp, max_hp)
	_on_start()


func _on_start() -> void:
	pass


## Fim da introdução: começa o ciclo de ataques.
func _begin() -> void:
	pass


func _think(_delta: float) -> void:
	pass


func _angry() -> bool:
	return hp <= max_hp / 2


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _player_x() -> float:
	var p := _player()
	return p.global_position.x if p else position.x


func _face_player() -> void:
	facing = 1 if _player_x() > position.x else -1


func _shout(text: String, time := 1.3) -> void:
	_bubble.text = text
	_bubble.visible = true
	_bubble_time = time
	Sfx.play("fala")


func _pick(list: Array):
	return list[_rng.randi() % list.size()]


func _physics_process(delta: float) -> void:
	_t += delta
	if _invuln > 0.0:
		_invuln -= delta
	_bubble_time -= delta
	_bubble.visible = _bubble_time > 0.0 and not dead
	_tick(delta)
	if dead:
		queue_redraw()
		return
	if gravity > 0.0:
		velocity.y = minf(velocity.y + gravity * delta, 420.0)
	match _state:
		"sleep":
			velocity.x = 0.0
		"intro":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_begin()
		_:
			_think(delta)
	move_and_slide()
	position.x = clampf(position.x, arena_left + half_w, arena_right - half_w)
	_after_move(delta)
	queue_redraw()


## Roda todo quadro, até depois de morto (partículas, enfeites).
func _tick(_delta: float) -> void:
	pass


func _after_move(_delta: float) -> void:
	pass


## Lança um projétil inimigo.
func _shot(kind: String, pos: Vector2, vel: Vector2, grav := 500.0, label := "") -> Area2D:
	var s := EnemyShot.new()
	s.kind = kind
	s.label = label
	s.reflectable = false
	s.fall_gravity = grav
	s.position = pos
	s.velocity = vel
	get_parent().add_child(s)
	return s


## Pode pisar agora? (false = o pisão machuca o jogador)
func _can_stomp() -> bool:
	return true


func _bad_stomp() -> void:
	var p := _player()
	if p:
		p.hurt()


func stomp() -> void:
	if not _can_stomp():
		_bad_stomp()
		return
	_take_damage(stomp_damage)


## Golpe (giro, leque, disco, piada...). Só vale na hora em que o boss está vulnerável,
## para a luta não virar só apertar X.
func knock() -> void:
	if knock_anytime or _can_stomp():
		_take_damage(1)
	elif _invuln <= 0.0 and _bubble_time < 0.3 and _state != "sleep":
		Sfx.play("clang")
		_invuln = 0.3


## Inimigo arremessado pela pinça de caranguejo (Sergipe).
func hit_by_throw() -> void:
	if knock_anytime or _can_stomp():
		_take_damage(2)
	else:
		knock()


func _take_damage(amount: int) -> void:
	if dead or _invuln > 0.0 or _state == "sleep":
		return
	hp = maxi(hp - amount, 0)
	_invuln = invuln_time
	Sfx.play("boss_hit")
	Game.boss_hp_changed.emit(hp, max_hp)
	if hp == 0:
		_on_zero_hp()
	else:
		_on_hurt()


func _on_hurt() -> void:
	pass


## Vida zerou. Normalmente quebra; o Boi do Maranhão ressuscita uma vez.
func _on_zero_hp() -> void:
	_break_apart()


func _break_apart() -> void:
	dead = true
	collision_layer = 0
	Sfx.play("boss_break")
	for i in 10:
		var d := Debris.new()
		d.position = position + Vector2(_rng.randf_range(-half_w, half_w), -_rng.randf_range(4.0, height))
		d.color = debris_colors[i % debris_colors.size()]
		d.size = Vector2(_rng.randi_range(5, 14), _rng.randi_range(4, 10))
		d.velocity = Vector2(_rng.randf_range(-140.0, 140.0), _rng.randf_range(-340.0, -160.0))
		get_parent().add_child(d)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_interval(0.8)
	tw.tween_callback(func(): defeated.emit())
	tw.tween_callback(queue_free)


# --- Desenho -------------------------------------------------------------

func _part(r: Rect2, col: Color) -> void:
	draw_rect(r.grow(1.0), INK)
	draw_rect(r, col)


func _draw() -> void:
	if _bubble.visible:
		var w: int = _bubble.text.length() * 4 + 5
		# O balão não sai da arena (perto da parede ele escorrega para dentro).
		var bx := 0.0
		if arena_right - arena_left > w + 8:
			bx = clampf(0.0, arena_left - position.x + w / 2.0 + 4.0, arena_right - position.x - w / 2.0 - 4.0)
		_bubble.position.x = bx
		draw_rect(Rect2(bx - w / 2.0 - 1, bubble_y - 1, w + 2, 11), INK)
		draw_rect(Rect2(bx - w / 2.0, bubble_y, w, 9), Color.WHITE)
		draw_rect(Rect2(-2, bubble_y + 10, 4, 3), Color.WHITE)
	_draw_back()
	if dead and modulate.a <= 0.0:
		return
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 1:
		return
	_draw_body()


## Desenhado mesmo piscando (sombras, rastros).
func _draw_back() -> void:
	pass


func _draw_body() -> void:
	pass
