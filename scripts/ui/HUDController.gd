class_name HUDController
extends Control

var economy: Node = null
var game_manager: Node = null

@onready var credits_label: Label = $Info/CreditsLabel
@onready var hero_label: Label = $Info/HeroLabel
@onready var hq_label: Label = $Info/HQLabel
@onready var message_label: Label = $Info/MessageLabel
@onready var mobile_controls: Control = $MobileControls

func bind_systems(manager: Node, economy_system: Node) -> void:
	_ensure_nodes_ready()
	game_manager = manager
	economy = economy_system
	if economy and economy.has_signal("credits_changed"):
		economy.credits_changed.connect(_on_credits_changed)
	if message_label:
		message_label.text = "Status: Running"
	_refresh_from_state()

func _on_credits_changed(faction_id: String, new_amount: float) -> void:
	_ensure_nodes_ready()
	if game_manager and game_manager.player_faction_id == faction_id:
		if credits_label:
			credits_label.text = "Credits: %.0f" % new_amount

func update_hero_hp(current: float, maximum: float) -> void:
	_ensure_nodes_ready()
	if hero_label:
		hero_label.text = "Hero HP: %s / %s" % [str(round(current)), str(round(maximum))]

func update_hq_hp(current: float, maximum: float) -> void:
	_ensure_nodes_ready()
	if hq_label:
		hq_label.text = "HQ HP: %s / %s" % [str(round(current)), str(round(maximum))]

func show_message(text: String) -> void:
	_ensure_nodes_ready()
	if message_label:
		message_label.text = "Status: %s" % text

func _refresh_from_state() -> void:
	_ensure_nodes_ready()
	if not game_manager or not game_manager.faction_registry:
		return
	var state = game_manager.faction_registry.get_faction(game_manager.player_faction_id)
	if state:
		if credits_label:
			credits_label.text = "Credits: %.0f" % state.credits

func _ensure_nodes_ready() -> void:
	if not credits_label and has_node("Info/CreditsLabel"):
		credits_label = get_node("Info/CreditsLabel")
	if not hero_label and has_node("Info/HeroLabel"):
		hero_label = get_node("Info/HeroLabel")
	if not hq_label and has_node("Info/HQLabel"):
		hq_label = get_node("Info/HQLabel")
	if not message_label and has_node("Info/MessageLabel"):
		message_label = get_node("Info/MessageLabel")
	if not mobile_controls and has_node("MobileControls"):
		mobile_controls = get_node("MobileControls")
