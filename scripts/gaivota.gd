extends CharacterBody2D
## Inimigo do Espírito Santo: gaivota distraída. Voa de um lado para o outro e,
## quando vê o jogador embaixo, mergulha nele... mas no meio do mergulho esquece
## o que ia fazer ("?") e volta lá para cima. Morre com pisão ou panelada.
## A origem fica nos pés.

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const SPEED := 45.0
const RANGE := 90.0            # distância que voa antes de virar
const DIVE_SPEED := 150.0
const DIVE_TIME := 0.55        # no meio do mergulho ela esquece
const RETURN_SPEED := 60.0
const WAKE_DISTANCE := 200.0

var dir := -1
var dead := false
var stomp_line := 4.0
var _active := false
var _state := "fly"            # fly -> dive -> forget (volta para a altura) -> fly
var _timer := 0.0
var _gap := 0.0
var _t := 0.0
var _start := Vector2.ZERO
var _sprite: Sprite2D
var _mark: Node2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 8)
	cs.shape = rect
	cs.position = Vector2(0, -6)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -10)
	_sprite.texture = Art.tex("gaivota_0")
	add_child(_sprite)
	_mark = PixelText.new()
	_mark.align = 1
	_mark.position = Vector2(0, -24)
	_mark.visible = false
	add_child(_mark)
	_start = position


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
	_gap -= delta
	match _state:
		"fly":
			velocity = Vector2(dir * SPEED, (_start.y - position.y) * 4.0)
			var p := _player()
			if p and not p.dead and _gap <= 0.0:
				var d := p.global_position - global_position
				if d.y > 24.0 and d.y < 130.0 and absf(d.x) < 60.0:
					_state = "dive"
					_timer = DIVE_TIME
					velocity = (d + Vector2(0, -6)).normalized() * DIVE_SPEED
					dir = 1 if d.x > 0.0 else -1
					Sfx.play("gaivota")
		"dive":
			if _timer <= 0.0:
				_state = "forget"
				_mark.text = "?"
				_mark.visible = true
				Sfx.play("esquece")
				velocity = Vector2.ZERO
		"forget":
			# Para no ar um instante e sobe de volta para a altura de antes.
			if _timer < -0.4:
				velocity = Vector2(0, -RETURN_SPEED)
			if position.y <= _start.y:
				position.y = _start.y
				_state = "fly"
				_gap = 2.0
				_mark.visible = false
	move_and_slide()
	if _state == "dive" and (is_on_floor() or is_on_wall()):
		_timer = 0.0
	if _state == "fly":
		if is_on_wall():
			dir = -dir
		elif absf(position.x - _start.x) > RANGE:
			dir = 1 if _start.x > position.x else -1   # volta para a área dela
	var flap := 10.0 if _state != "dive" else 0.0
	_sprite.texture = Art.tex("gaivota_%d" % (int(_t * flap) % 2))
	_sprite.flip_h = dir > 0


func stomp() -> void:
	knock()


func knock() -> void:
	dead = true
	collision_layer = 0
	_mark.visible = false
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 12.0, 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
