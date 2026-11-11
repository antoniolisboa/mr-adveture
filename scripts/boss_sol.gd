extends "res://scripts/boss_base.gd"
## Boss do Piauí: O Sol de Teresina, de óculos escuros, que se acha o dono do meio-dia.
## Flutua lá no alto, onde ninguém alcança.
##
## Ciclo: "raios" (marca 2 ou 3 faixas no chão, que piscam, e depois desce um raio
## em cada uma: saia das faixas) -> "ondas" (solta ondas de calor que vêm atrás do
## jogador; o leque desmancha) -> "desce" -> "cajuina" (até o sol cansa de tanto calor:
## desce para tomar uma cajuína gelada e fica ao alcance: hora de pisar) -> "sobe".

const BOSS_NAME := "O SOL DE TERESINA"
const ANNOUNCE := "AQUI É 40 GRAUS À SOMBRA... E NÃO TEM SOMBRA!"

const OndaCalor := preload("res://scripts/onda_calor.gd")

const SUN := Color("ffd23a")
const SUN_EDGE := Color("ff9a1a")
const GLASSES := Color("1a1a1a")
const CHEEK := Color("ff7a5a")
const BEAM := Color(1.0, 0.95, 0.5, 0.85)
const MARK := Color(1.0, 0.5, 0.1, 0.55)
const HIGH := 112.0             # altura do voo acima do chão

var _floor_y := 0.0
var _beams: Array = []          # posições x das faixas
var _beam_phase := ""           # "marca" ou "raio"
var _volleys := 0


func _setup() -> void:
	max_hp = 8
	half_w = 18.0
	height = 36.0
	stomp_line = 30.0
	bubble_y = -58.0
	gravity = 0.0
	debris_colors = [SUN, SUN_EDGE, Color("fff3c8")]


func _on_start() -> void:
	_floor_y = position.y
	_shout("TÁ QUENTE AÍ EMBAIXO?")
	var tw := create_tween()
	tw.tween_property(self, "position:y", _floor_y - HIGH, 1.2)


func _begin() -> void:
	_start_raios()


func _start_raios() -> void:
	_state = "raios"
	_volleys = 3 if _angry() else 2
	_mark_beams()


func _mark_beams() -> void:
	_beams.clear()
	var n := 3 if _angry() else 2
	_beams.append(clampf(_player_x(), arena_left + 12.0, arena_right - 12.0))
	for i in n - 1:
		_beams.append(_rng.randf_range(arena_left + 12.0, arena_right - 12.0))
	_beam_phase = "marca"
	_timer = 0.9
	Sfx.play("alerta")


func _can_stomp() -> bool:
	return _state == "cajuina"


func _think(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	match _state:
		"raios":
			position.x = move_toward(position.x, _player_x(), 40.0 * delta)
			if _beam_phase == "marca" and _timer <= 0.0:
				_beam_phase = "raio"
				_timer = 0.5
				Sfx.play("raio")
			elif _beam_phase == "raio":
				_beam_hit()
				if _timer <= 0.0:
					_volleys -= 1
					if _volleys > 0:
						_mark_beams()
					else:
						_beams.clear()
						_state = "ondas"
						_timer = 2.4
						_shout("SOLTA O MORMAÇO!")
						for i in (3 if _angry() else 2):
							var o := OndaCalor.new()
							o.position = position + Vector2((i - 0.5) * 50.0, 10.0)
							get_parent().add_child(o)
		"ondas":
			position.x = move_toward(position.x, (arena_left + arena_right) / 2.0, 50.0 * delta)
			if _timer <= 0.0:
				_state = "desce"
				_shout("UFA... ATÉ EU TÔ COM CALOR!")
				var tw := create_tween()
				tw.tween_property(self, "position:y", _floor_y, 1.0).set_ease(Tween.EASE_IN)
				_timer = 1.0
		"desce":
			if _timer <= 0.0:
				_state = "cajuina"
				_timer = 1.8 if _angry() else 2.6
				_shout("UMA CAJUÍNA GELADA, POR FAVOR...")
		"cajuina":
			if _timer <= 0.0:
				_go_up()
		"sobe":
			if _timer <= 0.0:
				_start_raios()


func _go_up() -> void:
	_state = "sobe"
	_timer = 1.0
	var tw := create_tween()
	tw.tween_property(self, "position:y", _floor_y - HIGH, 1.0).set_ease(Tween.EASE_OUT)


func _beam_hit() -> void:
	var p := _player()
	if p == null or p.dead:
		return
	for bx in _beams:
		if absf(p.global_position.x - bx) < 10.0:
			p.hurt()


func _on_hurt() -> void:
	_shout(_pick(["AI, QUEIMEI A LÍNGUA!", "DERRAMOU MINHA CAJUÍNA!", "VIXE, NUBLOU!"]))
	if _state == "cajuina":
		_timer = minf(_timer, 0.2)


func _on_zero_hp() -> void:
	_shout("TÁ BOM... VOU ME PÔR. ATÉ AMANHÃ!", 2.2)
	for o in get_tree().get_nodes_in_group("ondas_calor"):
		o.knock()
	_beams.clear()
	_break_apart()


func _draw_back() -> void:
	# As faixas e os raios ficam no chão da arena, que está abaixo do sol.
	var floor_local := _floor_y - position.y
	for bx in _beams:
		var lx: float = bx - position.x
		if _beam_phase == "marca":
			if int(_t * 12.0) % 2 == 0:
				draw_rect(Rect2(lx - 10, floor_local - 4, 20, 4), MARK)
		else:
			draw_rect(Rect2(lx - 9, -300, 18, floor_local + 300), BEAM)
			draw_rect(Rect2(lx - 4, -300, 8, floor_local + 300), Color.WHITE)
	if _state == "cajuina" or _state == "desce":
		# Barraquinha com a garrafa de cajuína (cor de âmbar, sem marca nenhuma).
		var x := 26.0
		_part(Rect2(x - 8, -12, 18, 12), Color("c9a36b"))
		_part(Rect2(x - 1, -22, 5, 10), Color("e8b040"))
		draw_rect(Rect2(x, -25, 3, 3), Color("e8b040"))
		draw_rect(Rect2(x - 1, -18, 5, 3), Color.WHITE)


func _draw_body() -> void:
	var c := Vector2(0, -18)
	# Raios em volta girando devagar
	var spin := _t * (2.0 if _state != "cajuina" else 0.4)
	for k in 10:
		var a := spin + k * TAU / 10.0
		var d := Vector2(cos(a), sin(a))
		var p1 := c + d * 19.0
		var p2 := c + d * (27.0 + (3.0 if k % 2 == 0 else 0.0))
		draw_line(p1, p2, SUN_EDGE, 3.0)
	draw_circle(c, 19.0, INK)
	draw_circle(c, 18.0, SUN_EDGE)
	draw_circle(c, 16.0, SUN)
	# Óculos escuros enormes
	_part(Rect2(c + Vector2(-13, -7), Vector2(11, 7)), GLASSES)
	_part(Rect2(c + Vector2(2, -7), Vector2(11, 7)), GLASSES)
	draw_rect(Rect2(c + Vector2(-2, -6), Vector2(4, 2)), GLASSES)
	draw_rect(Rect2(c + Vector2(-11, -6), Vector2(3, 1)), Color("6a6a7a"))
	draw_rect(Rect2(c + Vector2(4, -6), Vector2(3, 1)), Color("6a6a7a"))
	draw_rect(Rect2(c + Vector2(-13, 2), Vector2(4, 3)), CHEEK)
	draw_rect(Rect2(c + Vector2(9, 2), Vector2(4, 3)), CHEEK)
	if _state == "cajuina":
		draw_rect(Rect2(c + Vector2(-3, 6), Vector2(6, 3)), INK)        # boca no canudinho
		draw_rect(Rect2(c + Vector2(3, 7), Vector2(14, 1)), Color.WHITE)
		draw_rect(Rect2(c + Vector2(13, 1), Vector2(2, 3)), Color("7fd0f0"))   # gota de suor
	else:
		draw_rect(Rect2(c + Vector2(-6, 6), Vector2(12, 2)), INK)       # sorriso convencido
		draw_rect(Rect2(c + Vector2(4, 4), Vector2(2, 2)), INK)
