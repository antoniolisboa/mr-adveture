extends CharacterBody2D
## Inimigo do Rio: frescobolista na areia que arremessa bolinhas no jogador.
## A bolinha pode ser rebatida com a raquete. A origem fica nos pés.

const Art := preload("res://scripts/art.gd")
const EnemyShot := preload("res://scripts/enemy_shot.gd")

const GRAVITY := 900.0
const RANGE := 190.0          # só joga quando o jogador está perto
const INTERVAL := 2.2

var facing := -1
var dead := false
var stomp_line := 14.0
var _timer := 1.0
var _swing := 0.0
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
	_sprite.texture = Art.tex("frescobolista_0")
	add_child(_sprite)


func _physics_process(delta: float) -> void:
	if dead:
		return
	velocity = Vector2(0.0, minf(velocity.y + GRAVITY * delta, 320.0))
	move_and_slide()
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p and not p.dead:
		facing = 1 if p.global_position.x > global_position.x else -1
		if absf(p.global_position.x - global_position.x) < RANGE:
			_timer -= delta
			if _timer <= 0.0:
				_timer = INTERVAL
				_serve()
	_swing -= delta
	_sprite.texture = Art.tex("frescobolista_1" if _swing > 0.0 else "frescobolista_0")
	_sprite.flip_h = facing > 0


func _serve() -> void:
	_swing = 0.3
	var b := EnemyShot.new()
	b.kind = "bolinha"
	b.fall_gravity = 120.0
	b.position = position + Vector2(facing * 10, -16)
	b.velocity = Vector2(facing * 110.0, -40.0)
	get_parent().add_child(b)
	Sfx.play("serve")


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
