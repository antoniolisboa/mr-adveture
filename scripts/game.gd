extends Node
## Estado global do jogo (autoload "Game") e configuração dos controles.

signal hud_changed
signal player_died
signal level_cleared
signal boss_hp_changed(hp: int, max_hp: int)  # hp < 0 esconde a barra
signal announce(text: String)

var character := "m"          # "m" = ele, "f" = ela
var power := ""               # poder atual ("" = nenhum; ver scripts/powers.gd)
var state_power := "pao"      # item que as caixas de poder soltam no estado atual
var music := "forro"          # música do estado atual
var completed := {}           # estados concluídos (fica salvo)
var objects := {}             # objetos do caramelo já achados, por região (fica salvo)
var save_enabled := true      # os testes automáticos desligam para não mexer no progresso
var biscoitos := 0
var total_biscoitos := 0
var checkpoint := Vector2.INF # INF = ainda não passou por nenhum cartaz
var collected := {}           # células dos biscoitos já pegos
var boss_defeated := false
var boss_name := ""
var air := 1.0                # fôlego debaixo d'água (Alagoas)
var heat := 0.0               # calor do meio-dia (Piauí)

var _saved_collected := {}

const SAVE_PATH := "user://progresso.cfg"
const States := preload("res://levels/states.gd")


func _ready() -> void:
	_setup_input()
	load_progress()


## Marca o estado como concluído. Se com ele a região ficou completa, entrega o
## objeto do caramelo e devolve a região (vazio se não ganhou nada novo).
func complete_state(state_id: String) -> Dictionary:
	completed[state_id] = true
	var region := States.region_of(state_id)
	var earned := {}
	if not region.is_empty() and not objects.has(region["id"]):
		var all_done := true
		for id in region["states"]:
			if not completed.has(id):
				all_done = false
		if all_done:
			objects[region["id"]] = true
			earned = region
	save_progress()
	return earned


func save_progress() -> void:
	if not save_enabled:
		return
	var cfg := ConfigFile.new()
	cfg.set_value("progresso", "estados", completed.keys())
	cfg.set_value("progresso", "objetos", objects.keys())
	cfg.save(SAVE_PATH)


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for id in cfg.get_value("progresso", "estados", []):
		completed[id] = true
	for id in cfg.get_value("progresso", "objetos", []):
		objects[id] = true


## Apaga o progresso salvo (mapa volta a ficar todo amarelo).
func reset_progress() -> void:
	completed.clear()
	objects.clear()
	save_progress()


## Começo de um estado.
func new_run() -> void:
	power = ""
	checkpoint = Vector2.INF
	collected = {}
	_saved_collected = {}
	boss_defeated = false
	biscoitos = 0
	heat = 0.0
	air = 1.0
	hud_changed.emit()


func collect_biscoito(cell: Vector2i) -> void:
	collected[cell] = true
	Sfx.play("biscoito")
	biscoitos = collected.size()
	hud_changed.emit()


func set_power(id: String) -> void:
	if id != "" and id != power:
		Sfx.play("powerup")
	power = id
	hud_changed.emit()


func reach_checkpoint(pos: Vector2) -> void:
	checkpoint = pos
	Sfx.play("checkpoint")
	_saved_collected = collected.duplicate()


## Começo de uma nova fase: zera checkpoint e biscoitos, mas mantém o poder.
func new_fase() -> void:
	heat = 0.0
	air = 1.0
	checkpoint = Vector2.INF
	collected = {}
	_saved_collected = {}
	boss_defeated = false
	biscoitos = 0
	hud_changed.emit()


## Volta ao último cartaz: perde o poder e os biscoitos pegos depois dele.
func restore_checkpoint() -> void:
	collected = _saved_collected.duplicate()
	biscoitos = collected.size()
	power = ""
	heat = 0.0
	air = 1.0
	hud_changed.emit()


func _setup_input() -> void:
	var keys := {
		"left": [KEY_LEFT, KEY_A],
		"right": [KEY_RIGHT, KEY_D],
		"jump": [KEY_SPACE, KEY_Z, KEY_UP, KEY_W],
		"attack": [KEY_X, KEY_J, KEY_SHIFT],
		"confirm": [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE],
		"restart": [KEY_R],
		"menu_up": [KEY_UP, KEY_W],
		"menu_down": [KEY_DOWN, KEY_S],
		"back": [KEY_ESCAPE, KEY_BACKSPACE],
	}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)

	# Controle (gamepad)
	var buttons := {
		"left": [JOY_BUTTON_DPAD_LEFT],
		"right": [JOY_BUTTON_DPAD_RIGHT],
		"jump": [JOY_BUTTON_A],
		"attack": [JOY_BUTTON_X, JOY_BUTTON_B],
		"confirm": [JOY_BUTTON_START, JOY_BUTTON_A],
		"restart": [JOY_BUTTON_BACK],
		"menu_up": [JOY_BUTTON_DPAD_UP],
		"menu_down": [JOY_BUTTON_DPAD_DOWN],
	}
	for action in buttons:
		for button in buttons[action]:
			var ev := InputEventJoypadButton.new()
			ev.button_index = button
			InputMap.action_add_event(action, ev)
	for pair in [["left", -1.0], ["right", 1.0]]:
		var ev := InputEventJoypadMotion.new()
		ev.axis = JOY_AXIS_LEFT_X
		ev.axis_value = pair[1]
		InputMap.action_add_event(pair[0], ev)
