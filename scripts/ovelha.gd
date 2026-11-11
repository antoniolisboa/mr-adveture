extends "res://scripts/walker.gd"
## Ovelha do pampa (Rio Grande do Sul): não é inimiga. Pasta devagar e não machuca;
## pisar nela faz "BÉÉ" e o jogador quica bem alto na lã fofa (bom para alcançar
## lugares altos). Golpe só assusta: ela dá um pulinho e continua pastando.

var bouncy := true
var grabbable := false         # a pinça de Sergipe não pega ovelha
var _squish := 0.0


func _setup() -> void:
	sprite_name = "ovelha"
	size = Vector2(14, 12)
	speed = 10.0
	stomp_line = 8.0
	anim_fps = 2.0


func _behave(delta: float) -> void:
	_squish -= delta
	if _squish > 0.0:
		_walk(delta, 0.0)
		_sprite.texture = Art.tex("ovelha_flat")
		return
	_walk(delta, speed)


func _animate() -> void:
	if _squish > 0.0:
		return
	super._animate()
	_laugh_text.visible = _laugh > 0.0 or _squish > -0.4


func harmless() -> bool:
	return true


func stomp() -> void:
	_squish = 0.25
	_laugh_text.text = "BÉÉ!"
	_laugh_text.visible = true
	Sfx.play("bee")


func knock() -> void:
	if is_on_floor():
		velocity.y = -160.0
	dir = -dir
	_squish = -0.01
	_laugh_text.text = "BÉÉ?"
	_laugh_text.visible = true
	Sfx.play("bee")
