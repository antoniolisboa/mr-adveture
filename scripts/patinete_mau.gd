extends CharacterBody2D
## Inimigo de São Paulo: patinete de aluguel abandonado que resolveu andar sozinho.
## Corre rápido de um lado para o outro e vira na beirada. Morre com pisão ou golpe.
## A origem fica nos pés.

const Art := preload("res://scripts/art.gd")

const GRAVITY := 900.0
const SPEED := 80.0
const WAKE_DISTANCE := 200.0

var dir := -1
var dead := false
var stomp_line := 5.0
var _active := false
var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 10)
	cs.shape = rect
	cs.position = Vector2(0, -5)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	_sprite.texture = Art.tex("patinete_mau_0")
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
	velocity.x = dir * SPEED
	move_and_slide()
	if is_on_wall() or (is_on_floor() and not _ground_ahead()):
		dir = -dir
	if global_position.y > 600.0:
		queue_free()
	_sprite.texture = Art.tex("patinete_mau_%d" % (int(_t * 12.0) % 2))
	_sprite.flip_h = dir > 0


func _ground_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(dir * 9.0, -2.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 8), 1)
	return not space.intersect_ray(q).is_empty()


func stomp() -> void:
	dead = true
	collision_layer = 0
	_sprite.texture = Art.tex("patinete_mau_flat")
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
