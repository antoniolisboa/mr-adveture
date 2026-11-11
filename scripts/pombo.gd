extends CharacterBody2D
## Inimigo do Rio: pombo que voa de um lado para o outro, subindo e descendo.
## Morre com pisão, pão de queijo ou raquetada. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")

const SPEED := 40.0
const RANGE := 80.0          # distância que voa antes de virar
const BOB := 10.0            # quanto sobe e desce
const WAKE_DISTANCE := 200.0

var dir := -1
var dead := false
var stomp_line := 4.0
var _active := false
var _t := 0.0
var _start := Vector2.ZERO
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 9)
	cs.shape = rect
	cs.position = Vector2(0, -5)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	_sprite.texture = Art.tex("pombo_0")
	add_child(_sprite)
	_start = position


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
	var target_y := _start.y + sin(_t * 3.0) * BOB
	velocity = Vector2(dir * SPEED, (target_y - position.y) * 10.0)
	move_and_slide()
	if is_on_wall() or absf(position.x - _start.x) > RANGE:
		dir = -dir
		position.x = clampf(position.x, _start.x - RANGE, _start.x + RANGE)
	_sprite.texture = Art.tex("pombo_%d" % (int(_t * 8.0) % 2))
	_sprite.flip_h = dir > 0


func stomp() -> void:
	knock()


func knock() -> void:
	dead = true
	collision_layer = 0
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 12.0, 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
