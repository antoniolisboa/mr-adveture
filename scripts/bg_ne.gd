extends RefCounted
## Fundos do Nordeste. Chamado por scripts/background.gd, que passa a si mesmo (bg)
## para desenhar e emprestar os ajudantes (bg._sky, bg._hills, bg._hill_y, bg._rand,
## bg._cam_x, bg._time...).

## Tema -> descrição (o nome do tema vem da constante THEME de cada fase).
const THEMES := {
	"olinda": "ladeiras de Olinda: casario colorido no morro, igrejas e o mar ao fundo",
	"altose": "Alto da Sé no fim da tarde: igreja, barracas de tapioca e o Recife do outro lado",
	"arraial": "noite de São João: estrelas, bandeirinhas, casinhas de taipa e fogueiras",
	"dunas": "dunas douradas de Genipabu, a lagoa, dromedários e o mar",
	"morrocareca": "o Morro do Careca em Ponta Negra: duna enorme, mar e prédios de Natal",
	"jangada": "Praia de Iracema: mar verde, jangadas de vela branca e os prédios de Fortaleza",
	"beiramar": "noite na Beira-Mar: feirinha de artesanato, luzes, jangadas na areia e a lua",
	"lencois": "Lençóis Maranhenses: dunas brancas sem fim e lagoas azuis entre elas",
	"saoluis": "Centro Histórico de São Luís: sobrados de azulejo português e mirantes",
	"boi": "noite de São João no Maranhão: o arraial do Bumba Meu Boi, fitas e matracas",
	"teresina": "Teresina ao meio-dia: céu branco de calor, sol a pino e o ar tremendo",
	"capivara": "Serra da Capivara: paredões de pedra vermelha com pinturas rupestres e caatinga",
	"estaiada": "a ponte estaiada sobre o rio Poti, com o sol rachando",
	"maragogi": "piscinas naturais de Maragogi: mar turquesa, recifes e jangadas indo para as galés",
	"gales": "fim de tarde nas galés: o recife aparecendo na maré baixa e o céu alaranjado",
	"atalaia": "Orla de Atalaia: calçadão, postes, quiosques, coqueiros e o mar de Aracaju",
	"passarela": "a Passarela do Caranguejo no fim do dia: restaurantes iluminados e o mangue",
	"parquedopovo": "o Parque do Povo lotado: palco, luzes, bandeirinhas e o povo dançando",
}

## Temas que mudam sozinhos (fogos, ondas de calor, luzes): redesenha todo quadro.
const ANIMATED := ["altose", "arraial", "parquedopovo", "jangada", "beiramar", "boi", "teresina", "capivara", "estaiada", "maragogi", "gales", "passarela"]

const INK := Color("2b1d2e")
const SEA := Color("2f7fbf")
const SEA_LIGHT := Color("6fb7e6")
const WHITE := Color("f4f1e8")
const TRUNK := Color("8a6a3f")
const LEAF := Color("3c8d2f")
const LEAF_DARK := Color("2f6f3f")
const MID := Color("6fae6a")
const HOUSES := [Color("3f8fd1"), Color("f7d038"), Color("e85d75"), Color("5bbf3a"),
		Color("f07a2a"), Color("b583d6"), Color("f4f1e8"), Color("6fd0c0")]
const ROOF := Color("a8542a")
const WINDOW := Color("2e5e5a")
const DUSK := [Color("3d2a5e"), Color("7a3b6e"), Color("d0607e"), Color("f59a5d"), Color("f7d083")]


static func draw(bg, theme: String, size: Vector2) -> void:
	match theme:
		"olinda":
			_olinda(bg, size)
		"altose":
			_altose(bg, size)
		"dunas":
			_dunas(bg, size)
		"morrocareca":
			_morro_careca(bg, size)
		"jangada":
			_jangada_bg(bg, size)
		"beiramar":
			_beiramar(bg, size)
		"lencois":
			_lencois(bg, size)
		"saoluis":
			_saoluis(bg, size)
		"boi":
			_boi_bg(bg, size)
		"teresina":
			_teresina(bg, size)
		"capivara":
			_capivara(bg, size)
		"estaiada":
			_estaiada(bg, size)
		"maragogi":
			_maragogi(bg, size)
		"gales":
			_gales(bg, size)
		"atalaia":
			_atalaia(bg, size)
		"passarela":
			_passarela(bg, size)
		"arraial":
			_arraial(bg, size)
		"parquedopovo":
			_parque(bg, size)


# --- Ajudantes -------------------------------------------------------------

## Céu em faixas horizontais (do alto para baixo).
static func _bands(bg, size: Vector2, colors: Array, top: float, bottom: float) -> void:
	var h = (bottom - top) / colors.size()
	for i in colors.size():
		bg.draw_rect(Rect2(0, top + i * h, size.x, h + 1), colors[i])


## Prédios finos de longe (Recife, Natal, Fortaleza...).
static func _skyline(bg, size: Vector2, factor: float, base: float, col: Color, lit: Color, salt: int) -> void:
	var off = floorf(bg._cam_x * factor)
	var spacing = 14
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		var w = 8 + bg._rand(i, salt) % 6
		var h = 10 + bg._rand(i, salt + 1) % 34
		bg.draw_rect(Rect2(x, base - h, w, h), col)
		if lit.a > 0.0:
			for wy in range(int(base - h) + 2, int(base) - 1, 4):
				if bg._rand(i * 31 + wy, salt + 2) % 3 == 0:
					bg.draw_rect(Rect2(x + 2, wy, 1, 1), lit)


## Coqueiros: tronco curvado e folhas em leque.
static func _coqueiros(bg, size: Vector2, factor: float, base: float, spacing: int, salt: int) -> void:
	var off = floorf(bg._cam_x * factor)
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		if bg._rand(i, salt) % 3 == 0:
			continue
		var x = i * spacing - off + bg._rand(i, salt + 1) % 20
		var h = 34 + bg._rand(i, salt + 2) % 22
		var lean = 1 if bg._rand(i, salt + 3) % 2 == 0 else -1
		for y in h:
			var bend = lean * (y * y) / float(h * 9)
			bg.draw_rect(Rect2(x + bend, base - y, 3, 1), TRUNK)
		var top = Vector2(x + lean * h / 9.0, base - h)
		for a in [-2.6, -2.0, -1.2, -0.5, 0.1, 0.6]:
			var d = Vector2(cos(a), sin(a) + 0.35)
			for k in 12:
				bg.draw_rect(Rect2(top + d * k + Vector2(0, k * k * 0.04), Vector2(2, 2)), LEAF if k < 8 else LEAF_DARK)
		bg.draw_rect(Rect2(top - Vector2(1, -1), Vector2(4, 3)), Color("7a4a2a"))


## Igrejinha branca barroca de duas torres.
static func _igreja(bg, x: float, base: float, s: float) -> void:
	bg.draw_rect(Rect2(x, base - 16 * s, 26 * s, 16 * s), WHITE)
	bg.draw_rect(Rect2(x - 3 * s, base - 26 * s, 7 * s, 26 * s), WHITE)
	bg.draw_rect(Rect2(x + 22 * s, base - 26 * s, 7 * s, 26 * s), WHITE)
	bg.draw_rect(Rect2(x - 2 * s, base - 29 * s, 5 * s, 3 * s), Color("c9a36b"))
	bg.draw_rect(Rect2(x + 23 * s, base - 29 * s, 5 * s, 3 * s), Color("c9a36b"))
	bg.draw_colored_polygon(PackedVector2Array([Vector2(x + 4 * s, base - 16 * s),
			Vector2(x + 13 * s, base - 22 * s), Vector2(x + 22 * s, base - 16 * s)]), WHITE)
	bg.draw_rect(Rect2(x + 10 * s, base - 8 * s, 6 * s, 8 * s), Color("6b4f2c"))
	bg.draw_rect(Rect2(x - 1 * s, base - 22 * s, 3 * s, 3 * s), WINDOW)
	bg.draw_rect(Rect2(x + 24 * s, base - 22 * s, 3 * s, 3 * s), WINDOW)


## Morro coberto de casinhas coloridas acompanhando a ladeira, com igrejas no alto.
static func _casario_morro(bg, size: Vector2, factor: float, base: float, amp: float, salt: int) -> void:
	var off = floorf(bg._cam_x * factor)
	for x in int(size.x):
		var y: float = bg._hill_y(x + off, base, amp, 0.013, float(salt))
		bg.draw_rect(Rect2(x, y, 1, size.y - y), MID)
	var spacing = 15
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var wx = i * spacing
		var x = wx - off
		var y: float = bg._hill_y(wx + 7, base, amp, 0.013, float(salt)) + 3
		if bg._rand(i, salt) % 11 == 0:
			_igreja(bg, x - 4, y + 2, 0.8)
			continue
		var w = 12 + bg._rand(i, salt + 1) % 4
		var h = 9 + bg._rand(i, salt + 2) % 6
		bg.draw_rect(Rect2(x, y - h, w, h + 30), HOUSES[bg._rand(i, salt + 3) % HOUSES.size()])
		bg.draw_rect(Rect2(x - 1, y - h - 2, w + 2, 2), ROOF)
		bg.draw_rect(Rect2(x + 3, y - h + 3, 2, 3), WINDOW)
		bg.draw_rect(Rect2(x + w - 5, y - h + 3, 2, 3), WINDOW)


# --- Pernambuco ------------------------------------------------------------

static func _olinda(bg, size: Vector2) -> void:
	bg._sky(size)
	bg.draw_rect(Rect2(0, 104, size.x, size.y - 104), SEA)
	bg.draw_rect(Rect2(0, 104, size.x, 2), SEA_LIGHT)
	_skyline(bg, size, 0.04, 104.0, Color("9ab0c8"), Color(0, 0, 0, 0), 40)
	_casario_morro(bg, size, 0.2, 142.0, 40.0, 3)
	_casario_morro(bg, size, 0.4, 170.0, 26.0, 7)
	_coqueiros(bg, size, 0.6, 180.0, 70, 9)


static func _altose(bg, size: Vector2) -> void:
	_bands(bg, size, DUSK, 0.0, 112.0)
	bg.draw_circle(Vector2(250, 96), 14.0, Color("ffe08a"))
	bg.draw_rect(Rect2(0, 104, size.x, size.y - 104), Color("3f5f8f"))
	for i in 6:
		var y = 108 + i * 6
		var x = fposmod(i * 53.0 - bg._cam_x * 0.05 + bg._time * 4.0, size.x)
		bg.draw_rect(Rect2(x, y, 18, 1), Color("f7b07a"))
	_skyline(bg, size, 0.05, 106.0, Color("4a3a5e"), Color("f7d38a"), 41)
	# A Sé de Olinda lá no alto e o morro.
	var off = floorf(bg._cam_x * 0.15)
	for x in int(size.x):
		var y: float = bg._hill_y(x + off, 150.0, 30.0, 0.01, 5.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("4f7a4a"))
	var spacing = 420
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var wx = i * spacing + 160
		_igreja(bg, wx - off, bg._hill_y(wx + 12, 150.0, 30.0, 0.01, 5.0) + 3, 1.3)
	# Barracas de tapioca com luzinhas.
	off = floorf(bg._cam_x * 0.45)
	spacing = 90
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		bg.draw_rect(Rect2(x, 150, 34, 30), Color("c9a36b"))
		bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 4, 150), Vector2(x + 17, 138),
				Vector2(x + 38, 150)]), WHITE)
		bg.draw_rect(Rect2(x + 3, 154, 28, 6), Color("f6eedb"))
		for k in 5:
			var on = int(bg._time * 3.0 + k + i) % 2 == 0
			bg.draw_rect(Rect2(x + 2 + k * 7, 147, 2, 2), Color("f7d038") if on else Color("e85d75"))


# --- Paraíba ---------------------------------------------------------------

const NIGHT := [Color("0f0b2a"), Color("1a1440"), Color("261c55"), Color("33246a")]
const FLAGS := [Color("d64545"), Color("f7d038"), Color("2a9d4a"), Color("3f8fd1"), Color("e85d75"), Color("ffffff")]


static func _stars(bg, size: Vector2, n: int) -> void:
	for i in n:
		var x = fposmod(bg._rand(i, 50) * 0.37 - bg._cam_x * 0.02, size.x)
		var y = bg._rand(i, 51) % 90
		var tw = int(bg._time * 2.0 + i) % 5 == 0
		bg.draw_rect(Rect2(x, y, 1, 1), Color("fff3c8") if not tw else Color("8a7ab0"))
	bg.draw_circle(Vector2(60, 30), 9.0, Color("fff3c8"))
	bg.draw_circle(Vector2(64, 27), 8.0, NIGHT[0])


## Cordões de bandeirinhas em curva, de poste em poste.
static func _bandeirinhas(bg, size: Vector2, factor: float, top: float, spacing: int) -> void:
	var off = floorf(bg._cam_x * factor)
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x0 = i * spacing - off
		bg.draw_rect(Rect2(x0, top - 2, 2, 120), Color("5a3a22"))
		for k in range(0, spacing, 6):
			var sag = sin(PI * k / spacing) * 14.0
			var x = x0 + k
			var y = top + sag
			bg.draw_rect(Rect2(x, y, 6, 1), Color("2b1d2e"))
			var c = FLAGS[(i * 7 + k / 6) % FLAGS.size()]
			var flutter = 1.0 if int(bg._time * 4.0 + k) % 2 == 0 else 0.0
			bg.draw_colored_polygon(PackedVector2Array([Vector2(x + 1, y + 1), Vector2(x + 5, y + 1),
					Vector2(x + 3 + flutter, y + 6)]), c)


static func _fogueira(bg, x: float, base: float) -> void:
	for k in 3:
		bg.draw_rect(Rect2(x - 8 + k * 3, base - 4 + (k % 2) * 2, 14, 3), Color("7a4a2a"))
	var f = 1.0 + 0.25 * sin(bg._time * 13.0 + x)
	bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 7, base - 4), Vector2(x, base - 4 - 16 * f),
			Vector2(x + 7, base - 4)]), Color("f07a2a"))
	bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 4, base - 4), Vector2(x + 1, base - 4 - 10 * f),
			Vector2(x + 4, base - 4)]), Color("f7d038"))


static func _arraial(bg, size: Vector2) -> void:
	_bands(bg, size, NIGHT, 0.0, size.y)
	_stars(bg, size, 50)
	# Serra ao longe e casinhas de taipa com janelinhas acesas.
	var off = floorf(bg._cam_x * 0.15)
	for x in int(size.x):
		var y = bg._hill_y(x + off, 130.0, 24.0, 0.012, 8.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("1d2a3a"))
	off = floorf(bg._cam_x * 0.35)
	var spacing = 64
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		bg.draw_rect(Rect2(x, 136, 30, 40), Color("8a5a3a"))
		bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 3, 137), Vector2(x + 15, 124), Vector2(x + 33, 137)]), Color("5a3a22"))
		bg.draw_rect(Rect2(x + 5, 144, 6, 6), Color("f7d38a"))
		bg.draw_rect(Rect2(x + 19, 146, 6, 14), Color("3b2416"))
		if bg._rand(i, 52) % 2 == 0:
			_fogueira(bg, x + 46, 176.0)
	_bandeirinhas(bg, size, 0.6, 40.0, 96)


static func _parque(bg, size: Vector2) -> void:
	_bands(bg, size, NIGHT, 0.0, size.y)
	_stars(bg, size, 30)
	# Palco grande com luzes coloridas piscando.
	var off = floorf(bg._cam_x * 0.12)
	var spacing = 380
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x = i * spacing - off + 120
		bg.draw_rect(Rect2(x, 90, 140, 60), Color("2b1d4e"))
		bg.draw_rect(Rect2(x - 6, 82, 152, 8), Color("4a3a6e"))
		for k in 8:
			var c = FLAGS[(k + int(bg._time * 5.0)) % FLAGS.size()]
			bg.draw_rect(Rect2(x + 4 + k * 18, 86, 4, 3), c)
			var beam = PackedVector2Array([Vector2(x + 6 + k * 18, 90), Vector2(x - 10 + k * 18 + sin(bg._time * 2.0 + k) * 20.0, 150),
					Vector2(x + 20 + k * 18 + sin(bg._time * 2.0 + k) * 20.0, 150)])
			bg.draw_colored_polygon(beam, Color(c, 0.12))
	_bandeirinhas(bg, size, 0.3, 30.0, 120)
	# O povo dançando forró (silhuetas que balançam).
	off = floorf(bg._cam_x * 0.5)
	for i in range(int(off / 9.0) - 1, int(off / 9.0) + 40):
		var x = i * 9 - off
		var bob = 2.0 if int(bg._time * 4.0 + i * 0.5) % 2 == 0 else 0.0
		var h = 18 + bg._rand(i, 53) % 8
		bg.draw_rect(Rect2(x, 180 - h - bob, 6, h + bob), Color("150f26"))
		bg.draw_rect(Rect2(x + 1, 175 - h - bob, 4, 4), Color("150f26"))
		if bg._rand(i, 54) % 3 == 0:
			bg.draw_rect(Rect2(x - 1, 173 - h - bob, 8, 2), Color("3a2a10"))   # chapéu de palha


# --- Rio Grande do Norte ---------------------------------------------------

const DUNE := Color("f2d58a")
const DUNE_SHADE := Color("d9b866")
const DUNE_FAR := Color("e8cfa0")
const LAGOON := Color("3fa8d0")


## Fileira de dunas com o lado da sombra.
static func _dune_row(bg, size: Vector2, factor: float, base: float, amp: float, freq: float,
		seed: float, col: Color, shade: Color) -> void:
	var off = floorf(bg._cam_x * factor)
	for x in int(size.x):
		var y = bg._hill_y(x + off, base, amp, freq, seed)
		var y2 = bg._hill_y(x + off + 1, base, amp, freq, seed)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), shade if y2 > y else col)


static func _dromedarios(bg, size: Vector2, factor: float, base: float) -> void:
	var off = floorf(bg._cam_x * factor)
	var spacing = 260
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x = i * spacing - off + 90
		var c = Color("a8742a")
		bg.draw_rect(Rect2(x, base - 10, 14, 5), c)              # corpo
		bg.draw_rect(Rect2(x + 3, base - 13, 5, 3), c)           # corcova
		bg.draw_rect(Rect2(x + 13, base - 15, 2, 7), c)          # pescoço
		bg.draw_rect(Rect2(x + 13, base - 16, 5, 2), c)          # cabeça
		for lx in [1, 4, 9, 12]:
			bg.draw_rect(Rect2(x + lx, base - 5, 1, 5), c)


static func _dunas(bg, size: Vector2) -> void:
	bg._sky(size)
	bg.draw_rect(Rect2(0, 110, size.x, size.y - 110), SEA)
	bg.draw_rect(Rect2(0, 110, size.x, 2), SEA_LIGHT)
	_dune_row(bg, size, 0.12, 128.0, 30.0, 0.012, 1.0, DUNE_FAR, DUNE_SHADE)
	# Lagoa de Genipabu entre as dunas.
	var off = floorf(bg._cam_x * 0.25)
	var spacing = 340
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x = i * spacing - off + 60
		bg.draw_rect(Rect2(x, 140, 120, 8), LAGOON)
		bg.draw_rect(Rect2(x + 6, 140, 108, 1), SEA_LIGHT)
	_dromedarios(bg, size, 0.25, 142.0)
	_dune_row(bg, size, 0.4, 172.0, 22.0, 0.02, 3.0, Color("f6e6bc"), Color("e6cf98"))
	_coqueiros(bg, size, 0.6, 186.0, 110, 60)


static func _morro_careca(bg, size: Vector2) -> void:
	_bands(bg, size, [Color("7fc8f0"), Color("9fd8f5"), Color("c0e6f8")], 0.0, 112.0)
	bg.draw_rect(Rect2(0, 112, size.x, size.y - 112), SEA)
	for i in 8:
		var x = fposmod(i * 47.0 - bg._cam_x * 0.1 + bg._time * 10.0, size.x)
		bg.draw_rect(Rect2(x, 118 + i * 5, 14, 1), SEA_LIGHT)
	_skyline(bg, size, 0.05, 112.0, Color("c8d0d8"), Color(0, 0, 0, 0), 61)
	# O morrão de areia com a mata dos lados.
	var off = floorf(bg._cam_x * 0.1)
	var spacing = 520
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var cx = i * spacing - off + 200
		for x in range(int(cx) - 90, int(cx) + 90):
			var d = absf(x - cx) / 90.0
			var top = 150.0 - 70.0 * (1.0 - d * d)
			bg.draw_rect(Rect2(x, top, 1, 180 - top), Color("f6e6bc") if d < 0.45 else Color("4f8f4f"))
	_dune_row(bg, size, 0.4, 176.0, 14.0, 0.02, 5.0, Color("f6e6bc"), Color("e6cf98"))
	_coqueiros(bg, size, 0.6, 186.0, 90, 62)


# --- Ceará -----------------------------------------------------------------

const SEA_GREEN := Color("2fa8a0")
const SEA_GREEN_LIGHT := Color("7fe0d0")


## Jangada: tronco de madeira, mastro e a vela triangular branca (balança na onda).
static func _jangada(bg, x: float, base: float, s: float, t: float) -> void:
	var bob = sin(t * 2.0 + x * 0.1) * 1.0
	bg.draw_rect(Rect2(x - 8 * s, base + bob, 18 * s, 3 * s), Color("8a6a3f"))
	bg.draw_rect(Rect2(x, base - 22 * s + bob, 1 * s, 22 * s), Color("5a3a22"))
	bg.draw_colored_polygon(PackedVector2Array([Vector2(x + 1 * s, base - 21 * s + bob),
			Vector2(x + 1 * s, base - 2 * s + bob), Vector2(x + 13 * s, base - 3 * s + bob)]), WHITE)


static func _mar_com_jangadas(bg, size: Vector2, top: float, col: Color, light: Color) -> void:
	bg.draw_rect(Rect2(0, top, size.x, size.y - top), col)
	for i in 8:
		var x = fposmod(i * 47.0 - bg._cam_x * 0.12 + bg._time * 8.0, size.x)
		bg.draw_rect(Rect2(x, top + 6 + i * 5, 14, 1), light)
	var off = floorf(bg._cam_x * 0.15)
	var spacing = 150
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off + bg._rand(i, 70) % 60
		_jangada(bg, x, top + 8 + bg._rand(i, 71) % 14, 0.8 + (bg._rand(i, 72) % 3) * 0.15, bg._time)


static func _jangada_bg(bg, size: Vector2) -> void:
	bg._sky(size)
	_skyline(bg, size, 0.04, 104.0, Color("d8dee6"), Color(0, 0, 0, 0), 73)
	_mar_com_jangadas(bg, size, 104.0, SEA_GREEN, SEA_GREEN_LIGHT)
	_dune_row(bg, size, 0.45, 180.0, 10.0, 0.02, 9.0, Color("f6e6bc"), Color("e6cf98"))
	_coqueiros(bg, size, 0.6, 186.0, 100, 74)


static func _beiramar(bg, size: Vector2) -> void:
	_bands(bg, size, [Color("10183a"), Color("1a2650"), Color("243466"), Color("2f4478")], 0.0, 110.0)
	_stars(bg, size, 25)
	_skyline(bg, size, 0.05, 104.0, Color("1f2a4a"), Color("f7d38a"), 75)
	_mar_com_jangadas(bg, size, 104.0, Color("1a3a5a"), Color("4a7aa0"))
	bg.draw_rect(Rect2(0, 136, size.x, size.y - 136), Color("c9b080"))
	# Barracas da feirinha com lâmpadas e redes penduradas.
	var off = floorf(bg._cam_x * 0.5)
	var spacing = 64
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		var c = HOUSES[bg._rand(i, 76) % HOUSES.size()]
		bg.draw_rect(Rect2(x, 140, 44, 40), Color("f4f1e8"))
		bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 4, 141), Vector2(x + 22, 128), Vector2(x + 48, 141)]), c)
		for k in 3:
			var hy = 150 + k * 7
			bg.draw_rect(Rect2(x + 4, hy, 36, 2), HOUSES[(i + k) % HOUSES.size()])   # redes dobradas
		var on = int(bg._time * 2.0 + i) % 2 == 0
		bg.draw_rect(Rect2(x + 20, 136, 3, 3), Color("f7d038") if on else Color("f7b07a"))


# --- Maranhão --------------------------------------------------------------

const WHITE_DUNE := Color("f4efe0")
const WHITE_DUNE_SHADE := Color("e0d6bc")
const AZULEJO := Color("2b5fb4")
const AZULEJO_LIGHT := Color("dfe9f5")


static func _lencois(bg, size: Vector2) -> void:
	_bands(bg, size, [Color("5ab8f0"), Color("7fc8f5"), Color("a8dcf8")], 0.0, 120.0)
	_dune_row(bg, size, 0.1, 132.0, 26.0, 0.016, 2.0, Color("eef2f6"), Color("d8e0ea"))
	# Lagoas azuis entre as dunas do meio.
	var off = floorf(bg._cam_x * 0.25)
	var spacing = 180
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off + bg._rand(i, 80) % 40
		var w = 50 + bg._rand(i, 81) % 50
		bg.draw_rect(Rect2(x, 146, w, 10), Color("3fa8d0"))
		bg.draw_rect(Rect2(x + 4, 146, w - 8, 2), Color("8fd8f0"))
	_dune_row(bg, size, 0.4, 168.0, 20.0, 0.022, 6.0, Color("dfe6ee"), Color("c8d2de"))


## Sobrado colonial com fachada de azulejo azul e branco.
static func _sobrado(bg, x: float, base: float, w: float, h: float, tint: int) -> void:
	bg.draw_rect(Rect2(x, base - h, w, h + 40), AZULEJO_LIGHT if tint % 3 != 0 else Color("f2d16b"))
	for ty in range(int(base - h) + 2, int(base), 4):
		for tx in range(int(x) + 1, int(x + w) - 1, 4):
			if (tx / 4 + ty / 4) % 2 == 0:
				bg.draw_rect(Rect2(tx, ty, 2, 2), AZULEJO)
	bg.draw_rect(Rect2(x - 2, base - h - 3, w + 4, 3), ROOF)
	for k in range(int(x) + 4, int(x + w) - 6, 11):
		bg.draw_rect(Rect2(k - 1, base - h + 5, 8, 12), WHITE)
		bg.draw_rect(Rect2(k, base - h + 6, 6, 11), Color("2a6a4a"))       # janela de madeira verde
		bg.draw_rect(Rect2(k - 1, base - h + 17, 8, 1), INK)                # sacadinha de ferro
	bg.draw_rect(Rect2(x + w / 2 - 4, base - 12, 8, 52), Color("6b4f2c"))


static func _saoluis(bg, size: Vector2) -> void:
	bg._sky(size)
	bg.draw_rect(Rect2(0, 112, size.x, size.y - 112), Color("4f8fb0"))   # baía de São Marcos
	var off = floorf(bg._cam_x * 0.2)
	var spacing = 46
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		_sobrado(bg, x, 130.0 - bg._rand(i, 82) % 8, 40, 30 + bg._rand(i, 83) % 14, i + 1)
	off = floorf(bg._cam_x * 0.45)
	spacing = 58
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		_sobrado(bg, x, 170.0, 52, 40 + bg._rand(i, 84) % 16, i)


static func _boi_bg(bg, size: Vector2) -> void:
	_bands(bg, size, NIGHT, 0.0, size.y)
	_stars(bg, size, 40)
	var off = floorf(bg._cam_x * 0.15)
	var spacing = 46
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		bg.draw_rect(Rect2(x, 112 - bg._rand(i, 85) % 10, 40, 80), Color("1f2448"))
		bg.draw_rect(Rect2(x + 6, 122, 6, 8), Color("f7d38a"))
		bg.draw_rect(Rect2(x + 26, 122, 6, 8), Color("f7d38a"))
	_bandeirinhas(bg, size, 0.35, 36.0, 100)
	# Brincantes com chapéus de fita girando (silhuetas com fitas coloridas).
	off = floorf(bg._cam_x * 0.5)
	for i in range(int(off / 24.0) - 1, int(off / 24.0) + 16):
		var x = i * 24 - off
		var bob = 2.0 if int(bg._time * 3.0 + i) % 2 == 0 else 0.0
		bg.draw_rect(Rect2(x, 150 - bob, 8, 30), Color("150f26"))
		bg.draw_rect(Rect2(x - 4, 146 - bob, 16, 3), Color("150f26"))
		for k in 5:
			var sway = sin(bg._time * 4.0 + i + k) * 2.0
			bg.draw_rect(Rect2(x - 3 + k * 3 + sway, 149 - bob, 1, 10), FLAGS[(i + k) % FLAGS.size()])
	for i in range(int(off / 160.0) - 1, int(off / 160.0) + 3):
		_fogueira(bg, i * 160 - off + 80, 180.0)


# --- Piauí -----------------------------------------------------------------

const HOT_SKY := [Color("fff3c8"), Color("ffe8a0"), Color("ffd890"), Color("f8c880")]
const CAATINGA := Color("8a8a5a")
const RED_ROCK := Color("b5543a")
const RED_ROCK_DARK := Color("7a3424")


## Ar tremendo de calor: faixas finas que ondulam.
static func _mormaco(bg, size: Vector2, top: float) -> void:
	for i in 14:
		var y = top + i * 5.0
		var x = fposmod(i * 61.0 + sin(bg._time * 3.0 + i) * 10.0 - bg._cam_x * 0.3, size.x + 60.0) - 30.0
		bg.draw_rect(Rect2(x, y, 24, 1), Color(1, 1, 1, 0.25))


static func _sol_a_pino(bg, size: Vector2) -> void:
	var r = 16.0 + sin(bg._time * 2.0) * 1.0
	bg.draw_circle(Vector2(size.x * 0.75, 22), r + 6.0, Color(1, 0.95, 0.6, 0.5))
	bg.draw_circle(Vector2(size.x * 0.75, 22), r, Color("fffbe8"))


static func _teresina(bg, size: Vector2) -> void:
	_bands(bg, size, HOT_SKY, 0.0, size.y)
	_sol_a_pino(bg, size)
	_skyline(bg, size, 0.06, 128.0, Color("d8c8a8"), Color(0, 0, 0, 0), 90)
	# Cajueiros e oitizeiros dando a sombra que falta.
	var off = floorf(bg._cam_x * 0.3)
	for x in int(size.x):
		var y = bg._hill_y(x + off, 150.0, 10.0, 0.02, 3.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("c8b078"))
	var spacing = 70
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off + bg._rand(i, 91) % 30
		bg.draw_rect(Rect2(x - 1, 134, 3, 20), Color("7a4a2a"))
		bg.draw_circle(Vector2(x, 132), 10.0, Color("4f7a3a"))
		bg.draw_circle(Vector2(x + 4, 128), 6.0, Color("6f9a4f"))
	bg._city(size, 0.45, 176.0, Color("e8d8b8"), Color("8a7a5a"), 92)
	_mormaco(bg, size, 100.0)


static func _capivara(bg, size: Vector2) -> void:
	_bands(bg, size, HOT_SKY, 0.0, size.y)
	_sol_a_pino(bg, size)
	# Paredões de pedra vermelha com as pinturas rupestres (bonequinhos de palito).
	var off = floorf(bg._cam_x * 0.2)
	var spacing = 130
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		var h = 70 + bg._rand(i, 93) % 30
		bg.draw_rect(Rect2(x, 170 - h, 110, h + 10), RED_ROCK)
		bg.draw_rect(Rect2(x, 170 - h, 110, 4), RED_ROCK_DARK)
		for k in range(int(170 - h) + 14, 168, 14):
			bg.draw_rect(Rect2(x, k, 110, 1), RED_ROCK_DARK)
		for f in 3:
			var fx = x + 20 + f * 26
			var fy = 170 - h + 26 + (f % 2) * 8
			var c = Color("f4f1e8") if f != 1 else Color("5a1a10")
			bg.draw_rect(Rect2(fx, fy, 1, 6), c)            # corpo
			bg.draw_rect(Rect2(fx - 1, fy - 2, 3, 2), c)     # cabeça
			bg.draw_rect(Rect2(fx - 3, fy + 2, 7, 1), c)     # braços
			bg.draw_rect(Rect2(fx - 2, fy + 6, 1, 3), c)     # pernas
			bg.draw_rect(Rect2(fx + 2, fy + 6, 1, 3), c)
		if bg._rand(i, 94) % 2 == 0:                        # uma capivara pintada
			bg.draw_rect(Rect2(x + 76, 170 - h + 40, 10, 4), Color("5a1a10"))
			bg.draw_rect(Rect2(x + 85, 170 - h + 38, 4, 3), Color("5a1a10"))
			bg.draw_rect(Rect2(x + 77, 170 - h + 44, 1, 3), Color("5a1a10"))
			bg.draw_rect(Rect2(x + 84, 170 - h + 44, 1, 3), Color("5a1a10"))
	# Caatinga: arbustos secos e mandacarus.
	off = floorf(bg._cam_x * 0.5)
	spacing = 40
	first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		if bg._rand(i, 95) % 3 == 0:
			bg.draw_rect(Rect2(x, 150, 4, 30), Color("4f7a3a"))
			bg.draw_rect(Rect2(x - 5, 158, 5, 3), Color("4f7a3a"))
			bg.draw_rect(Rect2(x - 5, 152, 3, 7), Color("4f7a3a"))
			bg.draw_rect(Rect2(x + 4, 162, 5, 3), Color("4f7a3a"))
			bg.draw_rect(Rect2(x + 7, 156, 3, 7), Color("4f7a3a"))
		else:
			bg.draw_circle(Vector2(x, 172), 7.0, CAATINGA)
	_mormaco(bg, size, 110.0)


static func _estaiada(bg, size: Vector2) -> void:
	_bands(bg, size, HOT_SKY, 0.0, size.y)
	_sol_a_pino(bg, size)
	bg.draw_rect(Rect2(0, 128, size.x, size.y - 128), Color("7a8a5a"))   # rio Poti
	for i in 6:
		var x = fposmod(i * 57.0 - bg._cam_x * 0.1 + bg._time * 6.0, size.x)
		bg.draw_rect(Rect2(x, 134 + i * 6, 16, 1), Color("a8b888"))
	_skyline(bg, size, 0.05, 128.0, Color("d8c8a8"), Color(0, 0, 0, 0), 96)
	# A ponte: torre alta com os cabos em leque.
	var off = floorf(bg._cam_x * 0.15)
	var spacing = 480
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + 3):
		var x = i * spacing - off + 200
		bg.draw_rect(Rect2(x - 3, 30, 6, 106), Color("e8e2d0"))
		bg.draw_rect(Rect2(x - 5, 26, 10, 6), Color("e8e2d0"))
		for k in 7:
			bg.draw_line(Vector2(x, 36 + k * 4), Vector2(x - 30 - k * 18, 120), Color("c9ccd2"), 1.0)
			bg.draw_line(Vector2(x, 36 + k * 4), Vector2(x + 30 + k * 18, 120), Color("c9ccd2"), 1.0)
		bg.draw_rect(Rect2(x - 170, 120, 340, 5), Color("c9ccd2"))
	_mormaco(bg, size, 96.0)


# --- Alagoas ---------------------------------------------------------------

const TURQ := Color("3fc8c0")
const TURQ_LIGHT := Color("8fe8e0")
const TURQ_DEEP := Color("1f8fa8")


static func _recifes(bg, size: Vector2, factor: float, y: float, col: Color) -> void:
	var off = floorf(bg._cam_x * factor)
	var spacing = 60
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off + bg._rand(i, 100) % 20
		var w = 20 + bg._rand(i, 101) % 30
		bg.draw_rect(Rect2(x, y, w, 3), col)
		bg.draw_rect(Rect2(x + 3, y - 1, w - 6, 1), col)


static func _maragogi(bg, size: Vector2) -> void:
	bg._sky(size)
	bg.draw_rect(Rect2(0, 100, size.x, 12), TURQ_DEEP)
	bg.draw_rect(Rect2(0, 112, size.x, size.y - 112), TURQ)
	for i in 10:
		var x = fposmod(i * 41.0 - bg._cam_x * 0.12 + bg._time * 6.0, size.x)
		bg.draw_rect(Rect2(x, 114 + i * 5, 12, 1), TURQ_LIGHT)
	_recifes(bg, size, 0.15, 118.0, Color("c9a080"))
	var off = floorf(bg._cam_x * 0.12)
	var spacing = 170
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		_jangada(bg, i * spacing - off + bg._rand(i, 102) % 50, 110.0, 0.9, bg._time)
	_recifes(bg, size, 0.35, 150.0, Color("b08870"))
	_coqueiros(bg, size, 0.55, 186.0, 120, 103)


static func _gales(bg, size: Vector2) -> void:
	_bands(bg, size, DUSK, 0.0, 108.0)
	bg.draw_circle(Vector2(240, 100), 16.0, Color("ffe08a"))
	bg.draw_rect(Rect2(0, 104, size.x, size.y - 104), Color("2f8fa0"))
	for i in 10:
		var x = fposmod(i * 41.0 - bg._cam_x * 0.12 + bg._time * 5.0, size.x)
		bg.draw_rect(Rect2(x, 108 + i * 6, 14, 1), Color("f7b07a"))
	_recifes(bg, size, 0.2, 124.0, Color("8a6050"))
	_recifes(bg, size, 0.4, 150.0, Color("6a4838"))
	_coqueiros(bg, size, 0.6, 186.0, 110, 104)


# --- Sergipe ---------------------------------------------------------------

static func _postes(bg, size: Vector2, factor: float, base: float, spacing: int, lit: bool) -> void:
	var off = floorf(bg._cam_x * factor)
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		bg.draw_rect(Rect2(x, base - 40, 2, 40), Color("3a3a4a"))
		bg.draw_rect(Rect2(x - 4, base - 42, 10, 3), Color("3a3a4a"))
		bg.draw_rect(Rect2(x - 3, base - 39, 8, 2), Color("f7d38a") if lit else Color("e8e2d0"))


static func _atalaia(bg, size: Vector2) -> void:
	bg._sky(size)
	bg.draw_rect(Rect2(0, 108, size.x, size.y - 108), SEA)
	bg.draw_rect(Rect2(0, 108, size.x, 2), SEA_LIGHT)
	bg.draw_rect(Rect2(0, 140, size.x, size.y - 140), Color("f2d58a"))
	var off = floorf(bg._cam_x * 0.35)
	var spacing = 110
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		bg.draw_rect(Rect2(x, 146, 30, 24), Color("f4f1e8"))
		bg.draw_colored_polygon(PackedVector2Array([Vector2(x - 4, 147), Vector2(x + 15, 136), Vector2(x + 34, 147)]),
				HOUSES[bg._rand(i, 110) % HOUSES.size()])
	_coqueiros(bg, size, 0.5, 186.0, 80, 111)
	_postes(bg, size, 0.6, 186.0, 90, false)


static func _passarela(bg, size: Vector2) -> void:
	_bands(bg, size, DUSK, 0.0, 120.0)
	bg.draw_circle(Vector2(60, 108), 14.0, Color("ffe08a"))
	# Mangue ao longe (raízes e copas escuras)
	var off = floorf(bg._cam_x * 0.12)
	for x in int(size.x):
		var y = bg._hill_y(x + off, 128.0, 12.0, 0.03, 4.0)
		bg.draw_rect(Rect2(x, y, 1, size.y - y), Color("2f4f3a"))
	bg.draw_rect(Rect2(0, 132, size.x, size.y - 132), Color("4a5a4a"))
	# Restaurantes com placa de caranguejo e luzinhas
	off = floorf(bg._cam_x * 0.4)
	var spacing = 84
	var first = int(floor(off / spacing)) - 1
	for i in range(first, first + int(size.x / spacing) + 3):
		var x = i * spacing - off
		var c = HOUSES[bg._rand(i, 112) % HOUSES.size()]
		bg.draw_rect(Rect2(x, 128, 64, 52), c)
		bg.draw_rect(Rect2(x - 2, 124, 68, 4), ROOF)
		bg.draw_rect(Rect2(x + 6, 138, 52, 18), Color("f7d38a"))
		bg.draw_rect(Rect2(x + 22, 112, 20, 12), Color("2b1d2e"))
		bg.draw_rect(Rect2(x + 26, 116, 12, 5), Color("e85a3a"))            # caranguejinho na placa
		bg.draw_rect(Rect2(x + 23, 114, 3, 3), Color("e85a3a"))
		bg.draw_rect(Rect2(x + 38, 114, 3, 3), Color("e85a3a"))
		for k in 6:
			var on = int(bg._time * 3.0 + k + i) % 2 == 0
			bg.draw_rect(Rect2(x + 2 + k * 11, 126, 2, 2), Color("f7d038") if on else Color("e85d75"))
	_postes(bg, size, 0.6, 186.0, 96, true)
