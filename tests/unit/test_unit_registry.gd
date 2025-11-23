extends RefCounted

const UnitRegistry = preload("res://scripts/core/UnitRegistry.gd")

func run() -> bool:
	var registry := UnitRegistry.new()
	var dummy := Node2D.new()
	registry.register_unit(dummy, "A", "analyst")
	var nearby := registry.get_units_near_position("B", Vector2.ZERO, 10.0)
	if nearby.size() != 1:
		print("Expected one enemy unit in range")
		return false
	registry.unregister_unit(dummy)
	var after := registry.get_units_near_position("B", Vector2.ZERO, 10.0)
	return after.is_empty()
