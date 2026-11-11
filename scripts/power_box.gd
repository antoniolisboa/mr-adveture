extends StaticBody2D
## Caixa de poder: uma cabeçada por baixo solta o item do estado
## (Minas: pão de queijo; Rio: raquete de frescobol). A origem fica no canto superior esquerdo.

const Art := preload("res://scripts/art.gd")
const Pickup := preload("res://scripts/pickup.gd")

var used := false
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	cs.shape = rect
	cs.position = Vector2(8, 8)
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.texture = Art.tex("box")
	add_child(_sprite)


func bump() -> void:
	if used:
		return
	used = true
	Sfx.play("bump")
	Sfx.play("item")
	_sprite.texture = Art.tex("box_used")
	var tw := create_tween()
	tw.tween_property(_sprite, "position:y", -4.0, 0.06)
	tw.tween_property(_sprite, "position:y", 0.0, 0.08)

	var item := Pickup.new()
	item.kind = "power"
	item.power_id = Game.state_power
	item.rising = true
	var player := get_tree().get_first_node_in_group("player")
	if player and "facing" in player:
		item.dir = 1 if player.facing >= 0 else -1
	item.position = position + Vector2(8, 8)
	get_parent().add_child(item)
