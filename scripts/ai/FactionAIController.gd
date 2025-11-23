class_name FactionAIController
extends Node

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

var game_manager: Node = null
var faction_registry: Node = null
var economy: Node = null
var world: Node = null

var _action_timer: float = 0.0
var _spawn_cooldowns: Dictionary = {}
const ANALYST_SPAWN_INTERVAL := 3.0
const MAX_ANALYSTS := 12

func configure(manager: Node, registry: Node, economy_system: Node, world_controller: Node) -> void:
	game_manager = manager
	faction_registry = registry
	economy = economy_system
	world = world_controller

func process_ai(delta: float) -> void:
	_action_timer += delta
	if _action_timer < 1.0:
		return
	_action_timer = 0.0
	if not faction_registry or not economy:
		return
	for key in _spawn_cooldowns.keys():
		_spawn_cooldowns[key] = max(_spawn_cooldowns[key] - 1.0, 0.0)
	for state in faction_registry.get_big4_factions():
		if state.is_player or state.hq == null:
			continue
		var target_id = _choose_target_for(state.id)
		state.target_faction_id = target_id
		var roll = randf()
		var analyst_cd = _spawn_cooldowns.get(state.id, 0.0)
		var active_analysts = _count_units(state.id, "analyst")
		if analyst_cd <= 0.0 and active_analysts < MAX_ANALYSTS and economy.can_afford(state.id, BalanceConfig.COST_ANALYST_BATCH):
			if economy.spend_credits(state.id, BalanceConfig.COST_ANALYST_BATCH):
				request_spawn_analysts(state.id, target_id, BalanceConfig.ANALYSTS_PER_BATCH)
				_spawn_cooldowns[state.id] = ANALYST_SPAWN_INTERVAL
		elif roll > 0.6 and economy.can_afford(state.id, BalanceConfig.COST_TOWER_UPGRADE_L1_TO_L2):
			request_upgrade_tower(state.id)
		elif roll > 0.3 and economy.can_afford(state.id, BalanceConfig.COST_AUDITOR_HERO):
			request_deploy_hero(state.id)

func request_spawn_analysts(faction_id: String, target_faction_id: String, count: int) -> void:
	if game_manager and game_manager.has_method("spawn_analyst_batch"):
		game_manager.spawn_analyst_batch(faction_id, target_faction_id, count)

func request_upgrade_tower(faction_id: String) -> void:
	if game_manager and game_manager.has_method("upgrade_tower_for_faction"):
		game_manager.upgrade_tower_for_faction(faction_id)

func request_deploy_hero(faction_id: String) -> void:
	if game_manager and game_manager.has_method("deploy_hero"):
		game_manager.deploy_hero(faction_id)

func _choose_target_for(faction_id: String) -> String:
	if not faction_registry:
		return faction_id
	var alive: Array = []
	for other in faction_registry.get_big4_factions():
		if other.id == faction_id:
			continue
		if other.hq:
			alive.append(other.id)
	if alive.is_empty():
		return faction_id
	var current_state = faction_registry.get_faction(faction_id)
	if current_state and current_state.target_faction_id in alive and randf() < 0.5:
		return current_state.target_faction_id
	var player_id = game_manager.player_faction_id if game_manager else ""
	var non_player: Array = []
	for id in alive:
		if id != player_id:
			non_player.append(id)
	if not non_player.is_empty():
		# 30% chance to focus player if alive, else pick a non-player target.
		if player_id != "" and player_id in alive and randf() < 0.3:
			return player_id
		return non_player[randi() % non_player.size()]
	return alive[randi() % alive.size()]

func _count_units(faction_id: String, unit_type: String) -> int:
	if not game_manager or not game_manager.unit_registry:
		return 0
	var units = game_manager.unit_registry.get_units(faction_id, unit_type)
	return units.size()
