extends CharacterBody2D
## Inimigo de Santa Catarina: tainha pulando do mar na temporada de pesca.
## Fica escondida no fundo do buraco e, de tempos em tempos, salta bem alto em arco
## e volta para a água. Dá para pisar nela (ou derrubar). A origem fica nos pés.

const Art := preload("res://scripts/art.gd")

const JUMP := -360.0
const GRAVITY := 520.0
const WAIT := 1.7

var dead := false
var stomp_line := 4.0
var _home := Vector2.ZERO
var _vy := 0.0
var _wait := 0.0
var _up := false
var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 10)
	cs.shape = rect
	cs.position = Vector2(0, -6)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.texture = Art.tex("tainha_0")
	_sprite.position = Vector2(0, -6)
	_sprite.visible = false
	add_child(_sprite)
	_home = position + Vector2(0, 48)      # escondida lá no fundo
	position = _home
	_wait = fmod(_home.x * 0.07, WAIT)


func _physics_process(delta: float) -> void:
	if dead:
		return
	_t += delta
	var cam := get_viewport().get_camera_2d()
	if cam and absf(cam.get_screen_center_position().x - global_position.x) > 230.0:
		return
	if not _up:
		_wait -= delta
		if _wait <= 0.0:
			_up = true
			_vy = JUMP
			collision_layer = 4
			_sprite.visible = true
			Sfx.play("splash")
		return
	_vy += GRAVITY * delta
	position.y += _vy * delta
	# Sobe de cabeça para cima e desce de cabeça para baixo.
	_sprite.rotation = PI / 2.0 if _vy < 0.0 else -PI / 2.0
	_sprite.texture = Art.tex("tainha_%d" % (int(_t * 10.0) % 2))
	if _vy > 0.0 and position.y >= _home.y:
		position = _home
		_up = false
		_wait = WAIT
		collision_layer = 0
		_sprite.visible = false


func stomp() -> void:
	dead = true
	collision_layer = 0
	_sprite.rotation = 0.0
	_sprite.texture = Art.tex("tainha_flat")
	get_tree().create_timer(0.5).timeout.connect(queue_free)


func knock() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y + 200.0, 0.8).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
