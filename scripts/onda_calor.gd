extends "res://scripts/walker.gd"
## Inimigo do Piauí: onda de calor do meio-dia. Flutua tremendo e vem devagar atrás
## do jogador, atravessando tudo. Não dá para pisar (queima o pé). O vento do leque
## (ou qualquer golpe) desmancha a onda.

var _home_y := 0.0


func _setup() -> void:
	size = Vector2(14, 14)
	speed = 24.0
	stompable = false
	stomp_line = 99.0
	gravity = 0.0
	wake_distance = 180.0


func _after_ready() -> void:
	collision_mask = 0          # atravessa parede
	_home_y = global_position.y
	add_to_group("ondas_calor")


func _behave(delta: float) -> void:
	var p := _player()
	if p == null:
		return
	var to: Vector2 = p.global_position + Vector2(0, -8) - global_position
	velocity = to.normalized() * speed
	position += velocity * delta
	dir = 1 if to.x > 0.0 else -1
	queue_redraw()


func _animate() -> void:
	queue_redraw()


func _draw() -> void:
	if dead:
		return
	for i in 5:
		var y := -14.0 + i * 3.0
		var wob := sin(_t * 8.0 + i * 1.3) * 3.0
		var w := 12.0 - absf(i - 2.0) * 2.0
		draw_rect(Rect2(-w / 2.0 + wob, y, w, 2), Color(1.0, 0.6 - i * 0.07, 0.2, 0.75))
	draw_rect(Rect2(-3 + sin(_t * 8.0) * 2.0, -10, 2, 2), Color("2b1d2e"))
	draw_rect(Rect2(2 + sin(_t * 8.0) * 2.0, -10, 2, 2), Color("2b1d2e"))


func knock() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	Sfx.play("leque")
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)
