extends CharacterBody2D
## Pão de queijo arremessado: quica no chão e derruba inimigos.

const Art := preload("res://scripts/art.gd")

const SPEED := 170.0
const GRAVITY := 700.0
const BOUNCE := -170.0

var dir := 1
var _life := 2.0
var _sprite: Sprite2D


func _ready() -> void:
	add_to_group("projectiles")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 3.0
	cs.shape = circle
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.texture = Art.tex("pao_small")
	add_child(_sprite)

	var hit := Area2D.new()
	hit.collision_layer = 0
	hit.collision_mask = 4
	var hs := CollisionShape2D.new()
	var hc := CircleShape2D.new()
	hc.radius = 5.0
	hs.shape = hc
	hit.add_child(hs)
	hit.body_entered.connect(_on_hit)
	add_child(hit)

	velocity = Vector2(dir * SPEED, 0.0)


func _physics_process(delta: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 300.0)
	var col := move_and_collide(velocity * delta)
	if col:
		if col.get_normal().y < -0.5:
			velocity.y = BOUNCE
			_sprite.flip_h = not _sprite.flip_h
		else:
			queue_free()
			return
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_hit(body: Node) -> void:
	if body.has_method("knock") and not body.dead:
		body.knock()
		queue_free()
