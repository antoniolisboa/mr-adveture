extends CharacterBody2D
## Inimigo do Rio Grande do Sul: quero-quero, o guardião do pampa. Fica no chão
## cuidando do ninho; quando o jogador chega perto, grita "QUERO-QUERO!", levanta voo
## e dá rasantes na cabeça dele, três vezes, antes de voltar para o chão.
## Morre com pisão ou golpe. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const ALERT := 80.0
const DIVE_SPEED := 140.0

var dir := -1
var dead := false
var stomp_line := 5.0
var _state := "chao"            # chao -> sobe -> rasante -> sobe ... -> volta
var _timer := 0.0
var _dives := 0
var _t := 0.0
var _home := Vector2.ZERO
var _cool := 0.0
var _sprite: Sprite2D
var _shout: Node2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 10)
	cs.shape = rect
	cs.position = Vector2(0, -5)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -8)
	_sprite.texture = Art.tex("queroquero_0")
	add_child(_sprite)
	_shout = PixelText.new()
	_shout.align = 1
	_shout.text = "QUERO-QUERO!"
	_shout.position = Vector2(0, -26)
	_shout.visible = false
	add_child(_shout)
	_home = position


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if dead:
		return
	var cam := get_viewport().get_camera_2d()
	if cam and absf(cam.get_screen_center_position().x - global_position.x) > 230.0:
		return
	_t += delta
	_timer -= delta
	_cool -= delta
	var p := _player()
	match _state:
		"chao":
			velocity.x = 0.0
			velocity.y = minf(velocity.y + 900.0 * delta, 300.0)
			if p and not p.dead and _cool <= 0.0 and p.global_position.distance_to(global_position) < ALERT:
				_state = "sobe"
				_dives = 3
				_timer = 0.5
				_shout.visible = true
				Sfx.play("queroquero")
		"sobe":
			# Sobe até ficar acima do jogador.
			var target := Vector2(p.global_position.x if p else _home.x, (p.global_position.y if p else _home.y) - 56.0)
			velocity = (target - global_position).limit_length(90.0) * 2.0
			if _timer <= 0.0:
				if _dives <= 0 or p == null or p.dead:
					_state = "volta"
				else:
					_state = "rasante"
					_timer = 0.6
					var d := p.global_position + Vector2(0, -6) - global_position
					velocity = d.normalized() * DIVE_SPEED
					dir = 1 if d.x > 0.0 else -1
					Sfx.play("gaivota")
		"rasante":
			if _timer <= 0.0 or is_on_floor():
				_dives -= 1
				_state = "sobe"
				_timer = 0.7
		"volta":
			_shout.visible = false
			velocity = (_home - global_position).limit_length(70.0)
			if global_position.distance_to(_home) < 3.0:
				global_position = _home
				_state = "chao"
				_cool = 2.5
	move_and_slide()
	if absf(velocity.x) > 1.0:
		dir = 1 if velocity.x > 0.0 else -1
	if _state == "chao":
		_sprite.texture = Art.tex("queroquero_%d" % (int(_t * 2.0) % 2))
		_sprite.flip_h = dir > 0
	else:
		_sprite.texture = Art.tex("queroquero_voo_%d" % (int(_t * 10.0) % 2))
		_sprite.flip_h = dir > 0
	if _timer < -0.6:
		_shout.visible = false


func stomp() -> void:
	dead = true
	collision_layer = 0
	_shout.visible = false
	_sprite.texture = Art.tex("queroquero_flat")
	get_tree().create_timer(0.5).timeout.connect(queue_free)


func knock() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	_shout.visible = false
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 16.0, 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
