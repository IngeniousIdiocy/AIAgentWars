extends RefCounted

const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")

func run() -> bool:
	var ok := true
	var ids := [
		FactionsConfig.FACTION_KPMG,
		FactionsConfig.FACTION_PWC,
		FactionsConfig.FACTION_EY,
		FactionsConfig.FACTION_DELOITTE,
		FactionsConfig.FACTION_ACCENTURE,
	]
	for id in ids:
		if not FactionsConfig.FACTION_DATA.has(id):
			print("Missing faction in FACTION_DATA: ", id)
			ok = false
	for key in FactionsConfig.FACTION_DATA.keys():
		var data: Dictionary = FactionsConfig.FACTION_DATA[key]
		if not data.has("name") or not data.has("color"):
			print("Missing data for faction: ", key)
			ok = false
	return ok
