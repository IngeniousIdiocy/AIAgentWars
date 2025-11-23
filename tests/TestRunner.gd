extends Node

func _ready() -> void:
	var success := run_all_tests()
	print("All tests passed" if success else "Some tests failed")
	get_tree().quit(0 if success else 1)

func run_all_tests() -> bool:
	var suite_paths := [
		"res://tests/unit/test_faction_config.gd",
		"res://tests/unit/test_balance_config.gd",
		"res://tests/unit/test_faction_state.gd",
		"res://tests/unit/test_economy_system.gd",
		"res://tests/unit/test_unit_registry.gd",
		"res://tests/unit/test_unit_registry_get_units.gd",
		"res://tests/unit/test_tower.gd",
		"res://tests/integration/test_basic_bootstrap.gd",
		"res://tests/integration/test_game_flow_minimal.gd",
	]
	var passed := true
	for path in suite_paths:
		var suite = load(path).new()
		var ok: bool = suite.run()
		print("%s -> %s" % [path, "PASS" if ok else "FAIL"])
		passed = passed and ok
	return passed
