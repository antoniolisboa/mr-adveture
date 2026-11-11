extends CharacterBody2D
## Inimigo da Bahia: folião pipoca, de abadá, dançando no meio da rua.
## Vai e volta num pedacinho e, quando o jogador pula, ele pula junto
## ("tira o pé do chão!"). Morre com pisão ou com rasteira. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")

const GRAVITY := 900.0
const SPEED := 28.0
const RANGE := 28.0            # quanto anda para cada lado
const JUMP_VELOCITY := -280.0
const REACTION := 0.12         # atraso para pular depois do jogador
const WAKE_DISTANCE := 200.0

## Cores de abadá sorteadas por folião (o sprite usa amarelo e azul).
const ABADAS := [Color.WHITE, Color("ffb3c6"), Color("b5e8ff"), Color("c8f7a8")]

var dir := -1
var dead := false
var stomp_line := 14.0
var _active := false
var _start := Vector2.ZERO
var _jump_timer := -1.0
var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 20)
	cs.shape = rect
	cs.position = Vector2(0, -10)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -12)
	_sprite.texture = Art.tex("foliao_0")
	_sprite.modulate = ABADAS[absi(int(position.x / 16.0)) % ABADAS.size()]
	add_child(_sprite)
	_start = position
	_t = fmod(position.x * 0.37, 1.0)   # cada um dança num tempo diferente


func _physics_process(delta: float) -> void:
	if dead:
		return
	if not _active:
		var cam := get_viewport().get_camera_2d()
		if cam and absf(cam.get_screen_center_position().x - global_position.x) < WAKE_DISTANCE:
			_active = true
		else:
			return

	_t += delta
	velocity.y = minf(velocity.y + GRAVITY * delta, 320.0)
	velocity.x = dir * SPEED
	if Input.is_action_just_pressed("jump") and is_on_floor() and _on_screen():
		_jump_timer = REACTION
	if _jump_timer >= 0.0:
		_jump_timer -= delta
		if _jump_timer < 0.0 and is_on_floor():
			velocity.y = JUMP_VELOCITY
	move_and_slide()
	if is_on_wall() or absf(position.x - _start.x) > RANGE:
		dir = -dir
		position.x = clampf(position.x, _start.x - RANGE, _start.x + RANGE)
	if global_position.y > 600.0:
		queue_free()

	var arms_up := not is_on_floor() or int(_t * 4.0) % 2 == 0
	_sprite.texture = Art.tex("foliao_1" if arms_up else "foliao_0")
	_sprite.flip_h = dir > 0


func _on_screen() -> bool:
	var cam := get_viewport().get_camera_2d()
	return cam != null and absf(cam.get_screen_center_position().x - global_position.x) < 170.0


func stomp() -> void:
	knock()


func knock() -> void:
	dead = true
	collision_layer = 0
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 16.0, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
