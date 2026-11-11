extends Area2D
## Coisas que o jogador lança:
##   "piada"     balão de piada do microfone (Ceará): o inimigo fica rindo, parado
##   "disco"     disco de reggae (Maranhão): vai, volta como bumerangue e derruba tudo
##   "arremesso" inimigo agarrado pela pinça de caranguejo (Sergipe): cai e sai rolando
##               pelo chão derrubando quem estiver no caminho, até bater na parede

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const JOKES := ["É PAVÊ?", "TOC TOC!", "SABE DA ÚLTIMA?", "PERA, ESCUTA ESSA!", "HEIN? HEIN?"]

var kind := "piada"
var dir := 1
var shooter: Node2D
var texture: Texture2D
var velocity := Vector2.ZERO
var _t := 0.0
var _life := 1.0
var _gravity := 0.0
var _hit := {}
var _sprite: Sprite2D
var _text := ""


func _ready() -> void:
	add_to_group("player_shots")
	collision_layer = 0
	collision_mask = 4 | 1
	var cs := CollisionShape2D.new()
	_sprite = Sprite2D.new()
	add_child(_sprite)
	match kind:
		"piada":
			_text = JOKES[randi() % JOKES.size()]
			var rect := RectangleShape2D.new()
			rect.size = Vector2(_text.length() * 4 + 2, 9)
			cs.shape = rect
			var t := PixelText.new()
			t.text = _text
			t.align = 1
			t.shadow = false
			t.color = Color("2b1d2e")
			t.position = Vector2(0, -4)
			add_child(t)
			velocity = Vector2(dir * 150.0, 0.0)
			_life = 0.9
		"disco":
			collision_mask = 4     # o disco passa pelas paredes na volta
			var c := CircleShape2D.new()
			c.radius = 5.0
			cs.shape = c
			_sprite.texture = Art.tex("disco_voando")
			velocity = Vector2(dir * 190.0, 0.0)
			_life = 2.5
		_:
			collision_mask = 4     # o chão e a parede são vistos por raio (ele rola)
			var c := CircleShape2D.new()
			c.radius = 6.0
			cs.shape = c
			_sprite.texture = texture
			velocity = Vector2(dir * 200.0, -80.0)
			_gravity = 500.0
			_life = 2.5
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_t += delta
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	if kind == "disco":
		_sprite.rotation += delta * 20.0
		# Depois de um tempinho, volta para a mão de quem jogou.
		if _t > 0.45 and is_instance_valid(shooter):
			var to: Vector2 = shooter.global_position + Vector2(0, -9) - global_position
			velocity = velocity.move_toward(to.normalized() * 220.0, 700.0 * delta)
			if _t > 0.6 and to.length() < 12.0:
				queue_free()
	elif kind == "arremesso":
		_sprite.rotation += delta * 12.0 * dir
		if _roll(delta):
			return
	velocity.y += _gravity * delta
	position += velocity * delta


## Arremesso: quica no chão e rola; some quando bate na parede.
func _roll(delta: float) -> bool:
	var space := get_world_2d().direct_space_state
	var ahead := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(dir * 8.0, 0), 1)
	if not space.intersect_ray(ahead).is_empty():
		Sfx.play("bump")
		queue_free()
		return true
	if velocity.y >= 0.0:
		var step := velocity.y * delta + 7.0
		var down := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, step), 1)
		var hit := space.intersect_ray(down)
		if not hit.is_empty():
			global_position.y = hit["position"].y - 6.0
			velocity.y = 0.0
			global_position.x += velocity.x * delta
			return true
	return false


func _draw() -> void:
	if kind != "piada":
		return
	var w := _text.length() * 4 + 4
	draw_rect(Rect2(-w / 2.0 - 1, -5, w + 2, 11), Color("2b1d2e"))
	draw_rect(Rect2(-w / 2.0, -4, w, 9), Color("fbe3a0"))
	draw_rect(Rect2(-dir * (w / 2.0 - 3) - 1, 5, 3, 2), Color("fbe3a0"))


func _on_body_entered(body: Node) -> void:
	if body.has_method("stomp"):
		if body.dead or _hit.has(body):
			return
		_hit[body] = true
		match kind:
			"piada":
				if body.has_method("laugh"):
					body.laugh(3.0)
				else:
					body.knock()
				Sfx.play("risada")
				queue_free()
			"disco":
				body.knock()
			_:
				if body.has_method("hit_by_throw"):
					body.hit_by_throw()
				else:
					body.knock()
				Sfx.play("kick")
				queue_free()
	elif kind != "disco":
		queue_free()   # bateu no cenário
