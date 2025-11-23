extends RefCounted

const GameManager = preload("res://scripts/core/GameManager.gd")
const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")

func run() -> bool:
	var manager := GameManager.new()
	manager.start_game(FactionsConfig.FACTION_KPMG)
	return manager.state == manager.GameState.RUNNING
