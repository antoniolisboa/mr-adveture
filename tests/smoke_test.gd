extends SceneTree
## Teste automático: abre cada fase de cada estado pronto, faz o personagem correr
## e pular por alguns segundos e, nas fases com boss, leva o personagem para a arena.
## Uso: tools/godot.sh --headless -s res://tests/smoke_test.gd
## Só alguns estados: tools/godot.sh --headless -s res://tests/smoke_test.gd -- PE PB
## Os erros de script aparecem na saída; no fim mostra um resumo.




const FRAMES_RUNNING := 600    # 10 s andando para a direita
const FRAMES_BOSS := 900       # 15 s dentro da arena

var _log: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for i in n:
		await physics_frame


func _run() -> void:
	var game = root.get_node("Game")
	game.save_enabled = false   # não mexe no progresso salvo de quem joga
	var States = load("res://levels/states.gd")
	var main = load("res://scripts/main.gd").new()
	root.add_child(main)
	await _frames(5)
	main._on_title_done("f")
	await _frames(5)

	var only := OS.get_cmdline_user_args()
	for s in States.STATES:
		if s["data"] == null:
			continue
		if only.size() > 0 and not only.has(s["id"]):
			continue
		var data = s["data"]
		for fase in data.LEVELS.size():
			# Escolhe o estado/fase como se fosse pelo mapa.
			if main.world_map == null:
				main._end_state()
				await _frames(2)
			main._on_state_chosen(data, fase)
			game.set_power(data.POWER)
			await _frames(2)
			await _play(main, "%s %d" % [s["id"], fase + 1])
	_log.append("FIM")
	for line in _log:
		print("[teste] ", line)
	quit()


func _play(main, label: String) -> void:
	var game = root.get_node("Game")
	var start_x: float = main.level.player.global_position.x
	var max_x := start_x
	var deaths := 0
	var was_dead := false
	Input.action_press("right")
	for i in FRAMES_RUNNING:
		if i % 40 == 0:
			Input.action_press("jump")
		elif i % 40 == 25:
			Input.action_release("jump")
		if i % 30 == 0:
			Input.action_press("attack")
		elif i % 30 == 2:
			Input.action_release("attack")
		await physics_frame
		# Morreu ou recarregou a fase: segue com o personagem novo.
		var p = main.level.player
		if p.dead and not was_dead:
			deaths += 1
		was_dead = p.dead
		max_x = maxf(max_x, p.global_position.x)
	Input.action_release("right")
	Input.action_release("jump")
	Input.action_release("attack")
	await _frames(100)   # espera a fase recarregar se morreu no fim
	var info := "%s: chegou até x=%d (de x=%d), morreu %d vez(es)" % [label, max_x, start_x, deaths]

	var level = null
	var arena = null
	# Leva o personagem para a arena (tenta de novo se a fase recarregar no meio).
	for attempt in 3:
		level = main.level
		arena = null
		for c in level.get_children():
			if c.has_method("_start_fight"):
				arena = c
		if arena == null:
			break
		level.player.set("_invuln", 1.0)
		level.player.global_position = Vector2((arena.left_col + 3) * 16, (arena.gate_bottom_row + 1) * 16 - 1)
		await _frames(10)
		if is_instance_valid(arena) and main.level == level:
			break
		await _frames(100)
	if arena and is_instance_valid(arena):
		var player = level.player
		var boss = arena._boss
		game.set_power(main.state_data.POWER)
		for i in FRAMES_BOSS:
			if main.level != level:
				info += "; a fase recarregou durante a luta"
				break
			# Personagem invencível para a luta não acabar; ataca e pula sem parar.
			player.set("_invuln", 1.0)
			# Corre na direção do boss.
			if is_instance_valid(boss) and not boss.dead:
				var dx: float = boss.position.x - player.position.x
				Input.action_release("left")
				Input.action_release("right")
				if absf(dx) > 14.0:
					Input.action_press("right" if dx > 0.0 else "left")
			if i % 20 == 0:
				Input.action_press("attack")
				Input.action_press("jump")
			elif i % 20 == 5:
				Input.action_release("attack")
				Input.action_release("jump")
			await physics_frame
			if OS.has_feature("debug") and OS.get_environment("TESTE_DETALHADO") != "" and i % 60 == 0 and is_instance_valid(boss):
				print("  t=%ds boss x=%d estado=%s vida=%d | jogador x=%d y=%d poder=%s" % [i / 60,
						boss.position.x, boss._state, boss.hp, player.position.x, player.position.y, game.power])
		Input.action_release("attack")
		Input.action_release("jump")
		Input.action_release("left")
		Input.action_release("right")
		var hp = boss.hp if is_instance_valid(boss) else 0
		info += "; boss %s terminou com vida %s (arena: %s)" % [game.boss_name, hp, arena._state]
	print("[teste] ", info)
	_log.append(info)
