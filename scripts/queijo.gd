extends CharacterBody2D
## Inimigo de Minas: um queijo bravo que anda de um lado para o outro.
## Morre com um pisão ou com um pão de queijo arremessado.

const Art := preload("res://scripts/art.gd")

const SPEED := 30.0
const GRAVITY := 900.0
const WAKE_DISTANCE := 200.0   # só começa a andar quando aparece na tela

var dir := -1
var dead := false
var stomp_line := 5.0           # pés do jogador acima disso = pisão
var _active := false
var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 12)
	cs.shape = rect
	cs.position = Vector2(0, -6)
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	_sprite.texture = Art.tex("queijo_0")
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

	velocity.x = dir * SPEED
	velocity.y = minf(velocity.y + GRAVITY * delta, 320.0)
	move_and_slide()
	if is_on_wall():
		dir = -dir
	if global_position.y > 600.0:
		queue_free()

	_t += delta
	_sprite.texture = Art.tex("queijo_%d" % (int(_t * 6.0) % 2))
	_sprite.flip_h = dir > 0


## Pisão: fica achatado e some.
func stomp() -> void:
	dead = true
	collision_layer = 0
	_sprite.texture = Art.tex("queijo_flat")
	get_tree().create_timer(0.5).timeout.connect(queue_free)


## Atingido por pão de queijo: vira de ponta-cabeça e cai da tela.
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
