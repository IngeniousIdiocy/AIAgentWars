extends RefCounted

const UnitRegistry = preload("res://scripts/core/UnitRegistry.gd")

func run() -> bool:
	var registry := UnitRegistry.new()
	var a1 := Node2D.new()
	var a2 := Node2D.new()
	var hq := Node2D.new()
	registry.register_unit(a1, "A", "analyst")
	registry.register_unit(a2, "A", "analyst")
	registry.register_unit(hq, "A", "hq")

	var analysts := registry.get_units("A", "analyst")
	if analysts.size() != 2:
		print("Expected 2 analysts, got %s" % analysts.size())
		return false
	var all_units := registry.get_units("A")
	if all_units.size() != 3:
		print("Expected 3 total units, got %s" % all_units.size())
		return false
	return true
