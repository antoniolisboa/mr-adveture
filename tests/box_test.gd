extends SceneTree
## Teste das caixas de poder: bate em cada caixa de cada fase, espera o item
## cair e confere se ele parou no chão (alcançável) e se o personagem pega.
## Uso: tools/godot.sh --headless -s res://tests/box_test.gd


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
		if s["data"] == null or (only.size() > 0 and not only.has(s["id"])):
			continue
		var data = s["data"]
		for fase in data.LEVELS.size():
			if main.world_map == null:
				main._end_state()
				await _frames(2)
			main._on_state_chosen(data, fase)
			await _frames(2)
			var level = main.level
			var boxes = level.get_children().filter(func(n): return n.get_script() != null and n.get_script().resource_path.ends_with("power_box.gd"))
			for box in boxes:
				if main.level != level or not is_instance_valid(box):
					_log.append("%s %d: a fase recarregou no meio, pulando o resto" % [s["id"], fase + 1])
					break
				game.set_power("")
				var p = level.player
				for c in level.get_children():
					if c.has_method("stomp") and c != p:
						c.queue_free()      # sem inimigos atrapalhando o teste
				p.set("_invuln", 99.0)
				p.global_position = box.global_position + Vector2(8, 60)
				await _frames(2)
				box.bump()
				await _frames(240)
				if main.level != level or not is_instance_valid(box):
					_log.append("%s %d: a fase recarregou no meio (personagem caiu), pulando" % [s["id"], fase + 1])
					break
				if main.level != level:
					_log.append("%s %d: a fase recarregou no meio, pulando o resto" % [s["id"], fase + 1])
					break
				var items = level.get_children().filter(func(n): return n.get_script() != null and n.get_script().resource_path.ends_with("pickup.gd") and n.kind == "power")
				var label := "%s %d caixa col %d" % [s["id"], fase + 1, int(box.position.x / 16)]
				if items.is_empty():
					_log.append("%s: ITEM SUMIU (caiu no buraco?)" % label)
					continue
				var it = items[0]
				var col := int(it.global_position.x / 16)
				var row := int(it.global_position.y / 16)
				var floor_ok: bool = level.is_solid(col, row + 1)
				p.global_position = Vector2(it.global_position.x, (row + 1) * 16 - 1)
				p.velocity = Vector2.ZERO
				await _frames(10)
				var got: bool = game.power == data.POWER
				_log.append("%s: item parou em col %d linha %d, chão embaixo=%s, pegou=%s" % [label, col, row, floor_ok, got])
				if is_instance_valid(it):
					it.queue_free()
	for line in _log:
		print("[caixa] ", line)
	quit()
