extends RefCounted

const FactionState = preload("res://scripts/core/FactionState.gd")

func run() -> bool:
	var state := FactionState.new()
	state.id = "TEST"
	state.name = "Test Faction"
	state.color = Color(1, 0, 0)
	state.is_neutral = false
	state.credits = 50
	state.income_rate = 5
	state.target_faction_id = "OTHER"
	return state.id == "TEST" and state.name == "Test Faction" and state.credits == 50 and state.target_faction_id == "OTHER"
