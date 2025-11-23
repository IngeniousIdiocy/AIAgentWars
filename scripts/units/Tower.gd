class_name Tower
extends Node2D

signal tower_destroyed(faction_id: String, tower: Node)

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")
const TOWER_TEXTURE = preload("res://assets/game/tiles/towerDefense_001_0.png")

var faction_id: String = ""
var level: int = 1
var attack_range: float = 140.0
var attack_cooldown: float = 1.4
var attack_damage: float = 4.0
var hp: float = 40.0
var max_hp: float = 40.0
var _cooldown: float = 0.0

var registry: Node = null
var economy: Node = null
@export var projectile_scene: PackedScene
@onready var sprite: Sprite2D = get_node_or_null("Sprite")

func configure(registry_ref: Node, projectile_scene_ref: PackedScene, economy_ref: Node = null) -> void:
	registry = registry_ref
	projectile_scene = projectile_scene_ref
	economy = economy_ref

func _ready() -> void:
	_cooldown = attack_cooldown
	_ensure_visual()

func _process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if _cooldown > 0.0:
		return
	var target = _find_target()
	if target:
		_fire(target)

func upgrade() -> void:
	level = clamp(level + 1, 1, 3)
	attack_damage += 2.0
	attack_range += 12.0
	attack_cooldown = max(0.6, attack_cooldown - 0.15)
	max_hp += 10.0
	hp = max_hp

func _find_target() -> Node:
	if registry:
		var nearby = registry.get_units_near_position(faction_id, global_position, attack_range)
		if not nearby.is_empty():
			return nearby.front()
	return null

func _fire(target: Node) -> void:
	if not projectile_scene:
		return
	var projectile: Node2D = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.faction_id = faction_id
	projectile.damage = attack_damage
	if projectile.has_method("set_target"):
		projectile.set_target(target)
	var parent = get_tree().current_scene if get_tree() and get_tree().current_scene else get_parent()
	parent.add_child(projectile)
	_cooldown = attack_cooldown

func take_damage(amount: float, source_faction: String = "") -> void:
	hp -= amount
	if hp <= 0.0:
		_die(source_faction)

func _die(source_faction: String) -> void:
	if registry:
		registry.unregister_unit(self)
	if economy and source_faction != "" and source_faction != faction_id:
		economy.add_credits(source_faction, BalanceConfig.KILL_REWARD_TOWER)
	tower_destroyed.emit(faction_id, self)
	queue_free()

func set_faction_color(color: Color) -> void:
	if sprite:
		sprite.modulate = color

func _ensure_visual() -> void:
	if sprite:
		return
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = TOWER_TEXTURE
	sprite.centered = true
	sprite.scale = Vector2(0.75, 0.75)
	sprite.position = Vector2(0, -8)
	add_child(sprite)
