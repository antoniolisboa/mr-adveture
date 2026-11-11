extends SceneTree
## Carrega todos os scripts do jogo para achar erros de compilação rápido.
## Uso: tools/godot.sh --headless -s res://tests/load_all.gd


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var bad := 0
	for dir in ["res://scripts", "res://levels"]:
		for f in DirAccess.get_files_at(dir):
			if f.ends_with(".gd"):
				var sc = load(dir + "/" + f)
				if sc == null or not sc.can_instantiate():
					print("[load] ERRO: ", f)
					bad += 1
	print("[load] fim, %d com erro" % bad)
	quit()
