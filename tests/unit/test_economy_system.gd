extends RefCounted

const EconomySystem = preload("res://scripts/economy/EconomySystem.gd")
const FactionRegistry = preload("res://scripts/core/FactionRegistry.gd")
const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")

func run() -> bool:
	var registry := FactionRegistry.new()
	registry.initialize_from_config(FactionsConfig.FACTION_KPMG)
	var system := EconomySystem.new()
	system.configure(registry)
	system.add_credits(FactionsConfig.FACTION_KPMG, 10.0)
	if not system.can_afford(FactionsConfig.FACTION_KPMG, 5.0):
		print("Expected to afford after adding credits")
		return false
	if not system.spend_credits(FactionsConfig.FACTION_KPMG, 5.0):
		print("Expected spend_credits to succeed")
		return false
	system.add_income(1.0)
	var faction = registry.get_faction(FactionsConfig.FACTION_KPMG)
	return faction.credits > 0.0
