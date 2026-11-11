extends Node2D
## Arena do boss: quando o jogador entra, fecha o portão de trás, trava a câmera
## e acorda o boss. Quando o boss cai, os portões abrem e a câmera volta ao normal.

const Art := preload("res://scripts/art.gd")
const BOSSES := {
	"trem": preload("res://scripts/boss_trem.gd"),
	"mate": preload("res://scripts/boss_mate.gd"),
	"trio": preload("res://scripts/boss_trio.gd"),
	"panela": preload("res://scripts/boss_panela.gd"),
	"coach": preload("res://scripts/boss_coach.gd"),
	"boneco": preload("res://scripts/boss_boneco.gd"),
	"quadrilha": preload("res://scripts/boss_quadrilha.gd"),
	"bugueiro": preload("res://scripts/boss_bugueiro.gd"),
	"resenha": preload("res://scripts/boss_resenha.gd"),
	"boi": preload("res://scripts/boss_boi.gd"),
	"sol": preload("res://scripts/boss_sol.gd"),
	"siri": preload("res://scripts/boss_siri.gd"),
	"caranguejo": preload("res://scripts/boss_caranguejo.gd"),
	"quati": preload("res://scripts/boss_quati.gd"),
	"bruxa": preload("res://scripts/boss_bruxa.gd"),
	"cuia": preload("res://scripts/boss_cuia.gd"),
}

const TILE := 16

var level: Node2D
var left_col := 0
var right_col := 0
var boss_pos := Vector2.ZERO
var boss_id := "trem"
var gate_top_row := 0
var gate_bottom_row := 10

var _state := "idle"            # idle -> fighting -> done
var _left_gate: CollisionShape2D
var _right_gate: CollisionShape2D
var _boss: CharacterBody2D


func _ready() -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	add_child(body)
	_left_gate = _gate_shape(left_col)
	_right_gate = _gate_shape(right_col)
	body.add_child(_left_gate)
	body.add_child(_right_gate)
	_left_gate.disabled = true

	if Game.boss_defeated:
		_state = "done"
		_right_gate.disabled = true
	else:
		_boss = BOSSES[boss_id].new()
		_boss.position = boss_pos
		_boss.arena_left = (left_col + 1) * TILE
		_boss.arena_right = right_col * TILE
		_boss.defeated.connect(_on_boss_defeated)
		level.add_child.call_deferred(_boss)
	queue_redraw()


## Portão alto (passa do topo da tela para ninguém pular por cima).
func _gate_shape(col: int) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	var top := -6 * TILE
	var bottom := (gate_bottom_row + 1) * TILE
	shape.size = Vector2(TILE, bottom - top)
	cs.shape = shape
	cs.position = Vector2(col * TILE + TILE / 2.0, (top + bottom) / 2.0)
	return cs


func _physics_process(_delta: float) -> void:
	if _state != "idle" or not level.player or level.player.dead:
		return
	if level.player.global_position.x > (left_col + 2) * TILE:
		_start_fight()


func _start_fight() -> void:
	_state = "fighting"
	_left_gate.set_deferred("disabled", false)
	var cam: Camera2D = level.player.camera
	cam.limit_left = left_col * TILE
	cam.limit_right = (right_col + 1) * TILE
	Game.boss_name = _boss.BOSS_NAME
	Game.announce.emit(_boss.ANNOUNCE)
	Music.play(Game.music + "_boss")
	_boss.start()
	queue_redraw()


func _on_boss_defeated() -> void:
	_state = "done"
	Game.boss_defeated = true
	Game.boss_hp_changed.emit(-1, 0)
	_left_gate.set_deferred("disabled", true)
	_right_gate.set_deferred("disabled", true)
	if level.player:
		var cam: Camera2D = level.player.camera
		cam.limit_left = 0
		cam.limit_right = level.player.camera_limits.end.x
	Sfx.play("clear")
	Music.stop()
	queue_redraw()
	# Depois da fanfarra, a música da fase volta.
	get_tree().create_timer(1.5).timeout.connect(_resume_music)


func _resume_music() -> void:
	var p = level.player
	if p and not p.dead and not p.frozen:
		Music.play(Game.music)


func _draw() -> void:
	if _state == "fighting":
		_draw_gate(left_col)
	if _state != "done":
		_draw_gate(right_col)


func _draw_gate(col: int) -> void:
	for row in range(gate_top_row, gate_bottom_row + 1):
		draw_texture(Art.tex("stone"), Vector2(col * TILE, row * TILE))
