extends SceneTree
## Confere a entrega do objeto da região: completa todos os estados da região menos o
## último e termina a fase final dele, como se fosse jogando.
## Uso: tools/godot.sh --display-driver wayland -s res://tests/region_test.gd -- NE
## (sem nada = Sudeste). Fotos em tests/screens/regiao_<id>_msg.png e _mapa.png.


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var region_id: String = args[0] if args.size() > 0 else "SE"
	var game = root.get_node("Game")
	game.save_enabled = false
	game.completed.clear()
	game.objects.clear()
	var States = load("res://levels/states.gd")
	var region := {}
	for r in States.REGIONS:
		if r["id"] == region_id:
			region = r
	var ids: Array = region["states"]
	var main = load("res://scripts/main.gd").new()
	root.add_child(main)
	await _frames(5)
	main._on_title_done("f")
	await _frames(5)
	for id in ids.slice(0, ids.size() - 1):
		print("[regiao] ", id, " -> ", game.complete_state(id).get("object", "nada"))
	var data = null
	for s in States.STATES:
		if s["id"] == ids[-1]:
			data = s["data"]
	main._on_state_chosen(data, data.LEVELS.size() - 1)
	await _frames(20)
	game.level_cleared.emit()
	await _frames(40)
	print("[regiao] ", ids[-1], " (último) -> objetos: ", game.objects.keys())
	var img := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/screens"))
	img.save_png("res://tests/screens/regiao_%s_msg.png" % region_id)
	Input.action_press("confirm")
	await _frames(3)
	Input.action_release("confirm")
	await _frames(30)
	img = root.get_texture().get_image()
	img.save_png("res://tests/screens/regiao_%s_mapa.png" % region_id)
	quit()
