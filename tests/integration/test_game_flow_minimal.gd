extends RefCounted

const GameManager = preload("res://scripts/core/GameManager.gd")
const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")
const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

func run() -> bool:
	var manager := GameManager.new()
	manager.start_game(FactionsConfig.FACTION_KPMG)
	manager.tick(1.0)
	manager.tick(1.0)
	# Ensure no crash and economy moved credits
	var faction = manager.faction_registry.get_faction(FactionsConfig.FACTION_KPMG)
	if faction == null:
		print("Faction not created")
		return false
	if faction.credits <= BalanceConfig.STARTING_CREDITS:
		print("Credits did not grow: ", faction.credits)
		return false
	return true
