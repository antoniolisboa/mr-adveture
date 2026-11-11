extends "res://scripts/boss_base.gd"
## Boss do Paraná: o Quati-Rei das Cataratas, que manda em todos os quatis que roubam
## lanche de turista. Usa um boné de turista como coroa.
##
## Ciclo: "corre" (atravessa a arena atrás do jogador, duas vezes) -> "rouba" (pula
## bem alto e arremessa as sacolas roubadas em arco) -> "lanche" (senta e come um
## sanduíche roubado, distraído: hora de pisar) -> "corre".

const BOSS_NAME := "QUATI-REI DAS CATARATAS"
const ANNOUNCE := "ESSE LANCHE AÍ É MEU!"

const FUR := Color("8a5a3a")
const FUR_DARK := Color("5e3a24")
const FUR_LIGHT := Color("c89a6a")
const CAP := Color("f7d038")
const CAP_DARK := Color("d64545")
const BREAD := Color("e0a03c")

var _runs := 0
var _throws := 0
var _jumped := false


func _setup() -> void:
	max_hp = 8
	half_w = 20.0
	height = 24.0
	stomp_line = 18.0
	bubble_y = -58.0
	debris_colors = [FUR, FUR_DARK, FUR_LIGHT, CAP, CAP_DARK]


func _on_start() -> void:
	_shout("QUEM TROUXE BISCOITO?")


func _begin() -> void:
	_start_corre()


func _start_corre() -> void:
	_state = "corre"
	_runs = 2
	facing = 1 if position.x < (arena_left + arena_right) / 2.0 else -1


func _can_stomp() -> bool:
	return _state == "lanche"


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"corre":
			velocity.x = facing * (165.0 if _angry() else 125.0)
			if (facing < 0 and position.x <= arena_left + half_w + 1.0) or \
					(facing > 0 and position.x >= arena_right - half_w - 1.0):
				facing = -facing
				_runs -= 1
				if _runs <= 0:
					_state = "rouba"
					_jumped = false
					_throws = 5 if _angry() else 3
					_timer = 0.4
					_face_player()
					_shout("OLHA A SACOLA!")
		"rouba":
			velocity.x = 0.0
			if not _jumped and _timer <= 0.0:
				_jumped = true
				velocity.y = -380.0
				_timer = 0.12
			elif _jumped and _throws > 0 and _timer <= 0.0:
				_throws -= 1
				_timer = 0.14
				var dx := clampf(_player_x() - position.x, -170.0, 170.0)
				var spread := (_throws - 1) * 28.0
				_shot("sacola", position + Vector2(0, -height), Vector2(dx * 1.1 + spread, -150.0), 420.0)
				Sfx.play("throw")
			elif _jumped and _throws <= 0 and is_on_floor():
				_state = "lanche"
				_timer = 1.6 if _angry() else 2.3
				_shout("NHAM NHAM NHAM...")
		"lanche":
			velocity.x = 0.0
			if _timer <= 0.0:
				_shout("ACABOU! QUERO MAIS!")
				_start_corre()


func _on_hurt() -> void:
	_shout(_pick(["MEU SANDUÍCHE!", "ISSO NÃO É JEITO DE TRATAR A REALEZA!", "VOU CONTAR PROS QUATIS!"]))
	if _state == "lanche":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("TÁ BOM... NÃO ALIMENTEM OS QUATIS!", 2.4)
	_break_apart()


func _draw_body() -> void:
	var f := float(facing)
	var sitting := _state == "lanche"
	var run := absf(velocity.x) > 1.0
	var step := 2.0 if run and int(_t * 12.0) % 2 == 0 else 0.0
	# Rabo listrado em pé, atrás
	var tail_x := -f * 18.0
	for k in 7:
		var y := -18.0 - k * 5.0
		var sway := sin(_t * 4.0 + k * 0.5) * (k * 0.5)
		_part(Rect2(tail_x - 3 + sway - f * k * 0.6, y - 5, 7, 5), FUR_LIGHT if k % 2 == 0 else FUR_DARK)
	# Pernas
	if not sitting:
		for lx: float in [-12.0, -5.0, 6.0, 13.0]:
			var lift := step if (int(lx) % 2 == 0) else 2.0 - step
			_part(Rect2(lx - 2, -7 - lift * 0.5, 5, 7 + lift * 0.5), FUR_DARK)
	# Corpo
	var body_y := 4.0 if sitting else 0.0
	_part(Rect2(-18, -22 + body_y, 36, 16 - body_y), FUR)
	draw_rect(Rect2(-16, -22 + body_y, 32, 3), FUR_LIGHT)
	# Cabeça com o focinho comprido para a frente
	var hx := f * 18.0
	_part(Rect2(hx - 9, -32, 18, 14), FUR)
	_part(Rect2(hx + f * 8.0 - (0 if f > 0 else 10), -26, 10, 6), FUR_LIGHT)
	draw_rect(Rect2(hx + f * 17.0 - 1, -26, 3, 3), INK)        # narizinho
	# Máscara e olho maroto
	draw_rect(Rect2(hx - 6, -29, 12, 4), FUR_DARK)
	_part(Rect2(hx + f * 2.0 - 1, -29, 3, 3), Color.WHITE)
	draw_rect(Rect2(hx + f * 2.0 + (1 if f > 0 else -1), -28, 1, 2), INK)
	# Boné de turista virado de coroa
	_part(Rect2(hx - 8, -38, 16, 6), CAP)
	draw_rect(Rect2(hx - 8, -34, 16, 2), CAP_DARK)
	_part(Rect2(hx - f * 14.0 - (0 if f < 0 else -6) - 6, -34, 8, 2), CAP)
	# Sanduíche roubado na hora do lanche
	if sitting:
		var bite := int(_t * 4.0) % 2
		_part(Rect2(hx + f * 10.0 - 6, -20 + bite, 12, 7), BREAD)
		draw_rect(Rect2(hx + f * 10.0 - 6, -17 + bite, 12, 1), Color("5bbf3a"))
