extends "res://scripts/boss_base.gd"
## Boss da Paraíba: a Quadrilha Gigante do São João de Campina Grande. O noivo puxa a
## fila (é ele que leva os pisões) e o casal de trás vai junto. Os passos seguem o
## que o marcador grita:
##   "CAMINHO DA ROÇA!"  a fila atravessa a arena correndo (pule os dançarinos)
##   "OLHA A COBRA!"     uma cobra de pano desliza pelo chão (pule)
##   "OLHA A CHUVA!"     pingos caem do céu (desvie)
##   "É MENTIRA!"        todo mundo para e ri: o noivo fica distraído (hora de pisar)
## Brava, a quadrilha manda duas cobras e mais chuva.

const BOSS_NAME := "QUADRILHA GIGANTE"
const ANNOUNCE := "ANARRIÊ! A QUADRILHA VAI COMEÇAR!"

const STRAW := Color("e8c060")
const STRAW_DARK := Color("b08a3a")
const SKIN := Color("e0a47a")
const VEIL := Color("ffffff")
const PLAID := [Color("d64545"), Color("3f8fd1"), Color("2a9d4a")]
const DRESS := [Color("ffffff"), Color("f7d038"), Color("e85d75")]
const FOLLOW_GAP := 44.0

var _step := 0                  # posição na sequência de passos
var _followers: Array = []      # posição x dos dançarinos de trás
var _dir := -1
const STEPS := ["roca", "cobra", "mentira", "chuva", "mentira"]


func _setup() -> void:
	max_hp = 8
	half_w = 7.0
	height = 26.0
	stomp_line = 22.0
	bubble_y = -50.0
	debris_colors = [STRAW, PLAID[0], DRESS[0], PLAID[1]]


func _on_start() -> void:
	_shout("ANARRIÊ!")
	_followers = [position.x + FOLLOW_GAP, position.x + FOLLOW_GAP * 2.0]


func _begin() -> void:
	_next_step()


func _next_step() -> void:
	var step: String = STEPS[_step % STEPS.size()]
	_step += 1
	_state = step
	match step:
		"roca":
			_timer = 4.0
			_dir = -1 if position.x > (arena_left + arena_right) / 2.0 else 1
			_shout("CAMINHO DA ROÇA!")
		"cobra":
			_timer = 2.4
			_shout("OLHA A COBRA!")
			var from_left: bool = _player_x() > (arena_left + arena_right) / 2.0
			for i in (2 if _angry() else 1):
				var x := arena_left + 4.0 if from_left else arena_right - 4.0
				var s := _shot("cobra", Vector2(x, position.y - 6.0), Vector2((1 if from_left else -1) * 110.0, 0), 0.0)
				s.position.x -= (1 if from_left else -1) * i * 90.0
		"chuva":
			_timer = 2.6 if _angry() else 2.0
			_shout("OLHA A CHUVA!")
		"mentira":
			_timer = 2.0 if _angry() else 2.6
			_shout("É MENTIRA!", 1.0)
			Sfx.play("risada")


func _can_stomp() -> bool:
	return _state == "mentira"


func _think(delta: float) -> void:
	velocity.x = 0.0
	_timer -= delta
	match _state:
		"roca":
			var spd := 140.0 if _angry() else 115.0
			velocity.x = _dir * spd
			facing = _dir
			if (_dir < 0 and position.x <= arena_left + half_w + 2.0) or \
					(_dir > 0 and position.x >= arena_right - half_w - 2.0):
				_dir = -_dir
				if _timer < 1.2:
					_timer = 0.0
		"cobra":
			if is_on_floor() and int(_t * 3.0) % 2 == 0:
				velocity.y = -160.0          # pulinho de susto
		"chuva":
			if int(_t * 10.0) != int((_t - delta) * 10.0):
				var x := _rng.randf_range(arena_left + 8.0, arena_right - 8.0)
				_shot("pingo", Vector2(x, position.y - 190.0), Vector2(0, 60.0), 300.0)
	if _timer <= 0.0:
		_next_step()


func _after_move(delta: float) -> void:
	# O casal de trás vem atrás do noivo, cada um no seu espaço.
	var target := position.x
	for i in _followers.size():
		target -= facing * FOLLOW_GAP
		var want := clampf(target, arena_left + 7.0, arena_right - 7.0)
		_followers[i] = move_toward(_followers[i], want, 200.0 * delta)
	_followers_hit()


func _followers_hit() -> void:
	var p := _player()
	if p == null or p.dead or _state == "mentira":
		return
	for fx in _followers:
		var d: Vector2 = p.global_position - Vector2(fx, position.y)
		if absf(d.x) < 11.0 and d.y > -26.0 and d.y < 14.0:
			p.hurt()


func _on_hurt() -> void:
	_shout(_pick(["AI, PISOU NO MEU PÉ!", "VIXE, ERREI O PASSO!", "ÊTA, QUE SANFONEIRO RUIM!"]))
	if _state == "mentira":
		_timer = minf(_timer, 0.4)


func _on_zero_hp() -> void:
	_shout("ACABOU A QUADRILHA... VIVA SÃO JOÃO!", 2.0)
	_followers.clear()
	_break_apart()


# --- Desenho -------------------------------------------------------------

func _draw_back() -> void:
	if dead:
		return
	for i in _followers.size():
		var fx: float = _followers[i] - position.x
		_dancer(Vector2(fx, 0), i == 0, i + 1)


func _draw_body() -> void:
	_dancer(Vector2.ZERO, false, 0)


## Dançarino de quadrilha: chapéu de palha, camisa xadrez (ou vestido de chita).
func _dancer(at: Vector2, dama: bool, idx: int) -> void:
	var bob := -1.0 if int(_t * 8.0 + idx) % 2 == 0 and _state in ["roca", "chuva"] else 0.0
	var laugh := _state == "mentira"
	var o := at + Vector2(0, bob)
	if dama:
		_part(Rect2(o + Vector2(-7, -15), Vector2(14, 15)), DRESS[idx % DRESS.size()])
		for k in 3:
			draw_rect(Rect2(o + Vector2(-5 + k * 4, -10), Vector2(2, 2)), Color("e85d75"))
		_part(Rect2(o + Vector2(-4, -21), Vector2(8, 6)), DRESS[(idx + 1) % DRESS.size()])
	else:
		_part(Rect2(o + Vector2(-4, -8), Vector2(3, 8)), Color("2b5fb4"))
		_part(Rect2(o + Vector2(1, -8), Vector2(3, 8)), Color("2b5fb4"))
		_part(Rect2(o + Vector2(-5, -18), Vector2(10, 10)), PLAID[idx % PLAID.size()])
		draw_rect(Rect2(o + Vector2(-5, -14), Vector2(10, 1)), Color.WHITE)
		draw_rect(Rect2(o + Vector2(-1, -18), Vector2(1, 10)), Color.WHITE)
	# Cabeça
	_part(Rect2(o + Vector2(-4, -26), Vector2(8, 7)), SKIN)
	if laugh:
		draw_rect(Rect2(o + Vector2(-2, -22), Vector2(4, 2)), INK)
		draw_rect(Rect2(o + Vector2(-3, -25), Vector2(2, 1)), INK)
		draw_rect(Rect2(o + Vector2(1, -25), Vector2(2, 1)), INK)
	else:
		draw_rect(Rect2(o + Vector2(-2 + facing, -24), Vector2(1, 2)), INK)
		draw_rect(Rect2(o + Vector2(1 + facing, -24), Vector2(1, 2)), INK)
		draw_rect(Rect2(o + Vector2(-3, -21), Vector2(1, 1)), Color("7a4a2a"))  # sardinha pintada
		draw_rect(Rect2(o + Vector2(2, -21), Vector2(1, 1)), Color("7a4a2a"))
	if dama:
		draw_rect(Rect2(o + Vector2(-5, -27), Vector2(2, 6)), STRAW_DARK)        # tranças
		draw_rect(Rect2(o + Vector2(3, -27), Vector2(2, 6)), STRAW_DARK)
		draw_rect(Rect2(o + Vector2(-3, -28), Vector2(6, 2)), Color("d64545"))   # laço
	else:
		_part(Rect2(o + Vector2(-7, -27), Vector2(14, 2)), STRAW)
		_part(Rect2(o + Vector2(-4, -31), Vector2(8, 4)), STRAW)
		draw_rect(Rect2(o + Vector2(-4, -28), Vector2(8, 1)), Color("d64545"))
	if _state == "chuva":
		draw_rect(Rect2(o + Vector2(-6, -33), Vector2(12, 2)), INK)              # mão na cabeça
