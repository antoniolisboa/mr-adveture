extends RefCounted
## Fim de estado do Nordeste: o que o caramelo deixou para trás em cada lugar.
## Chamado por scripts/goal.gd, que passa a si mesmo (g) para desenhar.

const STYLES := {
	"frevo": "sombrinha de frevo caída e um pedaço de bolo de rolo mordido (Pernambuco)",
	"caju": "castanha de caju largada e o caju mordido, com marca de dente de cachorro (Rio Grande do Norte)",
	"rede": "rede armada entre dois coqueiros, ainda balançando, cheia de pelo caramelo (Ceará)",
	"boi": "boizinho de brinquedo bordado, com uma fita mordida (Maranhão)",
	"cajuina": "garrafinha de cajuína vazia na sombra de um cajueiro, e o caramelo já foi (Piauí)",
	"castelo": "castelo de areia todo cavado por patinhas, com uma conchinha no topo (Alagoas)",
	"martelinho": "tábua com o martelinho de quebrar caranguejo e um caranguejinho dando tchau (Sergipe)",
	"milho": "fogueira apagando e uma espiga de milho roída até o sabugo (Paraíba)",
}

const INK := Color("2b1d2e")
const PAW := Color("8a6a3f")
const CARAMELO := Color("d9913f")


static func draw(g, style: String) -> void:
	match style:
		"frevo":
			_frevo(g)
		"milho":
			_milho(g)
		"caju":
			_caju(g)
		"rede":
			_rede(g)
		"boi":
			_boizinho(g)
		"cajuina":
			_cajuina(g)
		"castelo":
			_castelo(g)
		"martelinho":
			_martelinho(g)


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


static func _frevo(g) -> void:
	# Sombrinha caída de lado, aberta.
	var cols := [Color("2a9d4a"), Color("f7d038"), Color("d64545"), Color("3f8fd1")]
	g.draw_rect(Rect2(-23, -13, 22, 9), INK)
	for i in 4:
		g.draw_rect(Rect2(-22 + i * 5, -12 + absf(i - 1.5) * 1.0, 5, 8 - absf(i - 1.5) * 1.0), cols[i])
	g.draw_rect(Rect2(-12, -4, 2, 4), INK)
	g.draw_rect(Rect2(-12, -1, 10, 1), INK)
	# Bolo de rolo mordido (as camadinhas enroladas).
	_box(g, Rect2(4, -9, 12, 9), Color("e0a03c"))
	for k in 3:
		g.draw_rect(Rect2(6 + k * 3, -7, 1, 5), Color("a8542a"))
	g.draw_rect(Rect2(13, -9, 3, 1), INK)              # marca da mordida
	g.draw_rect(Rect2(14, -8, 2, 1), INK)
	g.draw_rect(Rect2(5, -11, 2, 1), CARAMELO)          # pelinho caramelo
	_pegadas(g, 24, 4)


static func _milho(g) -> void:
	# Fogueira já virando brasa.
	for k in 3:
		_box(g, Rect2(-24 + k * 4, -5 + (k % 2) * 2, 16, 3), Color("5a3a22"))
	g.draw_rect(Rect2(-20, -8, 3, 2), Color("f07a2a"))
	g.draw_rect(Rect2(-14, -9, 2, 3), Color("d64545"))
	g.draw_rect(Rect2(-17, -14, 1, 4), Color(0.8, 0.8, 0.85, 0.6))   # fumacinha
	g.draw_rect(Rect2(-15, -18, 1, 3), Color(0.8, 0.8, 0.85, 0.4))
	# Espiga roída: o sabugo e dois grãos que sobraram.
	_box(g, Rect2(2, -4, 14, 4), Color("e8d0a0"))
	g.draw_rect(Rect2(3, -4, 2, 2), Color("f7d038"))
	g.draw_rect(Rect2(13, -3, 2, 2), Color("f7d038"))
	g.draw_rect(Rect2(16, -5, 4, 5), Color("6fae6a"))                 # palha
	g.draw_rect(Rect2(6, -6, 2, 1), CARAMELO)
	_pegadas(g, 26, 4)


static func _caju(g) -> void:
	# Cajueiro baixinho (de praia) com sombra.
	_box(g, Rect2(-22, -18, 4, 18), Color("7a4a2a"))
	g.draw_circle(Vector2(-20, -24), 11.0, INK)
	g.draw_circle(Vector2(-20, -24), 10.0, Color("2f7a3a"))
	g.draw_circle(Vector2(-16, -27), 5.0, Color("3c8d2f"))
	g.draw_rect(Rect2(-26, -19, 4, 5), Color("e85a3a"))
	# Caju mordido no chão e a castanha.
	_box(g, Rect2(2, -7, 8, 7), Color("e85a3a"))
	g.draw_rect(Rect2(7, -7, 3, 2), INK)
	_box(g, Rect2(3, -10, 5, 3), Color("7a4a2a"))
	g.draw_rect(Rect2(4, -12, 2, 1), CARAMELO)
	_pegadas(g, 22, 4)


static func _rede(g) -> void:
	_box(g, Rect2(-26, -30, 3, 30), Color("8a6a3f"))
	_box(g, Rect2(8, -30, 3, 30), Color("8a6a3f"))
	var sway = sin(Time.get_ticks_msec() / 300.0) * 2.0
	for x in range(-23, 8):
		var t = (x + 23) / 31.0
		var y = -24 + sin(t * PI) * 10.0 + sway * sin(t * PI)
		g.draw_rect(Rect2(x, y, 1, 3), [Color("d64545"), Color("f7d038"), Color("3f8fd1")][(x + 30) / 4 % 3])
	g.draw_rect(Rect2(-12, -16 + sway, 3, 1), CARAMELO)
	g.draw_rect(Rect2(-6, -15 + sway, 2, 1), CARAMELO)
	_pegadas(g, 20, 4)


static func _boizinho(g) -> void:
	# Boizinho de brinquedo: corpo de veludo com miçangas e a fita mordida.
	_box(g, Rect2(-20, -12, 18, 8), Color("1a1a2e"))
	_box(g, Rect2(-24, -16, 7, 7), Color("1a1a2e"))
	g.draw_rect(Rect2(-26, -19, 2, 3), Color("f4f1e8"))
	g.draw_rect(Rect2(-19, -19, 2, 3), Color("f4f1e8"))
	g.draw_rect(Rect2(-22, -14, 2, 2), Color("f2c94c"))
	for k in 4:
		g.draw_rect(Rect2(-18 + k * 4, -10, 2, 2), [Color("f7d038"), Color("e85d75"), Color("3f8fd1"), Color("2a9d4a")][k])
	_box(g, Rect2(-20, -4, 18, 4), Color("d64545"))
	# Fita mordida largada
	for k in 10:
		g.draw_rect(Rect2(2 + k, -1 - (k % 3), 1, 1), Color("e85d75"))
	g.draw_rect(Rect2(12, -3, 2, 1), CARAMELO)
	_pegadas(g, 20, 4)


static func _cajuina(g) -> void:
	# Sombra do cajueiro no chão e a garrafinha vazia deitada.
	g.draw_rect(Rect2(-30, -2, 34, 2), Color(0, 0, 0, 0.25))
	_box(g, Rect2(-16, -26, 4, 26), Color("7a4a2a"))
	g.draw_circle(Vector2(-14, -30), 13.0, INK)
	g.draw_circle(Vector2(-14, -30), 12.0, Color("4f7a3a"))
	g.draw_rect(Rect2(-22, -24, 4, 5), Color("e85a3a"))
	_box(g, Rect2(0, -5, 12, 5), Color("e8b040"))
	_box(g, Rect2(12, -4, 4, 3), Color("e8b040"))
	g.draw_rect(Rect2(2, -4, 6, 2), Color.WHITE)
	g.draw_rect(Rect2(-6, -2, 3, 1), CARAMELO)
	_pegadas(g, 22, 4)


static func _castelo(g) -> void:
	var sand = Color("e8c878")
	_box(g, Rect2(-24, -10, 26, 10), sand)
	_box(g, Rect2(-20, -18, 8, 8), sand)
	_box(g, Rect2(-8, -16, 8, 6), sand)
	for k in 3:
		g.draw_rect(Rect2(-20 + k * 3, -20, 2, 2), sand)
	g.draw_rect(Rect2(-17, -23, 3, 3), Color("ffb0c0"))                # conchinha
	# Buraco cavado pelo caramelo e a areia espalhada
	g.draw_rect(Rect2(-6, -6, 7, 6), Color("b89848"))
	g.draw_rect(Rect2(3, -2, 2, 1), sand)
	g.draw_rect(Rect2(6, -3, 1, 1), sand)
	g.draw_rect(Rect2(-4, -8, 2, 1), CARAMELO)
	_pegadas(g, 14, 4)


static func _martelinho(g) -> void:
	# Tábua de madeira com o martelinho (o caramelo só cheirou e foi embora).
	_box(g, Rect2(-26, -4, 24, 4), Color("c9a36b"))
	_box(g, Rect2(-20, -9, 3, 5), Color("8a6a3f"))
	_box(g, Rect2(-24, -12, 11, 3), Color("8a6a3f"))
	# Caranguejinho dando tchau com a pinça
	var wave = 1.0 if int(Time.get_ticks_msec() / 250) % 2 == 0 else 0.0
	_box(g, Rect2(2, -5, 9, 5), Color("e85a3a"))
	g.draw_rect(Rect2(3, -8, 1, 3), INK)
	g.draw_rect(Rect2(8, -8, 1, 3), INK)
	_box(g, Rect2(11, -9 - wave, 3, 3), Color("e85a3a"))
	g.draw_rect(Rect2(-6, -2, 2, 1), CARAMELO)
	_pegadas(g, 22, 4)
