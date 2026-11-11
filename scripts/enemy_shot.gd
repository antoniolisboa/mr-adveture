extends Area2D
## Projétil inimigo (trens do boss, bolinha de frescobol, biscoito do vendedor, mate).
## Machuca o jogador e some ao bater no cenário. Se for "rebatível", a raquete
## de frescobol manda de volta e aí ele derruba inimigos.

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

var kind := "panela"        # nome do sprite (scripts/art.gd)
var velocity := Vector2.ZERO
var fall_gravity := 500.0
var reflectable := true
var reflected := false
var label := ""             # se tiver texto, vira um balão de fala voador (frase de coach)
var joke := false           # piada do Ceará: em vez de machucar, faz o jogador rir parado
var _t := 0.0
var _life := 5.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 16
	collision_mask = 1 | 2
	var cs := CollisionShape2D.new()
	_sprite = Sprite2D.new()
	if label != "":
		var rect := RectangleShape2D.new()
		rect.size = Vector2(label.length() * 4 + 2, 7)
		cs.shape = rect
		var t := PixelText.new()
		t.text = label
		t.align = 1
		t.shadow = false
		t.color = Color("2b1d2e")
		t.position = Vector2(0, -4)
		add_child(t)
	else:
		var circle := CircleShape2D.new()
		circle.radius = 4.0
		cs.shape = circle
		_sprite.texture = Art.tex(kind)
	add_child(cs)
	add_child(_sprite)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_t += delta
	_life -= delta
	velocity.y += fall_gravity * delta
	position += velocity * delta
	_sprite.flip_h = int(_t * 10.0) % 2 == 0
	if _life <= 0.0:
		queue_free()


func _draw() -> void:
	if label == "":
		return
	var w := label.length() * 4 + 4
	draw_rect(Rect2(-w / 2.0 - 1, -5, w + 2, 11), Color("2b1d2e"))
	draw_rect(Rect2(-w / 2.0, -4, w, 9), Color.WHITE)
	var tail := -1.0 if velocity.x > 0.0 else 1.0
	draw_rect(Rect2(tail * (w / 2.0 - 3) - 1, 5, 3, 2), Color.WHITE)


func reflect(dir: int) -> void:
	if not reflectable or reflected:
		return
	reflected = true
	velocity = Vector2(dir * maxf(absf(velocity.x), 120.0) * 1.4, minf(velocity.y, -80.0))
	fall_gravity *= 0.5
	set_deferred("collision_mask", 1 | 4)
	_sprite.modulate = Color(1.0, 1.0, 0.6)
	Sfx.play("reflect")


## Bateu na panela de barro: faz "clang" e some.
func block() -> void:
	if reflected or is_queued_for_deletion():
		return
	Sfx.play("clang")
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("hurt"):
		if body.has_method("blocks") and body.blocks(global_position) and not reflected:
			block()
		elif not reflected and not body.dead:
			if joke:
				body.laugh(1.2)
			else:
				body.hurt()
			queue_free()
	elif body.has_method("knock"):
		if reflected and not body.dead:
			body.knock()
			queue_free()
	else:
		queue_free()   # bateu no cenário
