extends CharacterBody2D
## Inimigo de Minas: xícara de café quente que vai pulando atrás do jogador.
## Morre com pisão ou com pão de queijo. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")

const GRAVITY := 900.0
const HOP_VELOCITY := -250.0
const HOP_SPEED := 55.0
const HOP_INTERVAL := 1.0
const WAKE_DISTANCE := 200.0

var dir := -1
var dead := false
var stomp_line := 5.0
var _active := false
var _hop_timer := HOP_INTERVAL
var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 11)
	cs.shape = rect
	cs.position = Vector2(0, -5.5)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	_sprite.texture = Art.tex("xicara_0")
	add_child(_sprite)


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
	if is_on_floor():
		velocity.x = 0.0
		_hop_timer -= delta
		if _hop_timer <= 0.0:
			_hop_timer = HOP_INTERVAL
			var p := get_tree().get_first_node_in_group("player") as Node2D
			if p:
				dir = 1 if p.global_position.x > global_position.x else -1
			velocity = Vector2(dir * HOP_SPEED, HOP_VELOCITY)
	move_and_slide()
	if is_on_wall():
		dir = -dir
		velocity.x = dir * HOP_SPEED
	if global_position.y > 600.0:
		queue_free()

	# Agacha um pouco antes de pular.
	var crouch := is_on_floor() and _hop_timer < 0.2
	_sprite.texture = Art.tex("xicara_flat" if crouch else "xicara_%d" % (int(_t * 5.0) % 2))
	_sprite.flip_h = dir > 0


func stomp() -> void:
	dead = true
	collision_layer = 0
	_sprite.texture = Art.tex("xicara_flat")
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
