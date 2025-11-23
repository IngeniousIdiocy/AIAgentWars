extends RefCounted

const Tower = preload("res://scripts/units/Tower.gd")
const UnitRegistry = preload("res://scripts/core/UnitRegistry.gd")
const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

var destroyed_flag := false

class MockEconomy:
	extends Node
	var added: float = 0.0
	var last_faction: String = ""
	func add_credits(faction_id: String, amount: float) -> void:
		added += amount
		last_faction = faction_id

func run() -> bool:
	var registry := UnitRegistry.new()
	var econ := MockEconomy.new()
	var tower := Tower.new()
	tower.faction_id = "DEFENDER"
	tower.configure(registry, null, econ)

	# Upgrading should raise max_hp and reset hp.
	var base_max_hp := tower.max_hp
	tower.upgrade()
	if tower.max_hp <= base_max_hp or tower.hp != tower.max_hp:
		print("Upgrade did not raise and reset HP")
		return false

	# Lethal damage should destroy and reward credits to attacker.
	tower.hp = 5.0
	tower.tower_destroyed.connect(Callable(self, "_on_tower_destroyed"))
	tower.take_damage(10.0, "ATTACKER")
	if not destroyed_flag or tower.hp > 0.0:
		print("Tower did not emit destroyed signal on lethal damage")
		return false
	if econ.added != BalanceConfig.KILL_REWARD_TOWER or econ.last_faction != "ATTACKER":
		print("Credits not awarded correctly on tower kill")
		return false
	return true

func _on_tower_destroyed(_fid: String, _tower: Node) -> void:
	destroyed_flag = true
