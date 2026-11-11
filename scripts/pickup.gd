extends Area2D
## Item coletável: biscoito de polvilho (contador) ou item de poder do estado.
## A origem fica no centro do item.

const Art := preload("res://scripts/art.gd")
const Powers := preload("res://scripts/powers.gd")

var kind := "biscoito"      # "biscoito" ou "power"
var power_id := ""          # com kind = "power": qual poder (scripts/powers.gd)
var cell := Vector2i.ZERO   # posição no mapa (para não reaparecer depois do checkpoint)
var rising := false         # true quando sai de uma caixa
var dir := 1                # para que lado ele escorrega depois de sair da caixa

const GRAVITY := 600.0
const SLIDE_SPEED := 55.0
const RADIUS := 6.0

var _t := 0.0
var _sprite: Sprite2D
var _moving := false        # escorregando/caindo depois de sair da caixa
var _velocity := Vector2.ZERO
var _fell := 0.0            # quanto já caiu (ao cair de uma beirada e pousar, para)


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	cs.shape = circle
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.texture = Art.tex(Powers.POWERS[power_id]["item"] if kind == "power" else kind)
	add_child(_sprite)
	body_entered.connect(_on_body_entered)

	if rising:
		# Sobe de dentro da caixa antes de poder ser pego.
		monitoring = false
		z_index = -1
		var tw := create_tween()
		tw.tween_property(self, "position:y", position.y - 16.0, 0.4)
		tw.tween_callback(_finish_rise)


func _finish_rise() -> void:
	z_index = 0
	set_deferred("monitoring", true)
	# A caixa fica alta demais para alcançar o topo pulando: o item escorrega
	# para o lado, cai da plataforma e para no chão, onde dá para pegar.
	_moving = true
	_velocity = Vector2(dir * SLIDE_SPEED, 0.0)


func _physics_process(delta: float) -> void:
	if not _moving:
		return
	var space := get_world_2d().direct_space_state
	# Horizontal: bateu na parede, volta.
	if _velocity.x != 0.0:
		var step := _velocity.x * delta
		var from := global_position
		var to := from + Vector2(signf(step) * RADIUS + step, 0.0)
		var hit := space.intersect_ray(PhysicsRayQueryParameters2D.create(from, to, 1))
		if hit.is_empty():
			global_position.x += step
		else:
			dir = -dir
			_velocity.x = -_velocity.x
	# Vertical: gravidade e pouso.
	_velocity.y = minf(_velocity.y + GRAVITY * delta, 300.0)
	var dy := _velocity.y * delta
	var from_v := global_position
	var hit_v := space.intersect_ray(PhysicsRayQueryParameters2D.create(
			from_v, from_v + Vector2(0.0, RADIUS + dy + 1.0), 1))
	if hit_v.is_empty():
		global_position.y += dy
		_fell += dy
	else:
		global_position.y = hit_v["position"].y - RADIUS
		_velocity.y = 0.0
		if _fell > 12.0:      # caiu de uma beirada e pousou: fica ali
			_moving = false
		_fell = 0.0
	if global_position.y > 2000.0:
		queue_free()


func _process(delta: float) -> void:
	_t += delta
	_sprite.position.y = roundf(sin(_t * 4.0) * 1.5)


func _on_body_entered(body: Node) -> void:
	if not body.has_method("hurt") or body.dead:
		return
	if kind == "biscoito":
		Game.collect_biscoito(cell)
	else:
		Game.set_power(power_id)
	queue_free()
