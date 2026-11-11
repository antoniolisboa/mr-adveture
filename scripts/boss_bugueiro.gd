extends "res://scripts/boss_base.gd"
## Boss do Rio Grande do Norte: o Bugueiro "Com Emoção", que leva todo mundo pelas
## dunas sem perguntar se querem.
##
## Ciclo: pergunta "COM OU SEM EMOÇÃO?" -> "emocao" (atravessa a arena a toda,
## 2 ou 3 vezes; quando passa perto do jogador dá um salto: corra por baixo ou saia
## da frente) -> "atolou" (a roda gira na areia e ele fica parado: pise!) ->
## "sem_emocao" (anda devagarinho jogando areia para trás) -> pergunta de novo.

const BOSS_NAME := "BUGUEIRO \"COM EMOÇÃO\""
const ANNOUNCE := "COM EMOÇÃO OU SEM EMOÇÃO?"

const BODY := Color("f07a2a")
const BODY_DARK := Color("b8541a")
const BAR := Color("dfe6ee")
const TIRE := Color("1a1a1a")
const RIM := Color("9aa4b0")
const SKIN := Color("c98a5a")
const CAP := Color("2b5fb4")
const SAND := Color("f2d58a")

var _passes := 0
var _jumped := false
var _dust: Array = []           # [posição, idade]


func _setup() -> void:
	max_hp = 8
	half_w = 22.0
	height = 22.0
	stomp_line = 18.0
	bubble_y = -50.0
	debris_colors = [BODY, BODY_DARK, BAR, TIRE, CAP]


func _on_start() -> void:
	_shout("SEGURA FIRME!")


func _begin() -> void:
	_ask()


func _ask() -> void:
	_state = "pergunta"
	_timer = 1.2
	_shout("COM OU SEM EMOÇÃO?")


func _can_stomp() -> bool:
	return _state == "atolou"


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"pergunta":
			velocity.x = 0.0
			if _timer <= 0.0:
				_state = "emocao"
				_passes = 3 if _angry() else 2
				_face_away_wall()
				_jumped = false
				_shout("COM EMOÇÃO!!")
				Sfx.play("motor")
		"emocao":
			velocity.x = facing * (230.0 if _angry() else 190.0)
			if is_on_floor() and int(_t * 20.0) % 2 == 0:
				_dust.append([position + Vector2(-facing * half_w, -2), 0.0])
			# Salto quando passa perto do jogador.
			var dx := _player_x() - position.x
			if not _jumped and is_on_floor() and dx * facing > 0.0 and absf(dx) < 70.0:
				velocity.y = -330.0
				_jumped = true
				Sfx.play("emocao")
			if _hit_wall():
				_passes -= 1
				facing = -facing
				_jumped = false
				Sfx.play("crash")
				if _passes <= 0:
					_state = "atolou"
					_timer = 1.7 if _angry() else 2.3
					_shout("ATOLOU!")
		"atolou":
			velocity.x = 0.0
			if int(_t * 12.0) % 2 == 0:
				_dust.append([position + Vector2(-facing * (half_w - 4), -3), 0.0])
			if _timer <= 0.0:
				_state = "sem_emocao"
				_timer = 2.6
				_face_player()
				_shout("SEM EMOÇÃO, ENTÃO...")
		"sem_emocao":
			velocity.x = facing * 40.0
			if _hit_wall():
				facing = -facing
			if int(_t * 2.5) != int((_t - delta) * 2.5):
				var back := -facing
				var dx2 := clampf(_player_x() - position.x, -160.0, 160.0)
				_shot("areia", position + Vector2(back * half_w, -8), Vector2(dx2 * 1.1, -220.0), 450.0)
			if _timer <= 0.0:
				_ask()


func _hit_wall() -> bool:
	return (facing < 0 and position.x <= arena_left + half_w + 1.0) or \
			(facing > 0 and position.x >= arena_right - half_w - 1.0)


func _face_away_wall() -> void:
	facing = 1 if position.x < (arena_left + arena_right) / 2.0 else -1


func _tick(delta: float) -> void:
	for d in _dust:
		d[1] += delta
		d[0].y -= 10.0 * delta
	_dust = _dust.filter(func(d): return d[1] < 0.5)


func _on_hurt() -> void:
	_shout(_pick(["EI, CUIDADO COM A LATARIA!", "ESSE AÍ É SEM EMOÇÃO!", "AMASSOU O PARACHOQUE!"]))
	if _state == "atolou":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("FIM DO PASSEIO... COM EMOÇÃO!", 2.0)
	_break_apart()


# --- Desenho -------------------------------------------------------------

func _draw_back() -> void:
	for d in _dust:
		var s: float = 3.0 + d[1] * 10.0
		draw_rect(Rect2(d[0] - position - Vector2(s, s) / 2.0, Vector2(s, s)), Color(SAND, 0.9 - d[1] * 1.6))


func _draw_body() -> void:
	var f := float(facing)
	var shake := 1.0 if _state == "atolou" and int(_t * 20.0) % 2 == 0 else 0.0
	draw_set_transform(Vector2(shake, 0), 0.0, Vector2(f, 1))
	# Rodas (giram: os raios trocam de posição).
	var spin := int(_t * (30.0 if _state in ["emocao", "atolou"] else 8.0)) % 2
	for wx in [-14.0, 14.0]:
		draw_circle(Vector2(wx, -7), 8.0, INK)
		draw_circle(Vector2(wx, -7), 7.0, TIRE)
		draw_circle(Vector2(wx, -7), 3.0, RIM)
		if spin == 0:
			draw_rect(Rect2(wx - 5, -8, 10, 2), RIM)
		else:
			draw_rect(Rect2(wx - 1, -12, 2, 10), RIM)
	# Carroceria laranja, banco e santantônio.
	_part(Rect2(-24, -17, 48, 7), BODY)
	draw_rect(Rect2(-24, -12, 48, 2), BODY_DARK)
	_part(Rect2(14, -21, 10, 4), BODY)                  # capô na frente
	_part(Rect2(-18, -34, 2, 17), BAR)
	_part(Rect2(4, -34, 2, 17), BAR)
	_part(Rect2(-18, -35, 24, 2), BAR)
	# Motorista: boné, óculos escuros e sorrisão.
	_part(Rect2(-8, -29, 9, 9), SKIN)
	_part(Rect2(-9, -32, 11, 3), CAP)
	draw_rect(Rect2(1, -31, 4, 1), CAP)
	draw_rect(Rect2(-4, -26, 6, 2), INK)
	if _state == "atolou":
		draw_rect(Rect2(-3, -22, 4, 1), INK)
	else:
		draw_rect(Rect2(-4, -23, 6, 1), INK)
		draw_rect(Rect2(-4, -22, 1, 1), INK)
	# Braço no volante
	draw_rect(Rect2(0, -22, 8, 2), SKIN)
	draw_rect(Rect2(8, -24, 2, 5), INK)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
