extends "res://scripts/boss_base.gd"
## Boss do Ceará: O Rei da Resenha, o maior contador de piada da Beira-Mar.
##
## Ciclo: "piadas" (manda balões de piada, uns baixos e uns altos; quem leva fica rindo
## parado) -> "ri" (ri da própria piada, dobrado de tanto rir: hora de pisar ou
## responder com outra piada) -> "abraco" ("MEU AMIGO!": vem correndo dar um abraço
## apertado; encostar machuca) -> "piadas" de novo. Bravo, conta piada mais rápido.

const BOSS_NAME := "O REI DA RESENHA"
const ANNOUNCE := "CHEGOU O REI DA RESENHA, MACHO!"

const SHIRT := Color("2a9d4a")
const FLOWER := Color("f7d038")
const SKIN := Color("c98a5a")
const CROWN := Color("f2c94c")
const SHORTS := Color("2b5fb4")
const JOKES := ["É PAVÊ OU PRA COMER?", "SABE O QUE O PATO DISSE?", "ÉGUA, MACHO!", "ARREDA!",
		"VAI DAR CERTO NÃO!", "OXE, QUE FOI?", "TÁ COM FOME? COME!"]

var _jokes_left := 0
var _next_joke := 0.0


func _setup() -> void:
	max_hp = 8
	half_w = 11.0
	height = 34.0
	stomp_line = 30.0
	bubble_y = -56.0
	debris_colors = [SHIRT, FLOWER, CROWN, SHORTS]


func _on_start() -> void:
	_shout("ESCUTA ESSA, MACHO!")


func _begin() -> void:
	_start_piadas()


func _start_piadas() -> void:
	_state = "piadas"
	_jokes_left = 6 if _angry() else 4
	_next_joke = 0.3
	_face_player()


func _can_stomp() -> bool:
	return _state == "ri"


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"piadas":
			velocity.x = 0.0
			_face_player()
			_next_joke -= delta
			if _next_joke <= 0.0:
				_next_joke = 0.45 if _angry() else 0.65
				_jokes_left -= 1
				var high := _jokes_left % 2 == 0
				var s := _shot("", position + Vector2(facing * 14, -24 if high else -7),
						Vector2(facing * 110.0, 0.0), 0.0, _pick(JOKES))
				s.joke = true
				Sfx.play("piada")
				if _jokes_left <= 0:
					_state = "ri"
					_timer = 1.6 if _angry() else 2.2
					Sfx.play("badumtss")
					_shout("KKKKKKKKK", 1.0)
		"ri":
			velocity.x = 0.0
			if _timer <= 0.0:
				_state = "abraco"
				_timer = 2.0
				_face_player()
				_shout("MEU AMIGO!")
		"abraco":
			_face_player()
			velocity.x = facing * (110.0 if _angry() else 85.0)
			if _timer <= 0.0:
				_start_piadas()


func _on_hurt() -> void:
	_shout(_pick(["ESSA DOEU, MACHO!", "AI, SEM GRAÇA!", "TÁ ME ESCULHAMBANDO?"]))
	if _state == "ri":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("TÁ BOM, TÁ BOM... VOCÊ É MAIS ENGRAÇADO!", 2.2)
	_break_apart()


func _draw_body() -> void:
	var f := float(facing)
	var bend := 0.0
	if _state == "ri":
		bend = 6.0 + (1.0 if int(_t * 12.0) % 2 == 0 else 0.0)
	var o := Vector2(0, bend)
	# Pernas e bermuda
	_part(Rect2(-8, -6, 5, 6), SKIN)
	_part(Rect2(3, -6, 5, 6), SKIN)
	_part(Rect2(-10, -14, 20, 8), SHORTS)
	# Camisa florida (barrigão)
	_part(Rect2(Vector2(-11, -30) + o * 0.5, Vector2(22, 17)), SHIRT)
	for p in [Vector2(-7, -27), Vector2(3, -25), Vector2(-3, -19), Vector2(5, -18)]:
		draw_rect(Rect2(p + o * 0.5, Vector2(2, 2)), FLOWER)
	# Braço com o microfone
	_part(Rect2(Vector2(f * 10 - 2, -26) + o * 0.5, Vector2(5, 5)), SKIN)
	_part(Rect2(Vector2(f * 14 - 1, -31) + o * 0.5, Vector2(3, 6)), INK)
	draw_rect(Rect2(Vector2(f * 14 - 2, -34) + o * 0.5, Vector2(5, 4)), Color("9aa4b0"))
	# Cabeça, óculos escuros, bigode e a coroa de rei
	var h := Vector2(0, -38) + o
	_part(Rect2(h + Vector2(-7, -7), Vector2(14, 13)), SKIN)
	draw_rect(Rect2(h + Vector2(-6, -3), Vector2(12, 3)), INK)
	draw_rect(Rect2(h + Vector2(-4, 2), Vector2(8, 2)), Color("3b2416"))
	if _state == "ri":
		draw_rect(Rect2(h + Vector2(-3, 4), Vector2(6, 2)), Color("a02828"))
	_part(Rect2(h + Vector2(-7, -11), Vector2(14, 3)), CROWN)
	for k in 3:
		draw_rect(Rect2(h + Vector2(-7 + k * 6, -14), Vector2(2, 3)), CROWN)
	draw_rect(Rect2(h + Vector2(-1, -10), Vector2(2, 1)), Color("d64545"))
