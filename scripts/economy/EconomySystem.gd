class_name EconomySystem
extends Node

signal credits_changed(faction_id: String, new_amount: float)

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")
const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")

var faction_registry: Node = null
var _fallback_wallets: Dictionary = {}

func configure(registry: Node) -> void:
	faction_registry = registry

func add_income(delta: float) -> void:
	if faction_registry and faction_registry.has_method("get_big4_factions"):
		for faction_state in faction_registry.get_big4_factions():
			if faction_state.is_neutral:
				continue
			var gain = faction_state.income_rate * delta
			faction_state.credits += gain
			credits_changed.emit(faction_state.id, faction_state.credits)

func add_credits(faction_id: String, amount: float) -> void:
	var state = null
	if faction_registry:
		state = faction_registry.get_faction(faction_id)
	if state:
		state.credits += amount
		credits_changed.emit(faction_id, state.credits)
	else:
		_fallback_wallets[faction_id] = _fallback_wallets.get(faction_id, 0.0) + amount
		credits_changed.emit(faction_id, _fallback_wallets[faction_id])

func can_afford(faction_id: String, cost: float) -> bool:
	return _get_credits(faction_id) >= cost

func spend_credits(faction_id: String, cost: float) -> bool:
	if not can_afford(faction_id, cost):
		return false
	if faction_registry and faction_registry.get_faction(faction_id):
		var state = faction_registry.get_faction(faction_id)
		state.credits -= cost
		credits_changed.emit(faction_id, state.credits)
	else:
		_fallback_wallets[faction_id] = _fallback_wallets.get(faction_id, 0.0) - cost
		credits_changed.emit(faction_id, _fallback_wallets[faction_id])
	return true

func _get_credits(faction_id: String) -> float:
	if faction_registry and faction_registry.get_faction(faction_id):
		return faction_registry.get_faction(faction_id).credits
	return _fallback_wallets.get(faction_id, 0.0)
