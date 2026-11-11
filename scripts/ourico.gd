extends "res://scripts/walker.gd"
## Inimigo de Alagoas: ouriço-do-mar parado no recife. Espinhento: pisar machuca.
## Só sai do caminho com um golpe.


func _setup() -> void:
	sprite_name = "ourico"
	size = Vector2(12, 8)
	stompable = false
	stomp_line = 99.0
	anim_fps = 3.0


func _behave(delta: float) -> void:
	_walk(delta, 0.0)
