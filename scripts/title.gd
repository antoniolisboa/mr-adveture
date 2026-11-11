extends Node2D
## Tela inicial: escolha entre ele e ela.

signal started(character: String)

const Art := preload("res://scripts/art.gd")
const PixelText := preload("res://scripts/pixel_text.gd")

const SLOT_X := [100, 172]   # x de cada personagem (desenhados em escala 3)
const SPRITE_Y := 100

var choice := 0
var _t := 0.0


func _ready() -> void:
	_text("RESGATE DO CARAMELO", Vector2(160, 8), 2, Color("f7d038"))
	_text("PROTÓTIPO: SUDESTE E NORDESTE INTEIROS", Vector2(160, 34), 1, Color.WHITE)
	_text("ESCOLHA SEU PERSONAGEM", Vector2(160, 62), 1, Color.WHITE)
	_text("ELE", Vector2(SLOT_X[0] + 24, 86), 1, Color.WHITE)
	_text("ELA", Vector2(SLOT_X[1] + 24, 86), 1, Color.WHITE)
	_text("PROCURA-SE", Vector2(282, 104), 1, Color("d64545"))
	_text("SETAS: ESCOLHER   ENTER: COMEÇAR", Vector2(160, 152), 1, Color.WHITE)
	_text("Z: PULAR   X: USAR O ITEM   R: VOLTAR AO CARTAZ", Vector2(160, 164), 1, Color("fbe3a0"))


func _text(s: String, pos: Vector2, px: int, col: Color) -> Node2D:
	var t := PixelText.new()
	t.text = s
	t.position = pos
	t.pixel = px
	t.align = 1
	t.color = col
	add_child(t)
	return t


func _process(delta: float) -> void:
	_t += delta
	if Input.is_action_just_pressed("left"):
		choice = 0
	elif Input.is_action_just_pressed("right"):
		choice = 1
	elif Input.is_action_just_pressed("confirm"):
		started.emit("m" if choice == 0 else "f")
		return
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), Color("8fd3ff"))
	for i in 20:
		draw_texture(Art.tex("ground_top"), Vector2(i * 16, 148))
		draw_texture(Art.tex("ground"), Vector2(i * 16, 164))

	for i in 2:
		var ch := "m" if i == 0 else "f"
		var selected := i == choice
		# O escolhido corre no lugar; o outro fica parado.
		var frame := "idle"
		if selected:
			frame = "run1" if int(_t * 8.0) % 2 == 0 else "run2"
		var x: int = SLOT_X[i]
		if selected:
			draw_rect(Rect2(x - 4, SPRITE_Y - 4, 56, 52), Color(1, 1, 1, 0.25))
			draw_rect(Rect2(x - 4, SPRITE_Y - 4, 56, 52), Color("f7d038"), false, 1.0)
		draw_set_transform(Vector2(x, SPRITE_Y), 0.0, Vector2(3, 3))
		draw_texture(Art.tex("player_%s_%s_none" % [ch, frame]), Vector2.ZERO)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# O caramelo desaparecido.
	draw_set_transform(Vector2(266, 116), 0.0, Vector2(2, 2))
	draw_texture(Art.tex("caramelo"), Vector2.ZERO)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
