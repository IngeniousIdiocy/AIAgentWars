class_name InputController
extends Node

var hud: Node = null
var game_manager: Node = null

func bind(hud_node: HUDController, manager: Node) -> void:
	hud = hud_node
	game_manager = manager
	_connect_mobile_buttons()

func _connect_mobile_buttons() -> void:
	if not hud:
		return
	var controls = null
	if hud.has_method("get_node_or_null"):
		controls = hud.get_node_or_null("MobileControls")
		if not controls:
			controls = hud.get_node_or_null("Backdrop/MainContainer/Row/MobileControls")
	if not controls:
		return
	controls.get_node("ButtonContainer/ButtonsGrid/AttackButton").pressed.connect(_on_attack_pressed)
	controls.get_node("ButtonContainer/ButtonsGrid/SpawnAnalystsButton").pressed.connect(_on_spawn_pressed)
	controls.get_node("ButtonContainer/ButtonsGrid/DeployHeroButton").pressed.connect(_on_deploy_hero_pressed)
	controls.get_node("ButtonContainer/ButtonsGrid/UpgradeTowerButton").pressed.connect(_on_upgrade_pressed)
	controls.get_node("ButtonContainer/TargetButton").pressed.connect(_on_target_pressed)

func _on_attack_pressed() -> void:
	# TODO (UI & Input Agent): Trigger hero attack command.
	if game_manager and game_manager.has_method("player_attack"):
		game_manager.player_attack()

func _on_spawn_pressed() -> void:
	if game_manager and game_manager.has_method("spawn_player_analysts"):
		game_manager.spawn_player_analysts()

func _on_deploy_hero_pressed() -> void:
	if game_manager and game_manager.has_method("deploy_player_hero"):
		game_manager.deploy_player_hero()

func _on_upgrade_pressed() -> void:
	if game_manager and game_manager.has_method("upgrade_player_tower"):
		game_manager.upgrade_player_tower()

func _on_target_pressed() -> void:
	if game_manager and game_manager.has_method("cycle_player_target"):
		game_manager.cycle_player_target()

func _unhandled_input(event: InputEvent) -> void:
	if not game_manager:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if game_manager.has_method("move_player_hero_to"):
			game_manager.move_player_hero_to(event.position)
