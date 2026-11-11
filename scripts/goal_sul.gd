extends RefCounted
## Fim de estado do Sul: o que o caramelo deixou para trás em cada lugar.
## Chamado por scripts/goal.gd, que passa a si mesmo (g) para desenhar.

const STYLES := {
	"touca": "pinhões descascados e uma touquinha de tricô do tamanho do caramelo, no frio de Curitiba (Paraná)",
	"prancha": "pranchinha de surfe fincada na areia, com a borda toda mordida (Santa Catarina)",
	"cuia": "cuia de chimarrão virada, a bomba mordida e um pelego cheio de pelo caramelo (Rio Grande do Sul)",
}

const INK := Color("2b1d2e")
const PAW := Color("8a6a3f")
const CARAMELO := Color("d9913f")


static func draw(g, style: String) -> void:
	match style:
		"touca":
			_touca(g)
		"prancha":
			_prancha(g)
		"cuia":
			_cuia(g)


## Pegadas do caramelo indo embora para a direita.
static func _pegadas(g, x0: float, n: int) -> void:
	for i in n:
		var px := x0 + i * 9
		var py := -2 - (i % 2) * 3
		g.draw_rect(Rect2(px, py, 3, 2), PAW)
		g.draw_rect(Rect2(px - 1, py - 2, 1, 1), PAW)
		g.draw_rect(Rect2(px + 1, py - 3, 1, 1), PAW)
		g.draw_rect(Rect2(px + 3, py - 2, 1, 1), PAW)


static func _box(g, r: Rect2, col: Color) -> void:
	g.draw_rect(r.grow(1.0), INK)
	g.draw_rect(r, col)


static func _touca(g) -> void:
	# Touquinha de tricô listrada com pompom.
	_box(g, Rect2(-20, -10, 16, 10), Color("d64545"))
	for k in 3:
		g.draw_rect(Rect2(-20, -8 + k * 3, 16, 1), Color("f4f1e8"))
	g.draw_circle(Vector2(-12, -13), 4.0, INK)
	g.draw_circle(Vector2(-12, -13), 3.0, Color("f4f1e8"))
	g.draw_rect(Rect2(-17, -4, 3, 1), CARAMELO)          # pelinho
	# Pinhões descascados e as cascas
	for k in 4:
		var x := 0.0 + k * 5.0
		_box(g, Rect2(x, -4, 3, 4), Color("f0d8a8") if k % 2 == 0 else Color("7a3a2a"))
	_pegadas(g, 24, 4)


static func _prancha(g) -> void:
	# Pranchinha fincada em pé na areia, com mordidas na borda.
	var pts := PackedVector2Array([Vector2(-14, 0), Vector2(-17, -16), Vector2(-14, -30),
			Vector2(-10, -16), Vector2(-11, 0)])
	g.draw_colored_polygon(pts, INK)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-13, -1), Vector2(-16, -16), Vector2(-14, -28),
			Vector2(-11, -16), Vector2(-12, -1)]), Color("5aa0e0"))
	g.draw_rect(Rect2(-14, -22, 1, 14), Color("f7d038"))
	for y in [-20, -12]:
		g.draw_rect(Rect2(-11, y, 2, 2), Color("f2d58a"))     # mordidas
	g.draw_rect(Rect2(-20, -1, 14, 1), Color("d9b866"))
	g.draw_rect(Rect2(-6, -5, 3, 1), CARAMELO)
	_pegadas(g, 6, 5)


static func _cuia(g) -> void:
	# Pelego (pele de ovelha) no chão
	_box(g, Rect2(-26, -3, 22, 3), Color("ece6d6"))
	for k in 4:
		g.draw_rect(Rect2(-24 + k * 5, -5, 3, 2), Color("ece6d6"))
	g.draw_rect(Rect2(-20, -4, 4, 1), CARAMELO)
	g.draw_rect(Rect2(-12, -3, 3, 1), CARAMELO)
	# Cuia virada de lado com a erva derramada e a bomba mordida
	g.draw_circle(Vector2(4, -6), 6.0, INK)
	g.draw_circle(Vector2(4, -6), 5.0, Color("b07a3a"))
	g.draw_rect(Rect2(9, -8, 3, 5), Color("7a5228"))
	g.draw_rect(Rect2(12, -3, 8, 3), Color("3c8d2f"))
	g.draw_line(Vector2(2, -9), Vector2(-4, -18), INK, 3.0)
	g.draw_line(Vector2(2, -9), Vector2(-4, -18), Color("cfd6de"), 1.0)
	g.draw_rect(Rect2(-4, -16, 2, 1), Color("7a5228"))     # marca de dente
	_pegadas(g, 24, 4)
