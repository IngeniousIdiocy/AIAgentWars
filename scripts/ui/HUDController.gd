class_name HUDController
extends Control

const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")

var economy: Node = null
var game_manager: Node = null

@onready var stats_container: HBoxContainer = $Backdrop/MainContainer/Row/StatsContainer
@onready var message_label: Label = $Backdrop/MainContainer/MessageLabel
@onready var mobile_controls: Control = $Backdrop/MainContainer/Row/MobileControls
@onready var target_button: Button = $Backdrop/MainContainer/Row/MobileControls/ButtonContainer/TargetButton

var _faction_labels: Dictionary = {}

func bind_systems(manager: Node, economy_system: Node) -> void:
	_ensure_nodes_ready()
	game_manager = manager
	economy = economy_system
	if economy and economy.has_signal("credits_changed"):
		if not economy.credits_changed.is_connected(_on_credits_changed):
			economy.credits_changed.connect(_on_credits_changed)
	if message_label:
		message_label.text = "Status: Running"
	_configure_faction_headers()
	update_target_label(game_manager.player_target_faction_id)
	_refresh_from_state()

func _on_credits_changed(faction_id: String, new_amount: float) -> void:
	_ensure_nodes_ready()
	_set_credits_text(faction_id, new_amount)

func update_hero_hp(faction_id: String, current: float, maximum: float) -> void:
	_ensure_nodes_ready()
	var label: Label = _get_label(faction_id, "hero")
	if not label:
		return
	if maximum <= 0:
		label.text = "Hero HP: -"
	else:
		label.text = "Hero HP: %s / %s" % [str(round(current)), str(round(maximum))]

func update_hq_hp(faction_id: String, current: float, maximum: float) -> void:
	_ensure_nodes_ready()
	var label: Label = _get_label(faction_id, "hq")
	if not label:
		return
	if maximum <= 0:
		label.text = "HQ HP: -"
	else:
		label.text = "HQ HP: %s / %s" % [str(round(current)), str(round(maximum))]

func show_message(text: String) -> void:
	_ensure_nodes_ready()
	if message_label:
		message_label.text = "Status: %s" % text

func update_target_label(target_faction_id: String) -> void:
	_ensure_nodes_ready()
	if not target_button:
		return
	var display_name: String = target_faction_id
	if game_manager and game_manager.faction_registry:
		var state = game_manager.faction_registry.get_faction(target_faction_id)
		if state and state.name:
			display_name = state.name
	target_button.text = "Δ Target: %s" % display_name

func _refresh_from_state() -> void:
	_ensure_nodes_ready()
	if not game_manager or not game_manager.faction_registry:
		return
	for state in game_manager.faction_registry.get_big4_factions():
		_set_credits_text(state.id, state.credits)

func _ensure_nodes_ready() -> void:
	if not stats_container and has_node("Backdrop/MainContainer/Row/StatsContainer"):
		stats_container = get_node("Backdrop/MainContainer/Row/StatsContainer")
	if not message_label and has_node("Backdrop/MainContainer/MessageLabel"):
		message_label = get_node("Backdrop/MainContainer/MessageLabel")
	if not mobile_controls and has_node("Backdrop/MainContainer/Row/MobileControls"):
		mobile_controls = get_node("Backdrop/MainContainer/Row/MobileControls")
	if not target_button and has_node("Backdrop/MainContainer/Row/MobileControls/ButtonContainer/TargetButton"):
		target_button = get_node("Backdrop/MainContainer/Row/MobileControls/ButtonContainer/TargetButton")
	if _faction_labels.is_empty():
		_build_faction_label_map()

func _build_faction_label_map() -> void:
	_faction_labels.clear()
	if not stats_container:
		return
	for faction_id in FactionsConfig.BIG4_IDS:
		var column: Node = stats_container.get_node_or_null("%sStats" % faction_id)
		if not column:
			continue
		var content: Node = column.get_node_or_null("Content") if column.has_method("get_node_or_null") else null
		if not content:
			content = column
		_faction_labels[faction_id] = {
			"name": content.get_node_or_null("NameLabel"),
			"credits": content.get_node_or_null("CreditsLabel"),
			"hero": content.get_node_or_null("HeroLabel"),
			"hq": content.get_node_or_null("HQLabel"),
		}

func _configure_faction_headers() -> void:
	if not game_manager:
		return
	for faction_id in FactionsConfig.BIG4_IDS:
		var label: Label = _get_label(faction_id, "name")
		if not label:
			continue
		var title: String = faction_id
		var state = null
		if game_manager.faction_registry:
			state = game_manager.faction_registry.get_faction(faction_id)
		if state and state.name:
			title = state.name
		if game_manager.player_faction_id == faction_id:
			title = "%s (You)" % title
		label.text = title
		if state and state.color:
			label.add_theme_color_override("font_color", state.color)

func _set_credits_text(faction_id: String, amount: float) -> void:
	var label: Label = _get_label(faction_id, "credits")
	if label:
		label.text = "Credits: %.0f" % amount

func _get_label(faction_id: String, key: String) -> Label:
	if not _faction_labels.has(faction_id):
		return null
	return _faction_labels[faction_id].get(key, null)
