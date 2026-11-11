extends CharacterBody2D
## Inimigo de São Paulo: coach de colete. Fica parado e, quando o jogador chega perto,
## dispara frases motivacionais em balões que voam na altura da cabeça (pule por cima).
## Morre com pisão ou golpe. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")
const EnemyShot := preload("res://scripts/enemy_shot.gd")

const GRAVITY := 900.0
const RANGE := 150.0
const INTERVAL := 2.2
const PHRASES := ["FOCO!", "BORA!", "MINDSET!", "SINERGIA!", "ACREDITA!", "VAI QUE VAI!"]

var dead := false
var stomp_line := 18.0
var facing := -1
var _timer := 1.0
var _talk := 0.0
var _rng := RandomNumberGenerator.new()
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 22)
	cs.shape = rect
	cs.position = Vector2(0, -11)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -12)
	_sprite.texture = Art.tex("coach_0")
	add_child(_sprite)
	_rng.seed = int(position.x)


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if dead:
		return
	velocity.y = minf(velocity.y + GRAVITY * delta, 320.0)
	velocity.x = 0.0
	move_and_slide()
	_talk -= delta
	var p := _player()
	if p and not p.dead:
		var dx := p.global_position.x - global_position.x
		facing = 1 if dx > 0.0 else -1
		if absf(dx) < RANGE and absf(p.global_position.y - global_position.y) < 40.0:
			_timer -= delta
			if _timer <= 0.0:
				_timer = INTERVAL
				_speak()
	_sprite.texture = Art.tex("coach_1" if _talk > 0.0 else "coach_0")
	_sprite.flip_h = facing > 0


func _speak() -> void:
	var s := EnemyShot.new()
	s.label = PHRASES[_rng.randi() % PHRASES.size()]
	s.reflectable = true
	s.fall_gravity = 0.0
	s.position = position + Vector2(facing * 14.0, -14.0)
	s.velocity = Vector2(facing * 85.0, 0.0)
	get_parent().add_child(s)
	_talk = 0.4
	Sfx.play("fala")


func stomp() -> void:
	knock()


func knock() -> void:
	dead = true
	collision_layer = 0
	_sprite.flip_v = true
	Sfx.play("kick")
	z_index = 10
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 16.0, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y + 220.0, 0.7).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
