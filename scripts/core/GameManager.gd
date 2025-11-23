class_name GameManager
extends Node

signal game_started
signal game_over(winner_faction_id: String)

enum GameState { SETUP, RUNNING, VICTORY, DEFEAT }

const GameScene = preload("res://scenes/main/Game.tscn")
const FactionSelectScene = preload("res://scenes/ui/FactionSelect.tscn")
const AnalystScene = preload("res://scenes/units/Analyst.tscn")
const AuditorScene = preload("res://scenes/units/Auditor.tscn")
const NeutralMobScene = preload("res://scenes/units/NeutralMob.tscn")
const ProjectileScene = preload("res://scenes/units/Projectile.tscn")
const TowerScript = preload("res://scripts/units/Tower.gd")

const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")
const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")
const FactionRegistry = preload("res://scripts/core/FactionRegistry.gd")
const UnitRegistry = preload("res://scripts/core/UnitRegistry.gd")
const EconomySystem = preload("res://scripts/economy/EconomySystem.gd")
const FactionAIController = preload("res://scripts/ai/FactionAIController.gd")

var state: int = GameState.SETUP
var player_faction_id: String = ""
var player_target_faction_id: String = ""

var faction_registry: Node = null
var unit_registry: Node = null
var economy_system: Node = null
var faction_ai_controller: Node = null

var world: Node = null
var hud: Node = null
var input_controller: Node = null
var game_scene_instance: Node = null
var faction_select_instance: Node = null

var heroes: Dictionary = {}
var hq_by_faction: Dictionary = {}
var towers_by_faction: Dictionary = {}
var _faction_colors: Dictionary = {}

func _ready() -> void:
	_show_faction_select()

func _process(delta: float) -> void:
	if state == GameState.RUNNING:
		tick(delta)

func tick(delta: float) -> void:
	if economy_system:
		economy_system.add_income(delta)
	if faction_ai_controller:
		faction_ai_controller.process_ai(delta)
	_update_hud_stats()
	_check_victory_conditions()

func start_game(chosen_faction_id: String) -> void:
	player_faction_id = chosen_faction_id
	player_target_faction_id = _pick_initial_target(chosen_faction_id)
	_load_game_scene()
	_init_systems()
	state = GameState.RUNNING
	game_started.emit()

func _pick_initial_target(chosen: String) -> String:
	for id in FactionsConfig.BIG4_IDS:
		if id != chosen:
			return id
	return ""

func _show_faction_select() -> void:
	if faction_select_instance:
		faction_select_instance.queue_free()
	faction_select_instance = FactionSelectScene.instantiate()
	add_child(faction_select_instance)
	faction_select_instance.faction_selected.connect(func(faction_id): start_game(faction_id))

func _load_game_scene() -> void:
	if game_scene_instance:
		game_scene_instance.queue_free()
	game_scene_instance = GameScene.instantiate()
	add_child(game_scene_instance)
	world = game_scene_instance.get_node("World")
	hud = game_scene_instance.get_node("HUDLayer/HUD") if game_scene_instance.has_node("HUDLayer/HUD") else game_scene_instance.get_node("HUD")
	input_controller = game_scene_instance.get_node("InputController")

func _init_systems() -> void:
	if faction_select_instance:
		faction_select_instance.queue_free()
		faction_select_instance = null

	faction_registry = FactionRegistry.new()
	add_child(faction_registry)
	faction_registry.initialize_from_config(player_faction_id)
	for state in faction_registry.get_big4_factions():
		_faction_colors[state.id] = state.color

	unit_registry = UnitRegistry.new()
	add_child(unit_registry)

	economy_system = EconomySystem.new()
	add_child(economy_system)
	economy_system.configure(faction_registry)

	faction_ai_controller = FactionAIController.new()
	add_child(faction_ai_controller)
	faction_ai_controller.configure(self, faction_registry, economy_system, world)

	if world and world.has_method("setup_world"):
		world.setup_world()
	if world and world.has_method("bind_factions"):
		world.bind_factions(faction_registry)
	_setup_structures()
	_spawn_initial_neutral_mobs()

	if hud and hud.has_method("bind_systems"):
		hud.bind_systems(self, economy_system)
		if hud.has_method("update_target_label"):
			hud.update_target_label(player_target_faction_id)
	if input_controller and input_controller.has_method("bind"):
		input_controller.bind(hud, self)
	if hud and hud.has_method("show_message") and player_target_faction_id != "":
		hud.show_message("Targeting %s" % player_target_faction_id)

func spawn_player_analysts() -> void:
	if economy_system and economy_system.spend_credits(player_faction_id, BalanceConfig.COST_ANALYST_BATCH):
		spawn_analyst_batch(player_faction_id, player_target_faction_id, BalanceConfig.ANALYSTS_PER_BATCH)
		if hud:
			hud.show_message("Spawned analysts toward %s" % player_target_faction_id)

func deploy_player_hero() -> void:
	deploy_hero(player_faction_id)

func upgrade_player_tower() -> void:
	upgrade_tower_for_faction(player_faction_id)

func cycle_player_target() -> void:
	var idx = FactionsConfig.BIG4_IDS.find(player_target_faction_id)
	var next_idx = (idx + 1) % FactionsConfig.BIG4_IDS.size()
	var next_id = FactionsConfig.BIG4_IDS[next_idx]
	if next_id == player_faction_id:
		next_idx = (next_idx + 1) % FactionsConfig.BIG4_IDS.size()
		next_id = FactionsConfig.BIG4_IDS[next_idx]
	player_target_faction_id = next_id
	if hud and hud.has_method("update_target_label"):
		hud.update_target_label(next_id)
	if hud and hud.has_method("show_message"):
		hud.show_message("Targeting %s" % next_id)

func move_player_hero_to(position: Vector2) -> void:
	var hero: Node = heroes.get(player_faction_id)
	if hero and is_instance_valid(hero) and hero.has_method("set_move_target"):
		hero.set_move_target(position)

func player_attack() -> void:
	var hero: Node = heroes.get(player_faction_id)
	if hero and is_instance_valid(hero) and hero.has_method("trigger_attack"):
		hero.trigger_attack()

func spawn_analyst_batch(faction_id: String, target_faction_id: String, count: int) -> void:
	if not world:
		return
	var spawn_point = world.get_spawn_point_for_faction(faction_id)
	var lane = world.get_lane_path(faction_id, target_faction_id)
	for i in range(count):
		var analyst: Node2D = AnalystScene.instantiate()
		analyst.faction_id = faction_id
		analyst.target_faction_id = target_faction_id
		analyst.configure(unit_registry, economy_system, self)
		analyst.set_path(lane)
		analyst.global_position = spawn_point + Vector2(randf() * 10.0, randf() * 10.0)
		_apply_faction_tint(analyst, faction_id)
		world.add_child(analyst)
		unit_registry.register_unit(analyst, faction_id, "analyst")

func upgrade_tower_for_faction(faction_id: String) -> void:
	var towers: Array = towers_by_faction.get(faction_id, [])
	if towers.is_empty():
		return
	var chosen: Node = towers[0]
	for tower in towers:
		if tower.level < chosen.level:
			chosen = tower
	if chosen.level >= 3:
		return
	var cost = BalanceConfig.COST_TOWER_UPGRADE_L1_TO_L2 if chosen.level == 1 else BalanceConfig.COST_TOWER_UPGRADE_L2_TO_L3
	if economy_system and economy_system.spend_credits(faction_id, cost):
		chosen.upgrade()
		if hud and faction_id == player_faction_id:
			hud.show_message("Tower upgraded to L%s" % chosen.level)

func deploy_hero(faction_id: String) -> void:
	if heroes.has(faction_id) and is_instance_valid(heroes[faction_id]):
		return
	if economy_system and not economy_system.spend_credits(faction_id, BalanceConfig.COST_AUDITOR_HERO):
		return
	var hero: Node2D = AuditorScene.instantiate()
	hero.faction_id = faction_id
	hero.configure(unit_registry, economy_system, self)
	var spawn = world.get_spawn_point_for_faction(faction_id)
	hero.global_position = spawn
	_apply_faction_tint(hero, faction_id)
	world.add_child(hero)
	unit_registry.register_unit(hero, faction_id, "hero")
	heroes[faction_id] = hero
	hero.tree_exiting.connect(func():
		unit_registry.unregister_unit(hero)
		if heroes.has(faction_id):
			heroes.erase(faction_id)
	)
	if faction_id == player_faction_id:
		hud.update_hero_hp(faction_id, hero.hp, hero.max_hp)

func _setup_structures() -> void:
	hq_by_faction.clear()
	towers_by_faction.clear()
	if not world:
		return
	for faction_id in FactionsConfig.BIG4_IDS:
		var base = world.bases.get(faction_id)
		if not base:
			continue
		var hq: Node = base.get_hq()
		if hq and hq.has_method("configure"):
			hq.faction_id = faction_id
			hq.configure(unit_registry, economy_system, self)
			hq.hq_destroyed.connect(func(fid = faction_id): on_hq_destroyed(fid, ""))
			hq_by_faction[faction_id] = hq
			unit_registry.register_unit(hq, faction_id, "hq")
		var towers: Array = []
		for slot in base.get_tower_slots():
			var tower: Node2D = TowerScript.new()
			tower.faction_id = faction_id
			tower.position = slot.position
			tower.configure(unit_registry, ProjectileScene, economy_system)
			if tower.has_method("set_faction_color"):
				var tint = _faction_colors.get(faction_id, Color.WHITE)
				tower.set_faction_color(tint)
			base.add_child(tower)
			unit_registry.register_unit(tower, faction_id, "tower")
			tower.tower_destroyed.connect(_on_tower_destroyed)
			towers.append(tower)
		towers_by_faction[faction_id] = towers

func _spawn_initial_neutral_mobs() -> void:
	if not world:
		return
	for point in world.get_neutral_spawn_points():
		var mob: Node2D = NeutralMobScene.instantiate()
		mob.faction_id = FactionsConfig.FACTION_ACCENTURE
		mob.global_position = point
		mob.configure(unit_registry, economy_system)
		world.add_child(mob)
		unit_registry.register_unit(mob, mob.faction_id, "neutral")

func get_hq_for_faction(faction_id: String) -> Node:
	return hq_by_faction.get(faction_id)

func get_primary_enemy_hq(faction_id: String) -> Node:
	var candidates = []
	for id in hq_by_faction.keys():
		if id != faction_id:
			var hq = hq_by_faction[id]
			if hq and is_instance_valid(hq):
				candidates.append(hq)
	if candidates.is_empty():
		return null
	return candidates.front()

func _on_tower_destroyed(faction_id: String, tower: Node) -> void:
	if towers_by_faction.has(faction_id):
		var arr: Array = towers_by_faction[faction_id]
		if tower in arr:
			arr.erase(tower)

func _apply_faction_tint(node: Node, faction_id: String) -> void:
	var tint = _faction_colors.get(faction_id, Color.WHITE)
	var sprite = node.get_node_or_null("Sprite") if node else null
	if sprite and sprite is CanvasItem:
		sprite.modulate = tint

func on_hq_destroyed(faction_id: String, source_faction: String) -> void:
	if hq_by_faction.has(faction_id):
		hq_by_faction.erase(faction_id)
	var state_obj = faction_registry.get_faction(faction_id)
	if state_obj:
		state_obj.hq = null
	if faction_id == player_faction_id:
		state = GameState.DEFEAT
		game_over.emit(source_faction)
		if hud:
			hud.show_message("Defeat: HQ destroyed")
	else:
		_check_victory_conditions()

func _check_victory_conditions() -> void:
	if state != GameState.RUNNING:
		return
	if not hq_by_faction.has(player_faction_id):
		state = GameState.DEFEAT
		game_over.emit(player_faction_id)
		return
	if hq_by_faction.size() == 1 and hq_by_faction.has(player_faction_id):
		state = GameState.VICTORY
		game_over.emit(player_faction_id)
		if hud:
			hud.show_message("Victory!")

func _update_hud_stats() -> void:
	if not hud:
		return
	for faction_id in FactionsConfig.BIG4_IDS:
		var faction_hq = get_hq_for_faction(faction_id)
		if faction_hq:
			hud.update_hq_hp(faction_id, faction_hq.hp, faction_hq.max_hp)
		else:
			hud.update_hq_hp(faction_id, 0.0, 0.0)
		var hero: Node = heroes.get(faction_id)
		if hero and is_instance_valid(hero):
			hud.update_hero_hp(faction_id, hero.hp, hero.max_hp)
		else:
			hud.update_hero_hp(faction_id, 0.0, 0.0)
