extends SceneTree
## Tira fotos da tela de cada fase de um estado (precisa abrir janela, sem --headless).
## Uso: tools/godot.sh -s res://tests/screenshots.gd -- BA
## As imagens vão para tests/screens/ (fora do git).

const SHOTS_PER_LEVEL := 4


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await _frames(3)
	var img := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/screens"))
	img.save_png("res://tests/screens/%s.png" % name)
	print("[foto] ", name)


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var want: String = args[0] if args.size() > 0 else "BA"
	var game = root.get_node("Game")
	game.save_enabled = false   # não mexe no progresso salvo de quem joga
	var states = load("res://levels/states.gd")
	var main = load("res://scripts/main.gd").new()
	root.add_child(main)
	await _frames(10)
	await _shot("00_titulo")
	main._on_title_done("m")
	await _frames(10)
	# No mapa, seleciona o estado pedido.
	for i in main.world_map._playable.size():
		if main.world_map._playable[i]["id"] == want:
			main.world_map.selected = i
			main.world_map._refresh()
	await _shot("01_mapa")

	var data = null
	for s in states.STATES:
		if s["id"] == want:
			data = s["data"]
	for fase in data.LEVELS.size():
		if main.world_map == null:
			main._end_state()
			await _frames(2)
		main._on_state_chosen(data, fase)
		game.set_power(data.POWER)
		await _frames(30)
		var width: float = main.level.cols * 16.0
		for k in SHOTS_PER_LEVEL:
			var level = main.level
			var p = level.player
			p.set("_invuln", 0.0)
			var x := 40.0 + (width - 120.0) * k / (SHOTS_PER_LEVEL - 1)
			while _floor_y(level, x) < 0.0:   # não solta em cima de buraco
				x += 16.0
			p.global_position = Vector2(x, _floor_y(level, x))
			p.camera.reset_smoothing()
			await _frames(20)
			if k == 1:
				Input.action_press("attack")
				await _frames(4)
				Input.action_release("attack")
			await _shot("%s_%d_%d" % [want, fase + 1, k])
		# Na fase do boss: uma foto da luta.
		for c in main.level.get_children():
			if c.has_method("_start_fight"):
				await _frames(120)   # se morreu antes, espera a fase recarregar
				var level = main.level
				var arena = level.get_children().filter(func(n): return n.has_method("_start_fight"))[0]
				level.player.global_position = Vector2((arena.left_col + 4) * 16, (arena.gate_bottom_row + 1) * 16 - 1)
				for i in 200:
					if is_instance_valid(level.player):
						level.player.set("_invuln", 1.0)
					await process_frame
				await _shot("%s_%d_boss" % [want, fase + 1])
	quit()


## Altura do chão mais alto na coluna x (para o personagem não nascer dentro da parede).
func _floor_y(level, x: float) -> float:
	var col := int(x / 16.0)
	for y in level.rows.size():
		if level.is_solid(col, y):
			return y * 16.0 - 1.0
	return -1.0
