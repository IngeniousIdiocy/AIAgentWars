class_name Analyst
extends CharacterBody2D

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

var hp: float = 10.0
var max_hp: float = 10.0
var move_speed: float = 80.0
var attack_damage: float = 1.0
var attack_range: float = 64.0
var attack_cooldown: float = 1.2
var faction_id: String = ""
var is_neutral: bool = false
var target_faction_id: String = ""

var _cooldown: float = 0.0
var _path: Array[Vector2] = []
var _path_index: int = 0
# CharacterBody2D already exposes `velocity`

var registry: Node = null
var economy: Node = null
var game_manager: Node = null
var _override_target: Node = null

func configure(registry_ref: Node, economy_ref: Node, manager: Node) -> void:
	registry = registry_ref
	economy = economy_ref
	game_manager = manager

func _physics_process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if hp <= 0.0:
		return
	var target = _choose_target()
	if target and _is_in_range(target.global_position):
		_try_attack(target)
	else:
		_follow_path(delta)
	move_and_slide()

func take_damage(amount: float, source_faction: String = "") -> void:
	hp -= amount
	if hp <= 0.0:
		_die(source_faction)

func set_path(points: Array[Vector2]) -> void:
	_path = points.duplicate()
	_path_index = 0

func _choose_target() -> Node:
	if _override_target and is_instance_valid(_override_target):
		return _override_target
	if registry:
		var nearby = registry.get_units_near_position(faction_id, global_position, attack_range)
		if not nearby.is_empty():
			return nearby.front()
	if game_manager and game_manager.has_method("get_hq_for_faction") and target_faction_id != "":
		var hq = game_manager.get_hq_for_faction(target_faction_id)
		if hq and _is_in_range(hq.global_position):
			return hq
	return null

func _is_in_range(target_pos: Vector2) -> bool:
	return global_position.distance_to(target_pos) <= attack_range

func _try_attack(target: Node) -> void:
	if _cooldown > 0.0:
		return
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage, faction_id)
	_cooldown = attack_cooldown

func _follow_path(delta: float) -> void:
	if _path_index >= _path.size():
		velocity = Vector2.ZERO
		return
	var point: Vector2 = _path[_path_index]
	var dir = (point - global_position).normalized()
	velocity = dir * move_speed
	if global_position.distance_to(point) < 8.0:
		_path_index += 1
		if _path_index >= _path.size() and game_manager and game_manager.has_method("get_hq_for_faction"):
			var hq = game_manager.get_hq_for_faction(target_faction_id)
			_override_target = hq

func _die(source_faction: String) -> void:
	if registry:
		registry.unregister_unit(self)
	if economy and source_faction != "" and source_faction != faction_id:
		economy.add_credits(source_faction, BalanceConfig.KILL_REWARD_UNIT)
	queue_free()
