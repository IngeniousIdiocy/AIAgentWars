class_name FactionRegistry
extends Node

const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")
const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")
const FactionState = preload("res://scripts/core/FactionState.gd")

var _factions: Dictionary = {}

func initialize_from_config(player_faction_id: String) -> void:
	_factions.clear()
	for faction_id in FactionsConfig.FACTION_DATA.keys():
		var data: Dictionary = FactionsConfig.FACTION_DATA[faction_id]
		var state = FactionState.new()
		state.id = faction_id
		state.name = data.get("name", faction_id)
		state.color = data.get("color", Color.WHITE)
		state.is_neutral = data.get("is_neutral", false)
		state.is_player = faction_id == player_faction_id
		state.income_rate = 0.0 if state.is_neutral else BalanceConfig.PASSIVE_INCOME_PER_SECOND
		state.credits = 0.0 if state.is_neutral else BalanceConfig.STARTING_CREDITS
		state.target_faction_id = _pick_default_target(faction_id)
		_factions[faction_id] = state

func get_faction(id: String) -> FactionState:
	return _factions.get(id)

func get_all_factions() -> Array[FactionState]:
	return _factions.values()

func get_big4_factions() -> Array[FactionState]:
	var result: Array[FactionState] = []
	for id in FactionsConfig.BIG4_IDS:
		var state: FactionState = _factions.get(id)
		if state:
			result.append(state)
	return result

func get_neutral_factions() -> Array[FactionState]:
	var result: Array[FactionState] = []
	for id in FactionsConfig.NEUTRAL_IDS:
		var state: FactionState = _factions.get(id)
		if state:
			result.append(state)
	return result

func _pick_default_target(faction_id: String) -> String:
	for candidate in FactionsConfig.BIG4_IDS:
		if candidate != faction_id:
			return candidate
	return ""
