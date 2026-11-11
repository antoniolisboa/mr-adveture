extends SceneTree
## Testa os poderes do Nordeste, um por um, numa fase de verdade de cada estado.
## Uso: tools/godot.sh --headless -s res://tests/powers_test.gd

var _results: Array[String] = []
var main
var game


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for i in n:
		await physics_frame


func _check(name: String, ok: bool, info := "") -> void:
	var line := "%s %s %s" % ["OK  " if ok else "FALHOU", name, info]
	print("[poder] ", line)
	_results.append(line)


func _open(state_id: String, fase: int) -> Node:
	var States = load("res://levels/states.gd")
	for s in States.STATES:
		if s["id"] == state_id:
			if main.world_map == null:
				main._end_state()
				await _frames(2)
			main._on_state_chosen(s["data"], fase)
			game.set_power(s["data"].POWER)
			await _frames(3)
	return main.level


func _press(action: String, frames := 2) -> void:
	Input.action_press(action)
	await _frames(frames)
	Input.action_release(action)


## Põe um inimigo de teste do lado do jogador.
func _enemy(level, script_path: String, offset: Vector2) -> Node:
	var e = load(script_path).new()
	e.position = level.player.global_position + offset
	level.add_child(e)
	return e


func _run() -> void:
	game = root.get_node("Game")
	game.save_enabled = false
	main = load("res://scripts/main.gd").new()
	root.add_child(main)
	await _frames(3)
	main._on_title_done("m")
	await _frames(3)

	# Sombrinha: segurando X no ar cai devagar.
	var level = await _open("PE", 0)
	var p = level.player
	p.global_position.y -= 60.0
	Input.action_press("attack")
	await _frames(40)
	var vy: float = p.velocity.y
	Input.action_release("attack")
	_check("sombrinha plana", vy > 0.0 and vy <= 41.0, "(queda %.0f)" % vy)

	# Sanfona: o giro derruba inimigos dos dois lados.
	level = await _open("PB", 0)
	p = level.player
	var e1 = _enemy(level, "res://scripts/caranguejo.gd", Vector2(-16, 0))
	var e2 = _enemy(level, "res://scripts/caranguejo.gd", Vector2(16, 0))
	await _frames(2)
	await _press("attack")
	await _frames(20)
	_check("sanfona gira", e1.dead and e2.dead)

	# Buggy: corre mais e "com emoção" pula muito alto.
	level = await _open("RN", 0)
	p = level.player
	await _frames(20)
	var y0: float = p.global_position.y
	await _press("attack")
	var top := y0
	for i in 60:
		await physics_frame
		top = minf(top, p.global_position.y)
	await _frames(30)
	Input.action_press("right")
	await _frames(40)
	var vx: float = p.velocity.x
	Input.action_release("right")
	_check("buggy corre e pula com emoção", vx > 140.0 and y0 - top > 90.0, "(vel %.0f, pulo %.0f px)" % [vx, y0 - top])

	# Microfone: a piada deixa o inimigo rindo (inofensivo).
	level = await _open("CE", 0)
	p = level.player
	p.facing = 1
	var e3 = _enemy(level, "res://scripts/caranguejo.gd", Vector2(50, 0))
	e3.set("_active", true)
	await _frames(2)
	await _press("attack")
	await _frames(30)
	_check("microfone faz rir", e3.harmless())
	# E a piada do piadista faz o jogador rir parado.
	p.laugh(1.0)
	_check("jogador ri parado", p.get("_stun") > 0.0)

	# Disco de reggae: pulo mais alto e o disco volta.
	level = await _open("MA", 0)
	p = level.player
	await _frames(20)
	y0 = p.global_position.y
	Input.action_press("jump")
	top = y0
	for i in 90:
		await physics_frame
		top = minf(top, p.global_position.y)
	Input.action_release("jump")
	_check("reggae pula alto", y0 - top > 70.0, "(pulo %.0f px)" % (y0 - top))
	await _frames(60)
	await _press("attack")
	await _frames(5)
	var discs := root.get_tree().get_nodes_in_group("player_shots").size()
	await _frames(150)
	var after := root.get_tree().get_nodes_in_group("player_shots").size()
	_check("disco vai e volta", discs == 1 and after == 0)

	# Leque: desmancha a onda de calor; o calor sobe no sol e baixa abanando.
	level = await _open("PI", 0)
	p = level.player
	p.facing = 1
	var onda = _enemy(level, "res://scripts/onda_calor.gd", Vector2(18, -6))
	await _frames(2)
	await _press("attack")
	await _frames(10)
	_check("leque desmancha onda de calor", onda.dead)
	game.heat = 0.5
	await _press("attack")
	_check("leque refresca", game.heat < 0.3, "(calor %.2f)" % game.heat)

	# Água: sem snorkel o fôlego acaba; com snorkel não.
	level = await _open("AL", 0)
	p = level.player
	for c in level.get_children():
		if c.has_method("stomp"):
			c.queue_free()                               # tira ouriços e baiacus
	p.global_position = Vector2(48 * 16, 12 * 16)      # fundo de uma piscina
	game.set_power("")
	await _frames(120)
	var air_without: float = game.air
	game.set_power("snorkel")
	game.air = 1.0
	await _frames(120)
	_check("fôlego acaba sem snorkel", air_without < 0.9, "(fôlego %.2f)" % air_without)
	_check("snorkel não perde fôlego", game.air > 0.99)

	# Pinça: agarra o caranguejo e arremessa no outro.
	level = await _open("SE", 0)
	p = level.player
	p.facing = 1
	var c1 = _enemy(level, "res://scripts/caranguejo.gd", Vector2(14, 0))
	var c2 = _enemy(level, "res://scripts/caranguejo.gd", Vector2(90, 0))
	c2.set("speed", 0.0)
	await _frames(3)
	await _press("attack")
	await _frames(3)
	var held = p.get("_held_tex") != null
	_check("pinça agarra", held and not is_instance_valid(c1) or (is_instance_valid(c1) and c1.dead))
	await _frames(10)
	await _press("attack")
	await _frames(40)
	_check("pinça arremessa", not is_instance_valid(c2) or c2.dead)

	print("")
	for r in _results:
		print("[poder] ", r)
	quit()
