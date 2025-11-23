class_name NeutralMob
extends CharacterBody2D

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

var hp: float = 8.0
var max_hp: float = 8.0
var move_speed: float = 70.0
var attack_damage: float = 1.5
var attack_range: float = 56.0
var attack_cooldown: float = 1.0
var faction_id: String = ""
var is_neutral: bool = true

var registry: Node = null
var economy: Node = null

var _cooldown: float = 0.0
var _home_position: Vector2

func configure(registry_ref: Node, economy_ref: Node) -> void:
	registry = registry_ref
	economy = economy_ref

func _ready() -> void:
	_home_position = global_position

func _process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if hp <= 0.0:
		return
	var target = _find_target()
	if target:
		_move_toward(target.global_position, delta)
		if _is_in_range(target.global_position):
			_attack(target)
	else:
		_roam(delta)

func take_damage(amount: float, source_faction: String = "") -> void:
	hp -= amount
	if hp <= 0.0:
		_die(source_faction)

func _find_target() -> Node:
	if registry:
		var nearby = registry.get_units_near_position(faction_id, global_position, attack_range + 40.0)
		if not nearby.is_empty():
			return nearby.front()
	return null

func _is_in_range(pos: Vector2) -> bool:
	return global_position.distance_to(pos) <= attack_range

func _attack(target: Node) -> void:
	if _cooldown > 0.0:
		return
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage, faction_id)
	_cooldown = attack_cooldown

func _move_toward(pos: Vector2, delta: float) -> void:
	global_position = global_position.move_toward(pos, move_speed * delta)

func _roam(delta: float) -> void:
	var offset = Vector2(randf() - 0.5, randf() - 0.5) * 20.0
	var target = _home_position + offset
	_move_toward(target, delta)

func _die(source_faction: String) -> void:
	if registry:
		registry.unregister_unit(self)
	if economy and source_faction != "" and source_faction != faction_id:
		economy.add_credits(source_faction, BalanceConfig.KILL_REWARD_ACCENTURE_MOB)
	queue_free()
