extends CharacterBody2D
## Inimigo da Bahia: pimenta do acarajé. Anda devagar; quando o jogador chega perto
## e na mesma altura, esquenta (treme e fica vermelha) e dá uma arrancada.
## Morre com pisão ou com rasteira. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")

const GRAVITY := 900.0
const WALK_SPEED := 22.0
const DASH_SPEED := 175.0
const SIGHT := 110.0           # distância em que ela "vê" o jogador
const HEAT_TIME := 0.45
const DASH_TIME := 0.8
const COOL_TIME := 1.0
const WAKE_DISTANCE := 200.0

var dir := -1
var dead := false
var stomp_line := 5.0
var _active := false
var _state := "walk"           # walk -> heat -> dash -> cool -> walk
var _timer := 0.0
var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 9)
	cs.shape = rect
	cs.position = Vector2(0, -4.5)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	_sprite.texture = Art.tex("pimenta_0")
	add_child(_sprite)


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


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
	_timer -= delta
	velocity.y = minf(velocity.y + GRAVITY * delta, 320.0)
	var shake := 0.0
	match _state:
		"walk":
			velocity.x = dir * WALK_SPEED
			var p := _player()
			if p and not p.dead and is_on_floor():
				var dx := p.global_position.x - global_position.x
				if absf(dx) < SIGHT and absf(p.global_position.y - global_position.y) < 24.0:
					dir = 1 if dx > 0.0 else -1
					_state = "heat"
					_timer = HEAT_TIME
					Sfx.play("sizzle")
		"heat":
			velocity.x = 0.0
			shake = 1.0 if int(_t * 30.0) % 2 == 0 else -1.0
			if _timer <= 0.0:
				_state = "dash"
				_timer = DASH_TIME
		"dash":
			velocity.x = dir * DASH_SPEED
			if _timer <= 0.0:
				_state = "cool"
				_timer = COOL_TIME
		"cool":
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			if _timer <= 0.0:
				_state = "walk"
	move_and_slide()
	if is_on_wall():
		dir = -dir
		if _state == "dash":
			_state = "cool"
			_timer = COOL_TIME
	# Não cai dos buracos andando: vira na beirada (na arrancada ela cai mesmo).
	if _state == "walk" and is_on_floor() and not _ground_ahead():
		dir = -dir
	if global_position.y > 600.0:
		queue_free()

	var hot := _state == "heat" or _state == "dash"
	_sprite.modulate = Color(1.0, 0.75, 0.55) if hot else Color.WHITE
	_sprite.position.x = shake
	var speed := 16.0 if _state == "dash" else 5.0
	_sprite.texture = Art.tex("pimenta_%d" % (int(_t * speed) % 2))
	_sprite.flip_h = dir > 0


func _ground_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(dir * 8.0, -2.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 8), 1)
	return not space.intersect_ray(q).is_empty()


func stomp() -> void:
	dead = true
	collision_layer = 0
	_sprite.modulate = Color.WHITE
	_sprite.texture = Art.tex("pimenta_flat")
	get_tree().create_timer(0.5).timeout.connect(queue_free)


func knock() -> void:
	dead = true
	collision_layer = 0
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 20.0, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
