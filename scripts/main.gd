extends Node
## Cena principal: menu -> mapa do Brasil -> fases do estado -> mapa.
## Também cuida de morte, checkpoint e da passagem entre fases.

const Title := preload("res://scripts/title.gd")
const WorldMap := preload("res://scripts/world_map.gd")
const Level := preload("res://scripts/level.gd")
const Hud := preload("res://scripts/hud.gd")

enum State { TITLE, MAP, PLAYING, CLEARED }

var state := State.TITLE
var state_data            # estado sendo jogado (ex.: levels/minas_gerais.gd)
var fase := 0
var title: Node2D
var world_map: Node2D
var level: Node2D
var hud: CanvasLayer
var _reloading := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("8fd3ff"))
	Game.player_died.connect(_on_player_died)
	Game.level_cleared.connect(_on_level_cleared)
	_show_title()


func _process(_delta: float) -> void:
	match state:
		State.PLAYING:
			if Input.is_action_just_pressed("restart"):
				_respawn()
			elif Input.is_action_just_pressed("back"):
				_end_state()
		State.CLEARED:
			if Input.is_action_just_pressed("confirm"):
				if _is_last_fase():
					_end_state()
				else:
					_next_fase()


func _is_last_fase() -> bool:
	return fase >= state_data.LEVELS.size() - 1


func _show_title() -> void:
	state = State.TITLE
	Music.play("forro")
	title = Title.new()
	title.started.connect(_on_title_done)
	add_child(title)


func _on_title_done(character: String) -> void:
	title.queue_free()
	title = null
	Game.character = character
	_show_map()


func _show_map() -> void:
	state = State.MAP
	Music.play("forro")
	world_map = WorldMap.new()
	world_map.chosen.connect(_on_state_chosen)
	world_map.back.connect(_on_map_back)
	add_child(world_map)


func _on_map_back() -> void:
	world_map.queue_free()
	world_map = null
	_show_title()


func _on_state_chosen(data, start_fase: int) -> void:
	world_map.queue_free()
	world_map = null
	state_data = data
	fase = start_fase
	Game.state_power = data.POWER
	Game.music = data.MUSIC
	Game.new_run()
	hud = Hud.new()
	add_child(hud)
	_start_fase()


func _next_fase() -> void:
	fase += 1
	Game.new_fase()
	hud.hide_message()
	_start_fase()


func _start_fase() -> void:
	_load_level()
	state = State.PLAYING
	hud.show_banner("%s %d-%d\n%s" % [state_data.NAME, fase + 1, state_data.LEVELS.size(),
			state_data.LEVELS[fase].NAME])


func _load_level() -> void:
	if level:
		level.queue_free()
	level = Level.new()
	add_child(level)
	level.build(state_data.LEVELS[fase])
	Music.play(Game.music)
	Game.total_biscoitos = level.total_biscoitos
	hud.refresh()
	hud.show_boss(-1, 0)


func _respawn() -> void:
	Game.restore_checkpoint()
	_load_level()


func _on_player_died() -> void:
	if _reloading:
		return
	_reloading = true
	Music.stop()
	await get_tree().create_timer(1.5).timeout
	_reloading = false
	if state == State.PLAYING:
		_respawn()


func _on_level_cleared() -> void:
	state = State.CLEARED
	Music.stop()
	var score := "BISCOITOS: %d DE %d" % [Game.biscoitos, Game.total_biscoitos]
	if _is_last_fase():
		var earned: Dictionary = Game.complete_state(state_data.ID)
		var extra := ""
		if not earned.is_empty():
			# Região completa: o caramelo deixou um objeto para trás.
			extra = "\n\nREGIÃO %s COMPLETA!\nVOCÊ ACHOU: %s DO CARAMELO!" % [earned["name"], earned["object"]]
			hud.show_object(earned["sprite"])
			get_tree().create_timer(0.8).timeout.connect(func(): Sfx.play("powerup"))
		hud.show_message("%s%s\n\n%s\n\nENTER: VOLTAR AO MAPA" % [state_data.FINAL_MESSAGE, extra, score])
	else:
		hud.show_message("FASE CONCLUÍDA!\n\n%s\n\n%s\n\nENTER: PRÓXIMA FASE" % [
				state_data.LEVELS[fase].CLUE, score])


## Sai do estado (concluído ou abandonado com ESC) e volta ao mapa.
func _end_state() -> void:
	level.queue_free()
	level = null
	hud.queue_free()
	hud = null
	_show_map()
