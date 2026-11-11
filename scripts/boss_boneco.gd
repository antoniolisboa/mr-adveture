extends "res://scripts/boss_base.gd"
## Boss de Pernambuco: o Boneco Gigante de Olinda, de cabeça de papel machê e braços de
## pano compridos. Ninguém controla mais o boneco: ele dança frevo sozinho.
##
## Ciclo: "passo" (2 ou 3 saltos de frevo na direção do jogador: dá para correr por
## baixo enquanto ele está no ar) -> "gira" (rodopio parado; as mangas varrem o chão
## dos dois lados: pule as mangas ou fique longe; bravo, solta confete) -> "tonto" ->
## "reverencia" (agradece ao público e a cabeça desce até o chão: hora de pisar).
## Fora da reverência, encostar no boneco machuca.

const BOSS_NAME := "BONECO GIGANTE DE OLINDA"
const ANNOUNCE := "O BONECO DE OLINDA NÃO PARA DE DANÇAR!"

const SUIT := Color("6a4fa0")
const SUIT_LIGHT := Color("8f74c8")
const SHIRT := Color("f4f1e8")
const TIE := Color("d64545")
const HEAD := Color("ffd28a")
const CHEEK := Color("e85d75")
const HAT := Color("2b1d2e")
const HAT_BAND := Color("f7d038")
const SLEEVE := Color("f7d038")
const CONFETE := [Color("d64545"), Color("f7d038"), Color("2a9d4a"), Color("3f8fd1"), Color("e85d75")]

const ARM_REACH := 46.0

var _hops := 0
var _was_on_floor := true
var _bow := 0.0                 # 0 = em pé, 1 = cabeça no chão
var _spin := 0.0


func _setup() -> void:
	max_hp = 8
	half_w = 13.0
	height = 70.0
	stomp_line = 66.0
	bubble_y = -96.0
	debris_colors = [SUIT, HEAD, SLEEVE, SHIRT, TIE]


func _on_start() -> void:
	_shout("BORA FREVAR!")


func _begin() -> void:
	_start_passo()


func _start_passo() -> void:
	_state = "passo"
	_hops = 3 if _angry() else 2
	_timer = 0.4


func _can_stomp() -> bool:
	return _state == "reverencia" and _bow > 0.8


func _bad_stomp() -> void:
	var p := _player()
	if p:
		p.hurt()


func _think(delta: float) -> void:
	_spin += delta * (14.0 if _state == "gira" else 0.0)
	var target_bow := 1.0 if _state == "reverencia" else 0.0
	_bow = move_toward(_bow, target_bow, delta * 3.0)
	match _state:
		"passo":
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
				_timer -= delta
				if _timer <= 0.0:
					if _hops > 0:
						_hops -= 1
						_face_player()
						var dist := clampf(absf(_player_x() - position.x), 40.0, 140.0)
						velocity = Vector2(facing * dist / 0.85, -380.0)
						_was_on_floor = false
						_timer = 0.35
						Sfx.play("jump")
					else:
						_state = "gira"
						_timer = 3.0 if _angry() else 2.4
						_shout("OLHA O PASSO!")
		"gira":
			velocity.x = 0.0
			_timer -= delta
			_sleeves_hit()
			if _angry() and int(_t * 10.0) != int((_t - delta) * 10.0) and int(_t * 10.0) % 4 == 0:
				var a := _rng.randf_range(-1.0, 1.0)
				_shot("confete", position + Vector2(0, -60), Vector2(a * 150.0, -200.0), 400.0)
			if _timer <= 0.0:
				_state = "tonto"
				_timer = 0.7
				_shout("EITA, TONTEI...")
		"tonto":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_face_player()
				_state = "reverencia"
				_timer = 1.6 if _angry() else 2.2
				_shout("OBRIGADO, OLINDA!")
		"reverencia":
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				_start_passo()
	_update_shape()


func _after_move(_delta: float) -> void:
	if is_on_floor() and not _was_on_floor and _state == "passo":
		Sfx.play("crash")
	_was_on_floor = is_on_floor()


## As mangas compridas varrem o chão no rodopio.
func _sleeves_hit() -> void:
	var p := _player()
	if p == null or p.dead:
		return
	var reach := ARM_REACH * absf(cos(_spin))
	var d: Vector2 = p.global_position - global_position
	if absf(d.x) < reach + 6.0 and absf(d.x) > half_w and d.y > -20.0:
		p.hurt()


## Na reverência a parte de cima desce: a área de contato vira a cabeça, lá na frente.
func _update_shape() -> void:
	var rect := _shape.shape as RectangleShape2D
	if _bow > 0.8:
		rect.size = Vector2(44, 30)
		_shape.position = Vector2(facing * 24, -15)
		stomp_line = 26.0
	else:
		rect.size = Vector2(half_w * 2.0, height)
		_shape.position = Vector2(0, -height / 2.0)
		stomp_line = 66.0


func _on_hurt() -> void:
	_shout(_pick(["AI, MINHA CABEÇA DE PAPEL!", "ÉGUA... QUER DIZER, ÔXE!", "AMASSOU MEU CHAPÉU!"]))
	if _state == "reverencia":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	_shout("O FREVO NUNCA MORRE...", 2.0)
	for i in 14:
		_shot("confete", position + Vector2(0, -50), Vector2(_rng.randf_range(-160.0, 160.0),
				_rng.randf_range(-300.0, -120.0)), 400.0).collision_mask = 1
	_break_apart()


# --- Desenho -------------------------------------------------------------

func _draw_body() -> void:
	# Saia/paletó comprido até o chão, um pouco mais largo embaixo.
	_part(Rect2(-15, -12, 30, 12), SUIT)
	_part(Rect2(-13, -40, 26, 30), SUIT)
	draw_rect(Rect2(-11, -38, 2, 34), SUIT_LIGHT)
	for y in [-34, -24, -14]:
		draw_rect(Rect2(-1, y, 2, 2), HAT_BAND)       # botões dourados
	draw_rect(Rect2(-15, -2, 30, 2), INK)

	# Parte de cima: dobra na cintura na reverência (gira em volta da cintura).
	var ang := facing * _bow * 2.2
	draw_set_transform(Vector2(0, -36), ang, Vector2.ONE)
	_part(Rect2(-14, -14, 28, 14), SUIT)               # ombros
	_part(Rect2(-5, -14, 10, 10), SHIRT)
	_part(Rect2(-3, -13, 6, 3), TIE)
	# Cabeça grande de papel machê, com chapéu.
	var head := Vector2(0, -28)
	draw_circle(head, 15.0, INK)
	draw_circle(head, 14.0, HEAD)
	draw_rect(Rect2(head + Vector2(-9, -2), Vector2(4, 3)), CHEEK)
	draw_rect(Rect2(head + Vector2(5, -2), Vector2(4, 3)), CHEEK)
	if _state == "tonto":
		for x: float in [-7.0, 3.0]:
			draw_rect(Rect2(head + Vector2(x, -8), Vector2(4, 1)), INK)
			draw_rect(Rect2(head + Vector2(x + 1, -9), Vector2(2, 3)), INK)
	else:
		for x: float in [-7.0, 3.0]:
			draw_rect(Rect2(head + Vector2(x, -9), Vector2(4, 4)), Color.WHITE)
			draw_rect(Rect2(head + Vector2(x + 1 + facing, -8), Vector2(2, 2)), INK)
	draw_rect(Rect2(head + Vector2(-6, 4), Vector2(12, 2)), INK)  # sorrisão
	draw_rect(Rect2(head + Vector2(-5, 6), Vector2(10, 1)), TIE)
	_part(Rect2(head + Vector2(-16, -15), Vector2(32, 3)), HAT)
	_part(Rect2(head + Vector2(-10, -26), Vector2(20, 11)), HAT)
	draw_rect(Rect2(head + Vector2(-10, -18), Vector2(20, 2)), HAT_BAND)
	# Braços de pano: pendurados, balançando com a dança.
	if _state != "gira":
		var sway := sin(_t * 6.0) * 4.0
		_part(Rect2(-19, -13 + sway * 0.2, 5, 30), SLEEVE)
		_part(Rect2(14, -13 - sway * 0.2, 5, 30), SLEEVE)
		_part(Rect2(-20 + sway * 0.3, 16, 6, 5), HEAD)
		_part(Rect2(14 - sway * 0.3, 16, 6, 5), HEAD)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Rodopio: as mangas abertas varrendo rente ao chão.
	if _state == "gira":
		var reach := ARM_REACH * cos(_spin)
		for side: float in [-1.0, 1.0]:
			var x0 := side * 12.0
			var x1 := side * (12.0 + absf(reach))
			var r := Rect2(minf(x0, x1), -16 if reach * side > 0.0 else -13, absf(x1 - x0), 5)
			_part(r, SLEEVE)
			_part(Rect2(Vector2(x1 - 3, r.position.y - 1), Vector2(6, 6)), HEAD)
