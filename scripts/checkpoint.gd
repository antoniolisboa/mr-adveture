extends Area2D
## Cartaz de PROCURA-SE: serve de checkpoint. A origem fica no chão.

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

var _label: Node2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 32)
	cs.shape = rect
	cs.position = Vector2(0, -16)
	add_child(cs)

	var sprite := Sprite2D.new()
	sprite.texture = Art.tex("cartaz")
	sprite.position = Vector2(0, -16)
	add_child(sprite)

	_label = PixelText.new()
	_label.align = 1
	_label.position = Vector2(0, -46)
	_label.color = Color("f7d038")
	_label.visible = Game.checkpoint == global_position
	_label.text = "SALVO!"
	add_child(_label)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.has_method("hurt") or body.dead:
		return
	if Game.checkpoint != global_position:
		Game.reach_checkpoint(global_position)
		_label.visible = true
