extends SceneTree
## Teste dos bosses: abre a última fase de cada estado, começa a luta e "pisa" no boss
## sempre que ele fica vulnerável (_can_stomp), como um jogador que só acerta na hora
## certa. Mostra quanto tempo cada luta levou (ou se travou).
## Uso: tools/godot.sh --headless -s res://tests/boss_test.gd -- PE PB
## (sem estados = todos os que têm boss com _can_stomp, os do Nordeste)

const LIMIT := 90.0     # segundos


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game = root.get_node("Game")
	game.save_enabled = false
	var States = load("res://levels/states.gd")
	var main = load("res://scripts/main.gd").new()
	root.add_child(main)
	await process_frame
	main._on_title_done("m")
	await process_frame
	var only := OS.get_cmdline_user_args()
	var results: Array[String] = []
	for s in States.STATES:
		var data = s["data"]
		if data == null or (only.size() > 0 and not only.has(s["id"])):
			continue
		if main.world_map == null:
			main._end_state()
			await process_frame
		main._on_state_chosen(data, data.LEVELS.size() - 1)
		await physics_frame
		var level = main.level
		var arena = null
		for c in level.get_children():
			if c.has_method("_start_fight"):
				arena = c
		await physics_frame
		var boss = arena._boss
		if not boss.has_method("_can_stomp"):
			continue
		# Deixa o jogador longe, invencível, e começa a luta.
		level.player.global_position = Vector2((arena.left_col + 2) * 16 + 8, (arena.gate_bottom_row + 1) * 16 - 1)
		arena._start_fight()
		var t := 0.0
		var stomps := 0
		var states_seen := {}
		while t < LIMIT and is_instance_valid(boss) and not boss.dead:
			level.player.set("_invuln", 1.0)
			states_seen[boss._state] = true
			if boss._can_stomp() and boss._invuln <= 0.0:
				boss.stomp()
				stomps += 1
			await physics_frame
			t += 1.0 / 60.0
		var ok: bool = not is_instance_valid(boss) or boss.dead
		var line := "%s: %s em %.1f s, %d pisões, estados: %s" % [s["id"],
				"DERROTADO" if ok else "NÃO CAIU", t, stomps, ", ".join(states_seen.keys())]
		print("[boss] ", line)
		results.append(line)
		await _wait(120)
	for r in results:
		print("[boss] ", r)
	quit()


func _wait(n: int) -> void:
	for i in n:
		await physics_frame
