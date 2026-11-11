extends "res://scripts/boss_base.gd"
## Boss de Sergipe: o Caranguejo da Passarela, o maior caranguejo-uçá do mangue, que
## cansou de ver os primos virarem prato na passarela.
##
## Ciclo: "corre" (atravessa a arena de lado) -> "martelo" (levanta a pinça grande e
## bate na passarela: sai uma onda de lama pelos dois lados; a pinça fica entalada
## nas tábuas: hora de pisar) -> "filhotes" (chama dois caranguejinhos: com a pinça
## dá para agarrar um e arremessar no grandão a qualquer hora!).

const BOSS_NAME := "CARANGUEJO DA PASSARELA"
const ANNOUNCE := "AQUI NA PASSARELA QUEM MANDA SOU EU!"

const Caranguejo := preload("res://scripts/caranguejo.gd")

const SHELL := Color("c0402a")
const SHELL_DARK := Color("8a2a1a")
const SHELL_LIGHT := Color("e8704a")
const LEG := Color("a8342a")

var _runs := 0
var _raise := 0.0               # 0 = pinça no chão, 1 = lá no alto
var _stuck := false


func _setup() -> void:
	max_hp = 8
	half_w = 26.0
	height = 26.0
	stomp_line = 22.0
	bubble_y = -62.0
	debris_colors = [SHELL, SHELL_DARK, SHELL_LIGHT, LEG]


func _on_start() -> void:
	_shout("CLEC... CLEC... CLEC!")


func _begin() -> void:
	_start_corre()


func _start_corre() -> void:
	_state = "corre"
	_runs = 2 if _angry() else 1
	facing = 1 if position.x < (arena_left + arena_right) / 2.0 else -1


func _can_stomp() -> bool:
	return _state == "entalado"


## Caranguejinho arremessado pela pinça: dói em qualquer hora.
func hit_by_throw() -> void:
	_take_damage(2)


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"corre":
			velocity.x = facing * (170.0 if _angry() else 130.0)
			if (facing < 0 and position.x <= arena_left + half_w + 1.0) or \
					(facing > 0 and position.x >= arena_right - half_w - 1.0):
				facing = -facing
				_runs -= 1
				if _runs <= 0:
					_state = "martelo"
					_timer = 0.9
					_face_player()
					_shout("LÁ VAI MARTELADA!")
		"martelo":
			velocity.x = 0.0
			_raise = move_toward(_raise, 1.0, delta * 2.0)
			if _timer <= 0.0:
				_raise = 0.0
				_slam()
				_state = "entalado"
				_timer = 1.6 if _angry() else 2.2
				_shout("ENTALOU NA TÁBUA!")
		"entalado":
			velocity.x = 0.0
			if _timer <= 0.0:
				_state = "filhotes"
				_timer = 1.4
				_shout("VEM, PRIMARADA!")
				for i in 2:
					var c := Caranguejo.new()
					c.position = position + Vector2((i * 2 - 1) * (half_w + 10.0), -4)
					c.dir = i * 2 - 1
					get_parent().add_child(c)
		"filhotes":
			velocity.x = 0.0
			if _timer <= 0.0:
				_start_corre()


func _slam() -> void:
	Sfx.play("slam")
	var claw_x := position.x + facing * (half_w + 8.0)
	for d in [-1, 1]:
		_shot("lama", Vector2(claw_x, position.y - 5), Vector2(d * 130.0, 0), 0.0)


func _on_hurt() -> void:
	_shout(_pick(["AI, MEU CASCO!", "ISSO É CARANGUEJO, NÃO É TAMBOR!", "VOU PRO MANGUE!"]))
	if _state == "entalado":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("TÁ BOM, VOU VIRAR VEGETARIANO...", 2.2)
	_break_apart()


func _draw_body() -> void:
	var f := float(facing)
	var walk := 1.0 if int(_t * 12.0) % 2 == 0 and absf(velocity.x) > 1.0 else 0.0
	# Pernas (quatro de cada lado)
	for k in 4:
		for side: float in [-1.0, 1.0]:
			var x := side * (10.0 + k * 5.0)
			var lift := walk if (k + int(side)) % 2 == 0 else -walk
			draw_line(Vector2(x, -10), Vector2(x + side * 6.0, -4 - lift), INK, 3.0)
			draw_line(Vector2(x + side * 6.0, -4 - lift), Vector2(x + side * 7.0, 0), INK, 2.0)
			draw_line(Vector2(x, -10), Vector2(x + side * 6.0, -4 - lift), LEG, 1.0)
	# Casco
	_part(Rect2(-24, -26, 48, 16), SHELL)
	draw_rect(Rect2(-20, -26, 40, 3), SHELL_LIGHT)
	draw_rect(Rect2(-24, -14, 48, 2), SHELL_DARK)
	# Olhos no talo, brabos
	for ex: float in [-8.0, 5.0]:
		draw_rect(Rect2(ex + 1, -33, 2, 7), INK)
		_part(Rect2(ex, -36, 4, 4), Color.WHITE)
		draw_rect(Rect2(ex + 1 + (1 if f > 0 else 0), -35, 2, 2), INK)
		draw_rect(Rect2(ex - 1, -38, 6, 1), INK)
	# Pinça pequena atrás e a pinça GRANDE na frente
	var small := Vector2(-f * 30.0, -18)
	draw_line(Vector2(-f * 20.0, -18), small, INK, 4.0)
	_part(Rect2(small + Vector2(-4, -4), Vector2(8, 6)), SHELL)
	var arm := Vector2(f * 22.0, -20)
	var claw: Vector2
	if _state == "martelo":
		claw = arm + Vector2(f * 10.0, -10.0 - 26.0 * _raise)
	elif _state == "entalado":
		claw = Vector2(f * (half_w + 8.0), -4)
	else:
		claw = arm + Vector2(f * 12.0, -6.0)
	draw_line(arm, claw, INK, 6.0)
	draw_line(arm, claw, SHELL, 3.0)
	_part(Rect2(claw + Vector2(-9, -7), Vector2(18, 12)), SHELL)
	draw_rect(Rect2(claw + Vector2(-9, -7), Vector2(18, 2)), SHELL_LIGHT)
	draw_rect(Rect2(claw + Vector2(f * 2.0 - 1, -2), Vector2(9, 2)), INK)
	if _state == "entalado":
		for k in 3:
			draw_rect(Rect2(claw + Vector2(-12 + k * 9, 3), Vector2(4, 2)), Color("8a6a3f"))   # lascas de tábua
