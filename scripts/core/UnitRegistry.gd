class_name UnitRegistry
extends Node

var _units_by_faction: Dictionary = {}

func register_unit(unit: Node, faction_id: String, unit_type: String) -> void:
	if not _units_by_faction.has(faction_id):
		_units_by_faction[faction_id] = {}
	var by_type: Dictionary = _units_by_faction[faction_id]
	if not by_type.has(unit_type):
		by_type[unit_type] = []
	by_type[unit_type].append(unit)

func unregister_unit(unit: Node) -> void:
	for faction_id in _units_by_faction.keys():
		var by_type: Dictionary = _units_by_faction[faction_id]
		for unit_type in by_type.keys():
			var arr: Array = by_type[unit_type]
			if unit in arr:
				arr.erase(unit)

func get_units_near_position(faction_id: String, position: Vector2, radius: float) -> Array[Node]:
	var results: Array[Node] = []
	var radius_sq = radius * radius
	for other_id in _units_by_faction.keys():
		if other_id == faction_id:
			continue
		var by_type: Dictionary = _units_by_faction[other_id]
		for unit_type in by_type.keys():
			for unit in by_type[unit_type]:
				if not is_instance_valid(unit):
					continue
				if position.distance_squared_to(unit.global_position) <= radius_sq:
					results.append(unit)
	return results

func get_units(faction_id: String, unit_type: String = "") -> Array[Node]:
	if not _units_by_faction.has(faction_id):
		return []
	var by_type: Dictionary = _units_by_faction[faction_id]
	if unit_type == "":
		var combined: Array[Node] = []
		for arr in by_type.values():
			if arr is Array:
				for unit in arr:
					combined.append(unit)
		return combined
	var typed: Array[Node] = []
	if by_type.has(unit_type):
		for unit in by_type[unit_type]:
			typed.append(unit)
	return typed
