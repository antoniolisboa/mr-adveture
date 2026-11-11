extends CharacterBody2D
## Base dos inimigos do Nordeste. Anda de um lado para o outro, vira na parede
## (e na beirada, se turn_at_ledges), morre com pisão ou golpe. A origem fica nos pés.
## Os sprites seguem o nome: "<sprite_name>_0", "<sprite_name>_1" e "<sprite_name>_flat".
## Cada inimigo muda os valores em _setup() e o jeito de andar em _behave().
##
## Também sabe "morrer de rir": a piada do microfone do Ceará deixa o inimigo
## parado, tremendo de rir e sem machucar por alguns segundos (pode pisar nele).

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

var dir := -1
var dead := false
var stomp_line := 6.0
var speed := 40.0
var size := Vector2(12, 12)
var sprite_name := ""
var sprite_y := -8.0
var turn_at_ledges := true
var gravity := 900.0
var anim_fps := 6.0
var wake_distance := 220.0
var faces_left := true          # o desenho olha para a esquerda
var stompable := true           # false = pisar machuca (ouriço, onda de calor)

var _active := false
var _t := 0.0
var _sprite: Sprite2D
var _laugh := 0.0
var _laugh_text: Node2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	_setup()
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	cs.position = Vector2(0, -size.y / 2.0)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, sprite_y)
	if sprite_name != "":
		_sprite.texture = Art.tex(sprite_name + "_0")
	add_child(_sprite)
	_laugh_text = PixelText.new()
	_laugh_text.align = 1
	_laugh_text.text = "KKK"
	_laugh_text.color = Color("fbe3a0")
	_laugh_text.position = Vector2(0, -size.y - 10)
	_laugh_text.visible = false
	add_child(_laugh_text)
	_after_ready()


func _setup() -> void:
	pass


func _after_ready() -> void:
	pass


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if dead:
		return
	if not _active:
		var cam := get_viewport().get_camera_2d()
		if cam and absf(cam.get_screen_center_position().x - global_position.x) < wake_distance:
			_active = true
		else:
			return
	_t += delta
	if _laugh > 0.0:
		_laugh -= delta
		_laugh_text.visible = _laugh > 0.0
		velocity.x = 0.0
		velocity.y = minf(velocity.y + gravity * delta, 320.0)
		move_and_slide()
		_sprite.position.x = 1.0 if int(_t * 20.0) % 2 == 0 else -1.0
		return
	_sprite.position.x = 0.0
	_behave(delta)
	if global_position.y > 2000.0:
		queue_free()
	_animate()


## Jeito padrão: anda reto e vira na parede/beirada.
func _behave(delta: float) -> void:
	_walk(delta, speed)


func _walk(delta: float, spd: float) -> void:
	velocity.y = minf(velocity.y + gravity * delta, 320.0)
	velocity.x = dir * spd
	move_and_slide()
	if spd > 0.0 and (is_on_wall() or (turn_at_ledges and is_on_floor() and not _ground_ahead())):
		dir = -dir


func _animate() -> void:
	if sprite_name == "":
		return
	_sprite.texture = Art.tex("%s_%d" % [sprite_name, int(_t * anim_fps) % 2])
	_sprite.flip_h = (dir > 0) == faces_left


func _ground_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(dir * (size.x / 2.0 + 3.0), -2.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 8), 1)
	return not space.intersect_ray(q).is_empty()


## Piada do microfone: fica rindo e não machuca.
func laugh(time: float) -> void:
	if dead:
		return
	_laugh = time
	_laugh_text.visible = true
	_active = true


func harmless() -> bool:
	return _laugh > 0.0


func can_stomp() -> bool:
	return stompable or _laugh > 0.0


func stomp() -> void:
	dead = true
	collision_layer = 0
	_laugh_text.visible = false
	if sprite_name != "":
		_sprite.texture = Art.tex(sprite_name + "_flat")
	get_tree().create_timer(0.5).timeout.connect(queue_free)


func knock() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	_laugh_text.visible = false
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 20.0, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
