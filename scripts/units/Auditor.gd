class_name Auditor
extends CharacterBody2D

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

var hp: float = 25.0
var max_hp: float = 25.0
var move_speed: float = 110.0
var attack_damage: float = 3.0
var attack_range: float = 96.0
var attack_cooldown: float = 0.8
var faction_id: String = ""
var is_neutral: bool = false

var registry: Node = null
var economy: Node = null
var game_manager: Node = null
# CharacterBody2D already exposes `velocity`

var _cooldown: float = 0.0
var _move_target: Vector2 = Vector2.ZERO
var _has_move_target: bool = false
var _forced_target: Node = null

func configure(registry_ref: Node, economy_ref: Node, manager: Node) -> void:
	registry = registry_ref
	economy = economy_ref
	game_manager = manager

func set_move_target(target: Vector2) -> void:
	_move_target = target
	_has_move_target = true

func set_forced_target(target: Node) -> void:
	_forced_target = target

func trigger_attack() -> void:
	var target = _select_target()
	if target:
		_attack(target)

func _physics_process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if hp <= 0.0:
		return
	_move(delta)
	var target = _select_target()
	if target and _is_in_range(target.global_position):
		_attack(target)
	move_and_slide()

func take_damage(amount: float, source_faction: String = "") -> void:
	hp -= amount
	if hp <= 0.0:
		_die(source_faction)

func _move(delta: float) -> void:
	if not _has_move_target:
		velocity = Vector2.ZERO
		return
	var dir = (_move_target - global_position).normalized()
	velocity = dir * move_speed
	if global_position.distance_to(_move_target) < 6.0:
		_has_move_target = false

func _select_target() -> Node:
	if _forced_target and is_instance_valid(_forced_target):
		return _forced_target
	if registry:
		var nearby = registry.get_units_near_position(faction_id, global_position, attack_range)
		if not nearby.is_empty():
			return nearby.front()
	if game_manager and game_manager.has_method("get_primary_enemy_hq"):
		var hq = game_manager.get_primary_enemy_hq(faction_id)
		if hq and _is_in_range(hq.global_position):
			return hq
	return null

func _is_in_range(pos: Vector2) -> bool:
	return global_position.distance_to(pos) <= attack_range

func _attack(target: Node) -> void:
	if _cooldown > 0.0:
		return
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage, faction_id)
	_cooldown = attack_cooldown

func _die(source_faction: String) -> void:
	if registry:
		registry.unregister_unit(self)
	if economy and source_faction != "" and source_faction != faction_id:
		economy.add_credits(source_faction, BalanceConfig.KILL_REWARD_UNIT)
	queue_free()
