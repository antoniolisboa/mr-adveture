extends Area2D
## Fim do estado: o último lugar onde o caramelo esteve. A origem fica no chão.
## Estilos: "casinha" (casinha vazia, Minas), "barraca" (guarda-sol com a coleira, Rio)
## "abada" (cordão do bloco com um abadá de cachorro largado, Bahia)
## "moqueca" (panelinha de moqueca lambida e a espinha do peixe, Espírito Santo)
## e "cracha" (pufe de coworking com o crachá de estagiário do caramelo, São Paulo).

const PixelText := preload("res://scripts/pixel_text.gd")
const GoalNE := preload("res://scripts/goal_ne.gd")   # estilos do Nordeste
const GoalSul := preload("res://scripts/goal_sul.gd") # estilos do Sul

const INK := Color("2b1d2e")
const ROOF := Color("d64545")
const WALL := Color("c9a36b")
const WALL_DARK := Color("8a6a3f")
const PLATE := Color("f6eedb")

var style := "casinha"
var _done := false
var _plate: Node2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 32)
	cs.shape = rect
	cs.position = Vector2(0, -16)
	add_child(cs)

	if style == "casinha":
		_plate = PixelText.new()
		_plate.align = 1
		_plate.shadow = false
		_plate.color = INK
		_plate.position = Vector2(0, -26)
		_plate.text = "CARAMELO"
		add_child(_plate)
	elif style == "cracha":
		_plate = PixelText.new()
		_plate.align = 1
		_plate.position = Vector2(19, -30)
		_plate.text = "CARAMELO\nESTAGIÁRIO"
		add_child(_plate)
	body_entered.connect(_on_body_entered)


func _draw() -> void:
	if GoalNE.STYLES.has(style):
		GoalNE.draw(self, style)
		return
	if GoalSul.STYLES.has(style):
		GoalSul.draw(self, style)
		return
	if style == "barraca":
		_draw_barraca()
		return
	if style == "abada":
		_draw_abada()
		return
	if style == "moqueca":
		_draw_moqueca()
		return
	if style == "cracha":
		_draw_cracha()
		return
	# Telhado
	draw_colored_polygon(PackedVector2Array([
		Vector2(-23, -24), Vector2(0, -42), Vector2(23, -24)]), INK)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20, -25), Vector2(0, -40), Vector2(20, -25)]), ROOF)
	# Paredes de madeira
	draw_rect(Rect2(-19, -25, 38, 25), INK)
	draw_rect(Rect2(-18, -24, 36, 24), WALL)
	for y in [-17, -11, -5]:
		draw_rect(Rect2(-18, y, 36, 1), WALL_DARK)
	# Plaquinha com o nome
	draw_rect(Rect2(-18, -25, 36, 8), INK)
	draw_rect(Rect2(-17, -24, 34, 6), PLATE)
	# Porta
	draw_rect(Rect2(-6, -14, 12, 14), INK)
	draw_rect(Rect2(-4, -16, 8, 2), INK)
	# Vasilha vazia ao lado
	draw_rect(Rect2(24, -5, 12, 5), INK)
	draw_rect(Rect2(25, -4, 10, 3), ROOF)


## Guarda-sol listrado, cadeira de praia e a coleira vermelha esquecida.
func _draw_barraca() -> void:
	draw_rect(Rect2(-1, -40, 2, 40), INK)
	var colors := [ROOF, Color.WHITE]
	for i in 6:
		var x0 := -24 + i * 8
		draw_colored_polygon(PackedVector2Array([
			Vector2(x0, -36), Vector2(0, -46), Vector2(x0 + 8, -36)]), colors[i % 2])
	draw_rect(Rect2(-24, -36, 48, 2), INK)
	# Cadeira de praia
	draw_rect(Rect2(6, -10, 14, 2), INK)
	draw_rect(Rect2(6, -18, 2, 10), INK)
	draw_rect(Rect2(7, -17, 2, 8), Color("2bb3c0"))
	draw_rect(Rect2(8, -10, 11, 1), Color("2bb3c0"))
	draw_rect(Rect2(8, -8, 1, 8), INK)
	draw_rect(Rect2(18, -8, 1, 8), INK)
	# Coleira na areia
	draw_rect(Rect2(-14, -3, 8, 3), ROOF)
	draw_rect(Rect2(-12, -2, 4, 1), Color("ffe08a"))


## Fim do bloco: dois postes com a corda e um abadá pequenininho, do tamanho do
## caramelo, pendurado nela. Pegadas no chão seguem para fora da tela.
func _draw_abada() -> void:
	for x in [-22, 20]:
		draw_rect(Rect2(x, -30, 3, 30), INK)
		draw_rect(Rect2(x + 1, -29, 1, 28), Color("c9a36b"))
	for k in 14:
		var t := k / 14.0
		draw_rect(Rect2(-20 + t * 42, -26 + sin(t * PI) * 5.0, 3, 1), Color("f4f1e8"))
	# Abadá do caramelo
	draw_rect(Rect2(-6, -24, 12, 10), INK)
	draw_rect(Rect2(-5, -23, 10, 8), Color("f7d038"))
	draw_rect(Rect2(-9, -23, 4, 3), INK)
	draw_rect(Rect2(5, -23, 4, 3), INK)
	draw_rect(Rect2(-8, -22, 3, 1), Color("f7d038"))
	draw_rect(Rect2(5, -22, 3, 1), Color("f7d038"))
	draw_rect(Rect2(-3, -21, 6, 2), Color("2b5fb4"))
	draw_rect(Rect2(-2, -18, 4, 1), Color("2b5fb4"))
	# Pegadas
	for i in 4:
		var px := 26 + i * 9
		var py := -2 - (i % 2) * 3
		draw_rect(Rect2(px, py, 3, 2), Color("8a6a3f"))
		draw_rect(Rect2(px - 1, py - 2, 1, 1), Color("8a6a3f"))
		draw_rect(Rect2(px + 1, py - 3, 1, 1), Color("8a6a3f"))
		draw_rect(Rect2(px + 3, py - 2, 1, 1), Color("8a6a3f"))


## Uma panelinha de barro vazia, lambida até brilhar, a espinha do peixe do lado
## e as pegadas indo embora: o caramelo almoçou aqui.
func _draw_moqueca() -> void:
	# Toalha xadrez no chão
	for i in 8:
		draw_rect(Rect2(-24 + i * 6, -2, 6, 2), ROOF if i % 2 == 0 else Color.WHITE)
	# Panelinha
	draw_rect(Rect2(-13, -13, 26, 11), INK)
	draw_rect(Rect2(-12, -12, 24, 9), Color("43352e"))
	draw_rect(Rect2(-10, -11, 2, 6), Color("75604f"))
	draw_rect(Rect2(-17, -12, 4, 4), INK)
	draw_rect(Rect2(13, -12, 4, 4), INK)
	draw_rect(Rect2(-14, -15, 28, 3), INK)
	draw_rect(Rect2(-12, -14, 24, 1), Color("e8622a"))   # só o restinho do caldo
	# Brilho de panela lambida
	draw_rect(Rect2(4, -10, 1, 3), Color("ffffff"))
	draw_rect(Rect2(3, -9, 3, 1), Color("ffffff"))
	# Espinha do peixe
	draw_rect(Rect2(-30, -4, 12, 1), Color("f4f1e8"))
	for k in 4:
		draw_rect(Rect2(-28 + k * 3, -6, 1, 5), Color("f4f1e8"))
	draw_colored_polygon(PackedVector2Array([Vector2(-18, -4), Vector2(-14, -7), Vector2(-14, -1)]), Color("f4f1e8"))
	# Pegadas
	for i in 4:
		var px := 22 + i * 9
		var py := -2 - (i % 2) * 3
		draw_rect(Rect2(px, py, 3, 2), Color("8a6a3f"))
		draw_rect(Rect2(px - 1, py - 2, 1, 1), Color("8a6a3f"))
		draw_rect(Rect2(px + 1, py - 3, 1, 1), Color("8a6a3f"))
		draw_rect(Rect2(px + 3, py - 2, 1, 1), Color("8a6a3f"))


## Um pufe de coworking amassado no formato de um cachorro, o crachá
## "CARAMELO - ESTAGIÁRIO" largado do lado e as pegadas indo embora.
func _draw_cracha() -> void:
	# Pufe
	draw_rect(Rect2(-20, -11, 26, 11), INK)
	draw_rect(Rect2(-19, -10, 24, 10), Color("f07a2a"))
	draw_rect(Rect2(-15, -12, 16, 3), INK)
	draw_rect(Rect2(-14, -11, 14, 2), Color("f07a2a"))
	draw_rect(Rect2(-12, -8, 10, 3), Color("c85a1a"))      # marca do cochilo
	draw_rect(Rect2(-9, -9, 3, 1), Color("d9913f"))        # pelinho caramelo
	draw_rect(Rect2(-4, -7, 2, 1), Color("d9913f"))
	# Cordão e crachá
	for k in 8:
		draw_rect(Rect2(8 + k, -2 - absf(k - 4) * 0.5, 1, 1), Color("2b5fb4"))
	draw_rect(Rect2(14, -8, 10, 8), INK)
	draw_rect(Rect2(15, -7, 8, 6), Color.WHITE)
	draw_rect(Rect2(16, -6, 3, 3), Color("d9913f"))
	draw_rect(Rect2(20, -6, 2, 1), INK)
	draw_rect(Rect2(20, -4, 2, 1), INK)
	# Pegadas
	for i in 4:
		var px := 28 + i * 9
		var py := -2 - (i % 2) * 3
		draw_rect(Rect2(px, py, 3, 2), Color("8a6a3f"))
		draw_rect(Rect2(px - 1, py - 2, 1, 1), Color("8a6a3f"))
		draw_rect(Rect2(px + 1, py - 3, 1, 1), Color("8a6a3f"))
		draw_rect(Rect2(px + 3, py - 2, 1, 1), Color("8a6a3f"))


func _on_body_entered(body: Node) -> void:
	if _done or not body.has_method("hurt") or body.dead:
		return
	_done = true
	body.frozen = true
	Sfx.play("clear")
	Game.level_cleared.emit()
