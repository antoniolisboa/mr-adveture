extends "res://scripts/boss_base.gd"
## Boss de Alagoas: o Siri de Maragogi, dono das piscinas naturais, que não gosta de
## turista pisando no recife dele.
##
## Ciclo: "anda" (de lado, atrás do jogador; as pinças levantadas protegem o casco:
## pisar machuca) -> "bote" (2 ou 3 botes rápidos de pinça para a frente) -> "cansado"
## (abaixa as pinças, olhinhos caídos: hora de pisar) -> "bolhas" (sopra bolhas que
## sobem em ondinha na direção do jogador) -> "anda".

const BOSS_NAME := "SIRI DE MARAGOGI"
const ANNOUNCE := "SAI DO MEU RECIFE, TURISTA!"

const SHELL := Color("3f7fbf")
const SHELL_DARK := Color("2b5f8f")
const CLAW := Color("e85a3a")
const CLAW_DARK := Color("a83a22")
const BELLY := Color("f4f1e8")

var _snaps := 0
var _lunge := 0.0               # 0..1: quanto a pinça está esticada


func _setup() -> void:
	max_hp = 8
	half_w = 24.0
	height = 22.0
	stomp_line = 18.0
	bubble_y = -50.0
	debris_colors = [SHELL, SHELL_DARK, CLAW, CLAW_DARK, BELLY]


func _on_start() -> void:
	_shout("CLEC CLEC!")


func _begin() -> void:
	_start_anda()


func _start_anda() -> void:
	_state = "anda"
	_timer = 2.2 if _angry() else 2.8


func _can_stomp() -> bool:
	return _state == "cansado"


func _think(delta: float) -> void:
	_timer -= delta
	_lunge = move_toward(_lunge, 1.0 if _state == "bote" and _timer > 0.15 else 0.0, delta * 6.0)
	match _state:
		"anda":
			_face_player()
			var dx := _player_x() - position.x
			velocity.x = signf(dx) * (70.0 if _angry() else 50.0) if absf(dx) > 30.0 else 0.0
			if _timer <= 0.0:
				_state = "bote"
				_snaps = 3 if _angry() else 2
				_timer = 0.55
				_face_player()
				Sfx.play("pinca")
		"bote":
			velocity.x = facing * (220.0 if _timer > 0.25 else 0.0)
			_claw_hit()
			if _timer <= 0.0:
				_snaps -= 1
				if _snaps > 0:
					_timer = 0.55
					_face_player()
					Sfx.play("pinca")
				else:
					_state = "cansado"
					_timer = 1.6 if _angry() else 2.2
					_shout("UFA... CÃIMBRA NA PINÇA!")
		"cansado":
			velocity.x = 0.0
			if _timer <= 0.0:
				_state = "bolhas"
				_timer = 1.8
				_shout("BLUB BLUB!")
		"bolhas":
			velocity.x = 0.0
			if int(_t * 4.0) != int((_t - delta) * 4.0):
				var dx2 := clampf(_player_x() - position.x, -150.0, 150.0)
				_shot("bolha", position + Vector2(facing * 16, -14), Vector2(dx2 * 0.9, -60.0), -30.0)
				Sfx.play("bolha")
			if _timer <= 0.0:
				_start_anda()


## A pinça esticada no bote alcança mais longe que o corpo.
func _claw_hit() -> void:
	var p := _player()
	if p == null or p.dead or _lunge < 0.5:
		return
	var tip := position + Vector2(facing * (half_w + 16.0 * _lunge), -12)
	if p.global_position.distance_to(tip + Vector2(0, 6)) < 14.0:
		p.hurt()


func _bad_stomp() -> void:
	var p := _player()
	if p:
		p.hurt()
		_shout("NO CASCO NÃO, Ó!")


func _on_hurt() -> void:
	_shout(_pick(["AI, MEU CASCO!", "VOU CHAMAR OS PRIMOS!", "SIRI NÃO TEM SOSSEGO!"]))
	if _state == "cansado":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("TÁ BOM... O RECIFE É DE TODO MUNDO.", 2.2)
	_break_apart()


func _draw_body() -> void:
	var f := float(facing)
	var tired := _state == "cansado"
	# Perninhas finas dos lados (mexem andando de lado)
	var step := 1.0 if int(_t * 10.0) % 2 == 0 and absf(velocity.x) > 1.0 else 0.0
	for k in 3:
		for side: float in [-1.0, 1.0]:
			var x := side * (12.0 + k * 5.0)
			draw_line(Vector2(x, -8), Vector2(x + side * 4.0, -1.0 + (step if k % 2 == 0 else -step)), INK, 2.0)
	# Casco azul (siri) com a barriga clara
	_part(Rect2(-22, -20, 44, 12), SHELL)
	draw_rect(Rect2(-18, -20, 36, 2), Color("6fa8e0"))
	_part(Rect2(-16, -9, 32, 4), BELLY)
	for k in 4:
		draw_rect(Rect2(-14 + k * 9, -17, 4, 2), SHELL_DARK)
	# Olhinhos no talo
	for ex: float in [-6.0, 4.0]:
		draw_rect(Rect2(ex + 1, -26, 1, 6), INK)
		var ey := -28.0 if not tired else -25.0
		_part(Rect2(ex, ey, 3, 3), Color.WHITE)
		draw_rect(Rect2(ex + 1 + (1 if f > 0 else 0), ey + (1 if not tired else 2), 1, 1), INK)
	# Pinças: levantadas protegendo o casco, esticadas no bote, caídas cansado.
	for side: float in [-1.0, 1.0]:
		var front := side == f
		var base := Vector2(side * 20.0, -16)
		var claw: Vector2
		if tired:
			claw = Vector2(side * 28.0, -6)
		elif _state == "bote" and front:
			claw = Vector2(side * (28.0 + 16.0 * _lunge), -14)
		else:
			claw = Vector2(side * 14.0, -30)          # guarda alta em cima do casco
		draw_line(base, claw, INK, 4.0)
		draw_line(base, claw, CLAW_DARK, 2.0)
		var open := 3.0 if int(_t * 6.0) % 2 == 0 and not tired else 1.0
		_part(Rect2(claw + Vector2(-5, -4 - open), Vector2(10, 4)), CLAW)
		_part(Rect2(claw + Vector2(-5, 1), Vector2(10, 3)), CLAW)
