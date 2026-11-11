extends CharacterBody2D
## Inimigo do Espírito Santo: robalo de perninhas. Anda devagar; quando vê o jogador,
## solta um "!" e corre atrás dele... mas logo esquece que ele existe ("?"),
## vira de costas e volta a passear. Morre com pisão ou panelada. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const GRAVITY := 900.0
const WALK_SPEED := 20.0
const CHASE_SPEED := 72.0
const SIGHT := 100.0
const CHASE_TIME := 1.6        # quanto tempo ele lembra do jogador
const FORGET_TIME := 1.0       # parado com cara de "ué?"
const MEMORY_GAP := 2.5        # depois de esquecer, demora para reparar de novo
const WAKE_DISTANCE := 200.0

var dir := -1
var dead := false
var stomp_line := 6.0
var _active := false
var _state := "walk"           # walk -> chase -> forget -> walk
var _timer := 0.0
var _gap := 0.0
var _t := 0.0
var _sprite: Sprite2D
var _mark: Node2D


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
	_sprite.texture = Art.tex("robalo_0")
	add_child(_sprite)
	_mark = PixelText.new()
	_mark.align = 1
	_mark.position = Vector2(0, -22)
	_mark.visible = false
	add_child(_mark)


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
	velocity.y = minf(velocity.y + GRAVITY * delta, 320.0)
	match _state:
		"walk":
			velocity.x = dir * WALK_SPEED
			var p := _player()
			if p and not p.dead and _gap <= 0.0 and is_on_floor():
				var dx := p.global_position.x - global_position.x
				if absf(dx) < SIGHT and absf(p.global_position.y - global_position.y) < 30.0:
					dir = 1 if dx > 0.0 else -1
					_state = "chase"
					_timer = CHASE_TIME
					_show_mark("!", Color("ffe08a"))
					Sfx.play("alerta")
		"chase":
			var p := _player()
			if p:
				var dx := p.global_position.x - global_position.x
				if absf(dx) > 6.0:
					dir = 1 if dx > 0.0 else -1
			velocity.x = dir * CHASE_SPEED
			if _timer <= CHASE_TIME - 0.5:
				_mark.visible = false
			if _timer <= 0.0:
				_state = "forget"
				_timer = FORGET_TIME
				_show_mark("?", Color.WHITE)
				Sfx.play("esquece")
		"forget":
			velocity.x = 0.0
			# Olha para um lado e para o outro, procurando quem era mesmo.
			dir = 1 if int(_t * 3.0) % 2 == 0 else -1
			if _timer <= 0.0:
				_mark.visible = false
				_state = "walk"
				_gap = MEMORY_GAP
				var p := _player()
				if p:
					dir = -1 if p.global_position.x > global_position.x else 1
	move_and_slide()
	if is_on_wall():
		dir = -dir
	# Passeando ele não cai dos buracos; correndo atrás do jogador, cai.
	if _state == "walk" and is_on_floor() and not _ground_ahead():
		dir = -dir
	if global_position.y > 600.0:
		queue_free()

	var speed := 14.0 if _state == "chase" else 5.0
	if _state == "forget":
		speed = 0.0
	_sprite.texture = Art.tex("robalo_%d" % (int(_t * speed) % 2))
	_sprite.flip_h = dir > 0


func _show_mark(text: String, color: Color) -> void:
	_mark.text = text
	_mark.color = color
	_mark.visible = true


func _ground_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(dir * 8.0, -2.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 8), 1)
	return not space.intersect_ray(q).is_empty()


func stomp() -> void:
	dead = true
	collision_layer = 0
	_mark.visible = false
	_sprite.texture = Art.tex("robalo_flat")
	get_tree().create_timer(0.5).timeout.connect(queue_free)


func knock() -> void:
	dead = true
	collision_layer = 0
	_mark.visible = false
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 20.0, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
