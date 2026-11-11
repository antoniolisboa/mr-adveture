extends Area2D
## Placa verde de saída: fim de uma fase intermediária. A origem fica no chão.

const PixelText := preload("res://scripts/pixel_text.gd")

const POST := Color("8a6a3f")
const BOARD := Color("2e7d32")
const EDGE := Color("ffffff")
const INK := Color("2b1d2e")

var _done := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 40)
	cs.shape = rect
	cs.position = Vector2(0, -20)
	add_child(cs)

	var label := PixelText.new()
	label.align = 1
	label.shadow = false
	label.position = Vector2(0, -38)
	label.text = "SAÍDA >"
	add_child(label)
	body_entered.connect(_on_body_entered)


func _draw() -> void:
	draw_rect(Rect2(-2, -28, 4, 28), INK)
	draw_rect(Rect2(-1, -28, 2, 28), POST)
	draw_rect(Rect2(-19, -41, 38, 16), INK)
	draw_rect(Rect2(-18, -40, 36, 14), EDGE)
	draw_rect(Rect2(-17, -39, 34, 12), BOARD)


func _on_body_entered(body: Node) -> void:
	if _done or not body.has_method("hurt") or body.dead:
		return
	_done = true
	body.frozen = true
	Sfx.play("clear")
	Game.level_cleared.emit()
