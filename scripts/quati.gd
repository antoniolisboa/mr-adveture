extends "res://scripts/walker.gd"
## Inimigo do Paraná: quati das Cataratas, o maior ladrão de lanche de turista.
## Passeia com o rabo listrado em pé; quando vê o jogador na mesma altura, corre
## para cima dele. Se o jogador estiver com o item, o quati ROUBA o item (em vez de
## machucar) e foge com ele na cabeça. Pisar no ladrão devolve o item.

const Powers := preload("res://scripts/powers.gd")

var _loot := ""                 # item roubado ("" = nada)
var _loot_sprite: Sprite2D
var _flee := 0.0


func _setup() -> void:
	sprite_name = "quati"
	size = Vector2(14, 10)
	speed = 30.0
	stomp_line = 6.0
	anim_fps = 8.0


func _after_ready() -> void:
	_loot_sprite = Sprite2D.new()
	_loot_sprite.position = Vector2(0, -20)
	_loot_sprite.visible = false
	add_child(_loot_sprite)


func _behave(delta: float) -> void:
	var p := _player()
	if _loot != "":
		# Foge do jogador, rindo.
		_flee += delta
		if p:
			dir = -1 if p.global_position.x > global_position.x else 1
		turn_at_ledges = false
		_walk(delta, 110.0)
		if is_on_wall():
			velocity.y = -200.0
		return
	if p and not p.dead and absf(p.global_position.y - global_position.y) < 24.0 \
			and absf(p.global_position.x - global_position.x) < 110.0:
		dir = 1 if p.global_position.x > global_position.x else -1
		_walk(delta, 85.0)
	else:
		_walk(delta, speed)


## Chamado pelo jogador quando encosta com item: o quati leva o item.
func steal(power_id: String) -> void:
	_loot = power_id
	_loot_sprite.texture = Art.tex(Powers.POWERS[power_id]["item"])
	_loot_sprite.visible = true
	_laugh_text.text = "HEHE!"
	_laugh_text.visible = true
	Sfx.play("quati")


func has_loot() -> bool:
	return _loot != ""


func harmless() -> bool:
	return _loot != "" or super.harmless()


func stomp() -> void:
	if _loot != "":
		Game.set_power(_loot)    # devolve o lanche... digo, o item
		_loot = ""
		_loot_sprite.visible = false
	super.stomp()


func knock() -> void:
	if _loot != "" and not dead:
		Game.set_power(_loot)
		_loot = ""
		_loot_sprite.visible = false
	super.knock()
