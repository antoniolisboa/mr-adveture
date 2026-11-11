extends "res://scripts/boss_base.gd"
## Boss do Maranhão: o Bumba Meu Boi Gigante, de saia de veludo bordada com miçanga
## e estrela na testa. Como na história do auto do boi, ele morre... e ressuscita.
##
## Ciclo: "danca" (dança no lugar e joga matracas em arco) -> "prepara" (cava o chão)
## -> "investida" (corre até a parede) -> "tonto" (bateu a cabeça: hora de pisar).
## Com a vida zerada pela primeira vez: "O BOI MORREU!", fica deitado, e então
## "O BOI RESSUSCITOU!" volta com metade da vida, mais rápido e pulando na investida.

const BOSS_NAME := "BUMBA MEU BOI GIGANTE"
const ANNOUNCE := "ÊH, BOI! O BOI VAI DANÇAR!"

const VELVET := Color("1a1a2e")
const BEADS := [Color("f7d038"), Color("e85d75"), Color("3f8fd1"), Color("2a9d4a"), Color("ffffff")]
const SKIRT := Color("d64545")
const HORN := Color("f4f1e8")
const STAR := Color("f2c94c")
const PANTS := Color("f4f1e8")

var _revived := false
var _hops := 0


func _setup() -> void:
	max_hp = 8
	half_w = 26.0
	height = 38.0
	stomp_line = 32.0
	bubble_y = -62.0
	debris_colors = [VELVET, SKIRT, BEADS[0], BEADS[1], BEADS[2]]


func _on_start() -> void:
	_shout("MUUUU!")
	Sfx.play("muu")


func _begin() -> void:
	_start_danca()


func _start_danca() -> void:
	_state = "danca"
	_timer = 2.2 if _revived else 2.8
	_face_player()


func _can_stomp() -> bool:
	return _state == "tonto"


func _think(delta: float) -> void:
	_timer -= delta
	match _state:
		"danca":
			velocity.x = sin(_t * 4.0) * 30.0
			var every := 0.5 if _revived else 0.8
			if int(_t / every) != int((_t - delta) / every):
				var dx := clampf(_player_x() - position.x, -170.0, 170.0)
				_shot("matraca", position + Vector2(0, -40), Vector2(dx * 1.2 + _rng.randf_range(-20, 20), -260.0), 500.0)
				Sfx.play("matraca")
			if _timer <= 0.0:
				_state = "prepara"
				_timer = 0.8
				_face_player()
				_shout("ÊH, BOI!")
		"prepara":
			velocity.x = 0.0
			if _timer <= 0.0:
				_state = "investida"
				_hops = 2 if _revived else 0
				Sfx.play("muu")
		"investida":
			velocity.x = facing * (230.0 if _revived else 180.0)
			if _hops > 0 and is_on_floor() and absf(_player_x() - position.x) < 90.0:
				velocity.y = -300.0
				_hops -= 1
			if (facing < 0 and position.x <= arena_left + half_w + 1.0) or \
					(facing > 0 and position.x >= arena_right - half_w - 1.0):
				Sfx.play("slam")
				_state = "tonto"
				_timer = 1.6 if _revived else 2.2
				_shout("ÔXE... VI ESTRELA!")
		"tonto":
			velocity.x = 0.0
			if _timer <= 0.0:
				_start_danca()
		"morto":
			velocity.x = 0.0
			if _timer <= 0.0:
				_revived = true
				hp = max_hp / 2
				Game.boss_hp_changed.emit(hp, max_hp)
				_shout("O BOI RESSUSCITOU!!", 1.8)
				Sfx.play("powerup")
				_start_danca()


func _on_hurt() -> void:
	_shout(_pick(["MUUU!", "AI, MEU BORDADO!", "ARRE ÉGUA!"]))
	if _state == "tonto":
		_timer = minf(_timer, 0.3)


func _on_zero_hp() -> void:
	if not _revived:
		_state = "morto"
		_timer = 2.6
		_invuln = 3.0
		_shout("O BOI MORREU!", 2.0)
		Sfx.play("die")
		return
	_shout("O BOI DANÇOU... DE VERDADE!", 2.0)
	_break_apart()


func _draw_body() -> void:
	var f := float(facing)
	var lying := _state == "morto"
	var bob := 0.0
	if _state == "danca":
		bob = -2.0 if int(_t * 6.0) % 2 == 0 else 0.0
	if lying:
		draw_set_transform(Vector2(0, -2), f * 0.25, Vector2.ONE)
	# Pernas do brincante por baixo da saia.
	if not lying:
		var step := 2.0 if _state in ["investida", "danca"] and int(_t * 10.0) % 2 == 0 else 0.0
		_part(Rect2(-12, -9 - step, 5, 9 + step), PANTS)
		_part(Rect2(7, -9 + step - 2.0, 5, 9 - step + 2.0), PANTS)
	# Saia vermelha franjada
	_part(Rect2(Vector2(-27, -16 + bob), Vector2(54, 8)), SKIRT)
	for k in 9:
		draw_rect(Rect2(-26 + k * 6, -8 + bob, 3, 2), BEADS[k % BEADS.size()])
	# Corpo de veludo preto bordado
	_part(Rect2(Vector2(-25, -34 + bob), Vector2(50, 19)), VELVET)
	for k in 12:
		var px := -22 + (k % 6) * 8 + (k / 6) * 4
		var py := -30 + (k / 6) * 8
		draw_rect(Rect2(Vector2(px, py + bob), Vector2(2, 2)), BEADS[k % BEADS.size()])
	draw_colored_polygon(PackedVector2Array([Vector2(-6, -28 + bob), Vector2(0, -32 + bob),
			Vector2(6, -28 + bob), Vector2(0, -22 + bob)]), BEADS[1])     # coração bordado
	# Cabeça na frente, com chifres e a estrela
	var h := Vector2(f * 26, -34 + bob)
	_part(Rect2(h + Vector2(-8, -4), Vector2(16, 14)), VELVET)
	_part(Rect2(h + Vector2(f * 4 - 3, 4), Vector2(7, 5)), Color("3a2a3e"))   # focinho
	draw_rect(Rect2(h + Vector2(f * 5 - 1, 6), Vector2(1, 1)), INK)
	_part(Rect2(h + Vector2(-11, -8), Vector2(5, 3)), HORN)
	_part(Rect2(h + Vector2(6, -8), Vector2(5, 3)), HORN)
	_part(Rect2(h + Vector2(-12, -12), Vector2(2, 4)), HORN)
	_part(Rect2(h + Vector2(10, -12), Vector2(2, 4)), HORN)
	draw_rect(Rect2(h + Vector2(-2, -2), Vector2(4, 4)), STAR)
	draw_rect(Rect2(h + Vector2(-1, -3), Vector2(2, 6)), STAR)
	if _state in ["tonto", "morto"]:
		for x: float in [-5.0, 2.0]:
			draw_rect(Rect2(h + Vector2(x, 2), Vector2(3, 1)), Color.WHITE)
			draw_rect(Rect2(h + Vector2(x + 1, 1), Vector2(1, 3)), Color.WHITE)
	else:
		draw_rect(Rect2(h + Vector2(f * 3 - 1, 1), Vector2(2, 2)), Color.WHITE)
	# Fitas coloridas na cabeça balançando
	for k in 4:
		var sway := sin(_t * 5.0 + k) * 2.0
		draw_rect(Rect2(h + Vector2(-f * 2 - f * k * 2 + sway, -6), Vector2(1, 10 + k * 2)), BEADS[k])
	if _state == "tonto":
		for k in 3:
			var a := _t * 4.0 + k * TAU / 3.0
			draw_rect(Rect2(h + Vector2(cos(a) * 9.0 - 1, -16 + sin(a) * 3.0), Vector2(3, 3)), STAR)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
