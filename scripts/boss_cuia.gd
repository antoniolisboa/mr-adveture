extends "res://scripts/boss_base.gd"
## Boss do Rio Grande do Sul: a Cuia Gigante de Chimarrão, de bigode e lenço no
## pescoço, que não admite que ninguém mexa na bomba dela. "BAH, TCHÊ!"
##
## Ciclo: "pula" (três pulos atrás do jogador; cada pouso espalha erva-mate para os
## lados) -> "chimarrao" (a bomba esguicha água quente que cai em arco pela arena) ->
## "rola" (tomba e sai rolando de parede a parede: pule por cima) -> "entupiu" (a
## bomba entupiu e ela fica sacudindo, de boca para cima: hora de pisar).

const BOSS_NAME := "A CUIA GIGANTE"
const ANNOUNCE := "BAH, TCHÊ! QUEM MEXEU NA MINHA BOMBA?"

const GOURD := Color("b07a3a")
const GOURD_DARK := Color("7a5228")
const GOURD_LIGHT := Color("d8a868")
const SILVER := Color("cfd6de")
const MATE := Color("3c8d2f")
const SCARF := Color("d64545")

var _hops := 0
var _drops := 0
var _bounces := 0
var _roll := 0.0                # ângulo de quando ela rola


func _setup() -> void:
	max_hp = 10
	half_w = 18.0
	height = 34.0
	stomp_line = 26.0
	bubble_y = -66.0
	debris_colors = [GOURD, GOURD_DARK, GOURD_LIGHT, SILVER, MATE]


func _on_start() -> void:
	_shout("BAH!")


func _begin() -> void:
	_start_pula()


func _start_pula() -> void:
	_state = "pula"
	_hops = 3
	_timer = 0.5


func _can_stomp() -> bool:
	return _state == "entupiu"


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"pula":
			if is_on_floor():
				velocity.x = 0.0
				if _timer <= 0.0:
					if _hops <= 0:
						_state = "chimarrao"
						_drops = 8 if _angry() else 5
						_timer = 0.6
						_shout("ÁGUA QUENTE!")
						return
					_hops -= 1
					_face_player()
					velocity.y = -300.0
					velocity.x = facing * (90.0 if _angry() else 70.0)
					_timer = 0.05
			elif velocity.y > 0.0:
				_timer = 0.45
		"chimarrao":
			velocity.x = 0.0
			if _timer <= 0.0:
				_drops -= 1
				_timer = 0.28 if _angry() else 0.38
				# Cada gota cai num lugar diferente, uma delas perto do jogador.
				var target := _player_x() if _drops % 2 == 0 else _rng.randf_range(arena_left + 10.0, arena_right - 10.0)
				var t := 1.0
				var vx := (target - position.x) / t
				_shot("agua_quente", position + Vector2(0, -height - 14), Vector2(vx, -260.0), 520.0)
				Sfx.play("splash")
				if _drops <= 0:
					_state = "rola"
					_bounces = 2 if _angry() else 1
					_face_player()
					_shout("SAI DA FRENTE, GURI!")
		"rola":
			velocity.x = facing * (200.0 if _angry() else 165.0)
			_roll += facing * delta * 9.0
			if (facing < 0 and position.x <= arena_left + half_w + 1.0) or \
					(facing > 0 and position.x >= arena_right - half_w - 1.0):
				facing = -facing
				_bounces -= 1
				Sfx.play("slam")
				if _bounces < 0:
					_state = "entupiu"
					_roll = 0.0
					_timer = 1.8 if _angry() else 2.4
					_shout("BAH! ENTUPIU A BOMBA!")
		"entupiu":
			velocity.x = 0.0
			if _timer <= 0.0:
				_start_pula()


func _after_move(_delta: float) -> void:
	# Pouso dos pulos: espalha erva para os dois lados.
	if _state == "pula" and is_on_floor() and get_meta("air", false):
		Sfx.play("slam")
		for d in [-1, 1]:
			_shot("erva", position + Vector2(d * half_w, -6), Vector2(d * 120.0, -120.0), 500.0)
	set_meta("air", not is_on_floor())


func _on_hurt() -> void:
	_shout(_pick(["BAH, QUE JUDIAÇÃO!", "TRI DESNECESSÁRIO!", "ME DEIXA, TCHÊ!"]))
	if _state == "entupiu":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("TÁ, TÁ... SENTA AÍ E TOMA UM MATE.", 2.4)
	_break_apart()


func _draw_body() -> void:
	var f := float(facing)
	var shake := (1.0 if int(_t * 24.0) % 2 == 0 else -1.0) if _state == "entupiu" else 0.0
	draw_set_transform(Vector2(shake, -16), _roll, Vector2.ONE)
	# Cuia (porongo): bojo redondo e boca mais estreita, com a erva verde em cima
	_part(Rect2(-17, -6, 34, 22), GOURD)
	_part(Rect2(-13, -14, 26, 10), GOURD)
	draw_rect(Rect2(-15, -4, 6, 16), GOURD_LIGHT)
	draw_rect(Rect2(-17, 12, 34, 4), GOURD_DARK)
	draw_rect(Rect2(-12, -16, 24, 3), MATE)
	# Detalhe de prata na boca
	draw_rect(Rect2(-13, -14, 26, 2), SILVER)
	# Lenço vermelho de gaúcho
	_part(Rect2(-13, -4, 26, 4), SCARF)
	draw_colored_polygon(PackedVector2Array([Vector2(-2, 0), Vector2(4, 0), Vector2(1, 6)]), SCARF)
	# Olhos e bigodão
	var ex := f * 3.0
	var sad := _state == "entupiu"
	for x: float in [-7.0, 5.0]:
		_part(Rect2(ex + x, 2, 4, 4), Color.WHITE)
		draw_rect(Rect2(ex + x + (2 if f > 0 else 0), 3 + (1 if sad else 0), 2, 2), INK)
		draw_rect(Rect2(ex + x - 1, 0 if not sad else 1, 6, 1), INK)
	_part(Rect2(ex - 9, 8, 18, 3), Color("3b2416"))
	draw_rect(Rect2(ex - 11, 10, 3, 2), Color("3b2416"))
	draw_rect(Rect2(ex + 8, 10, 3, 2), Color("3b2416"))
	# Bomba de prata espetada na erva
	var top := Vector2(f * 6.0, -32)
	draw_line(Vector2(f * 2.0, -12), top, INK, 4.0)
	draw_line(Vector2(f * 2.0, -12), top, SILVER, 2.0)
	_part(Rect2(top + Vector2(-2, -3), Vector2(5, 3)), SILVER)
	if _state == "chimarrao":
		for k in 3:
			draw_rect(Rect2(top + Vector2(-1 + sin(_t * 12.0 + k) * 2.0, -8 - k * 4), Vector2(2, 3)), Color("bfefff"))
	if sad:
		for k in 2:
			draw_rect(Rect2(top + Vector2(-4 + k * 6, -10 - fmod(_t * 10.0 + k * 3, 8.0)), Vector2(2, 2)), Color("dfe6ee"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
