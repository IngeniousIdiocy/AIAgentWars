class_name HQ
extends Node2D

var hp: float = 200.0
var max_hp: float = 200.0
var faction_id: String = ""

signal hq_destroyed(faction_id: String)

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

var registry: Node = null
var economy: Node = null
var game_manager: Node = null

func _ready() -> void:
	# TODO (Units & Combat Agent): Wire HQ visuals and collision.
	pass

func configure(registry_ref: Node, economy_ref: Node, manager: Node) -> void:
	registry = registry_ref
	economy = economy_ref
	game_manager = manager

func take_damage(amount: float, source_faction: String = "") -> void:
	hp -= amount
	if hp <= 0.0:
		hp = 0.0
		hq_destroyed.emit(faction_id)
		if economy and source_faction != "" and source_faction != faction_id:
			economy.add_credits(source_faction, BalanceConfig.KILL_REWARD_HQ)
		if game_manager and game_manager.has_method("on_hq_destroyed"):
			game_manager.on_hq_destroyed(faction_id, source_faction)
		queue_free()
