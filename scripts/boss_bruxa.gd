extends "res://scripts/boss_base.gd"
## Boss de Santa Catarina: a Bruxa da Ilha, das histórias de bruxas de Florianópolis
## (a Ilha da Magia). Mora debaixo da Ponte Hercílio Luz e não gosta de visita.
##
## Ciclo: "voa" (voa lá no alto atrás do jogador soltando feitiços que caem) ->
## "vassourada" (desce num canto e varre a arena rente ao chão: pule por cima) ->
## "tonta" (tropeça na própria vassoura e cai sentada no chão: hora de pisar) ->
## "sobe" -> "voa".

const BOSS_NAME := "A BRUXA DA ILHA"
const ANNOUNCE := "QUEM É QUE TÁ PASSANDO NA MINHA PONTE?"

const ROBE := Color("4a2a6a")
const ROBE_LIGHT := Color("6a4a9a")
const SKIN := Color("8fcf6a")
const HAIR := Color("e8e8f0")
const BROOM := Color("8a6a3f")
const STRAW := Color("e0b050")

var _floor_y := 0.0
var _drops := 0
var _sweeps := 0
var _side := 1.0


func _setup() -> void:
	max_hp = 8
	half_w = 14.0
	height = 26.0
	stomp_line = 20.0
	bubble_y = -50.0
	gravity = 0.0
	debris_colors = [ROBE, ROBE_LIGHT, SKIN, BROOM, STRAW]


func _on_start() -> void:
	_floor_y = position.y
	_shout("HI HI HI HI!")


func _begin() -> void:
	_start_voa()


func _start_voa() -> void:
	_state = "voa"
	_drops = 6 if _angry() else 4
	_timer = 0.9


func _can_stomp() -> bool:
	return _state == "tonta"


func _top_y() -> float:
	return _floor_y - 82.0


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"voa":
			var tx := _player_x() + sin(_t * 1.3) * 40.0
			velocity.x = clampf((tx - position.x) * 2.0, -90.0, 90.0)
			velocity.y = (_top_y() + sin(_t * 3.0) * 6.0 - position.y) * 4.0
			_face_player()
			if _timer <= 0.0:
				_timer = 0.55 if _angry() else 0.75
				_drops -= 1
				var n := 3 if _angry() else 1
				for i in n:
					var s := _shot("feitico", position + Vector2(0, -8), Vector2((i - (n - 1) / 2.0) * 50.0, 30.0), 260.0)
					s.reflectable = true
				Sfx.play("feitico")
				if _drops <= 0:
					_state = "desce"
					_sweeps = 2 if _angry() else 1
					_side = -1.0 if _player_x() > (arena_left + arena_right) / 2.0 else 1.0
					_shout("VASSOURADA!")
		"desce":
			# Vai para um canto, rente ao chão.
			var target := Vector2(arena_left + half_w + 4.0 if _side < 0 else arena_right - half_w - 4.0, _floor_y - 2.0)
			var to := target - position
			velocity = to.limit_length(40.0) * 5.0
			facing = int(-_side)
			if to.length() < 4.0:
				_state = "vassourada"
				_timer = 0.35
		"vassourada":
			velocity.y = (_floor_y - 2.0 - position.y) * 6.0
			velocity.x = 0.0 if _timer > 0.0 else -_side * (190.0 if _angry() else 160.0)
			facing = int(-_side)
			if _timer <= 0.0 and ((_side < 0 and position.x >= arena_right - half_w - 2.0) or \
					(_side > 0 and position.x <= arena_left + half_w + 2.0)):
				_sweeps -= 1
				_side = -_side
				if _sweeps > 0:
					_timer = 0.3
				else:
					_state = "tonta"
					_timer = 1.7 if _angry() else 2.3
					velocity = Vector2.ZERO
					position.y = _floor_y
					_shout("TROPECEI NA VASSOURA!")
		"tonta":
			velocity = Vector2.ZERO
			position.y = _floor_y
			if _timer <= 0.0:
				_state = "sobe"
				_shout("AGORA EU TÔ BRABA!")
		"sobe":
			velocity = Vector2(0, (_top_y() - position.y) * 3.0)
			if position.y <= _top_y() + 4.0:
				_start_voa()


func _on_hurt() -> void:
	_shout(_pick(["AI, MEU CHAPÉU!", "VOU TE TRANSFORMAR EM TAINHA!", "NA MINHA ILHA NÃO!"]))
	if _state == "tonta":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("TÁ BEM... PODE PASSAR NA PONTE.", 2.4)
	_break_apart()


func _draw_back() -> void:
	# Faíscas de magia atrás da vassoura
	if _state in ["voa", "vassourada", "desce", "sobe"]:
		for k in 4:
			var x := -facing * (22.0 + k * 6.0)
			var y := -6.0 + sin(_t * 9.0 + k) * 3.0
			draw_rect(Rect2(x, y, 2, 2), Color("ff9ae0") if k % 2 == 0 else Color("fff3b0"))


func _draw_body() -> void:
	var f := float(facing)
	var dizzy := _state == "tonta"
	# Vassoura
	if dizzy:
		draw_line(Vector2(-22, -2), Vector2(20, -6), INK, 4.0)
		draw_line(Vector2(-22, -2), Vector2(20, -6), BROOM, 2.0)
		_part(Rect2(20, -10, 8, 8), STRAW)
	else:
		draw_line(Vector2(f * 20.0, -8), Vector2(-f * 20.0, -6), INK, 4.0)
		draw_line(Vector2(f * 20.0, -8), Vector2(-f * 20.0, -6), BROOM, 2.0)
		var sx := -f * 20.0 - (8.0 if f > 0 else 0.0)
		_part(Rect2(sx, -11, 8, 9), STRAW)
		for k in 3:
			draw_rect(Rect2(sx + k * 3, -3, 1, 2), STRAW)
	# Vestido
	_part(Rect2(-9, -22, 18, 16), ROBE)
	draw_rect(Rect2(-9, -10, 18, 2), ROBE_LIGHT)
	# Cabeça verde com cabelo branco desgrenhado
	var hy := -32.0 if not dizzy else -30.0
	for k in 5:
		draw_rect(Rect2(-8 + k * 3 - f * 2.0, hy - 1 + (k % 2) * 2, 3, 9), HAIR)
	_part(Rect2(-6, hy, 12, 10), SKIN)
	draw_rect(Rect2(f * 5.0 - (0 if f > 0 else 2), hy + 4, 3, 3), SKIN.darkened(0.2))   # narigão
	if dizzy:
		# Olhinhos girando e estrelas
		draw_rect(Rect2(-4, hy + 3, 2, 2), INK)
		draw_rect(Rect2(2, hy + 3, 2, 2), INK)
		for k in 3:
			var a := _t * 5.0 + k * TAU / 3.0
			draw_rect(Rect2(cos(a) * 12.0 - 1, hy - 8 + sin(a) * 3.0, 3, 3), Color("fff3b0"))
	else:
		draw_rect(Rect2(f * 1.0 - 1, hy + 3, 2, 2), INK)
		draw_rect(Rect2(f * 1.0 - 1, hy + 7, 5 if f > 0 else -5, 1), INK)   # sorriso torto
	# Chapéu pontudo
	var hat := PackedVector2Array([Vector2(-10, hy + 1), Vector2(10, hy + 1), Vector2(-f * 8.0, hy - 16)])
	draw_colored_polygon(PackedVector2Array([hat[0] + Vector2(-1, 1), hat[1] + Vector2(1, 1), hat[2] + Vector2(0, -1)]), INK)
	draw_colored_polygon(hat, ROBE)
	draw_rect(Rect2(-10, hy - 1, 20, 2), ROBE_LIGHT)
