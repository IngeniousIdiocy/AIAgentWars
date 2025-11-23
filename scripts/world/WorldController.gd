class_name WorldController
extends Node2D

const FactionsConfig = preload("res://scripts/config/FactionsConfig.gd")
const TILE_ROAD = preload("res://assets/game/tiles/cityTiles_080.png")
const GROUND_TILES = [
	preload("res://assets/game/tiles/cityTiles_031.png"),
	preload("res://assets/game/tiles/cityTiles_074.png"),
	preload("res://assets/game/tiles/cityTiles_097.png"),
]

@export var base_scene: PackedScene
@export var neutral_zone_scene: PackedScene

const MAP_SIZE := 80
const TILE_WIDTH := 132.0
const TILE_HEIGHT := 83.0
const HALF_TILE_W := TILE_WIDTH * 0.5
const HALF_TILE_H := TILE_HEIGHT * 0.5

var bases: Dictionary = {}
var neutral_zone: Node = null
var spawn_points: Dictionary = {}
var lanes: Dictionary = {}

var lane_center: Vector2 = Vector2.ZERO
var _grid_center: Vector2i = Vector2i.ZERO
var _base_tiles: Dictionary = {}
var _map_bounds: Rect2 = Rect2()

func _ready() -> void:
	if base_scene and neutral_zone_scene and bases.is_empty():
		setup_world()

func setup_world() -> void:
	_clear_children()
	_define_base_tiles()
	_build_city_grid()
	_spawn_bases()
	_spawn_neutral_zone()
	_build_lanes()

func _spawn_bases() -> void:
	bases.clear()
	spawn_points.clear()
	var positions: Dictionary = {}
	for faction_id in _base_tiles.keys():
		positions[faction_id] = _iso_to_world_from_grid(_base_tiles[faction_id])
	lane_center = _iso_to_world_from_grid(_grid_center)
	for faction_id in positions.keys():
		var base = base_scene.instantiate()
		base.faction_id = faction_id
		base.position = positions[faction_id]
		get_node("BaseContainer").add_child(base)
		bases[faction_id] = base
		spawn_points[faction_id] = base.get_spawn_point()

func _spawn_neutral_zone() -> void:
	var container = get_node("NeutralContainer")
	_queue_free_children(container)
	neutral_zone = neutral_zone_scene.instantiate()
	container.add_child(neutral_zone)
	neutral_zone.position = lane_center

func _build_city_grid() -> void:
	_grid_center = Vector2i(MAP_SIZE / 2, MAP_SIZE / 2)
	var decor = get_node("Decor")
	_queue_free_children(decor)
	var road_tiles = _generate_roads()
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF
	for q in range(MAP_SIZE):
		for r in range(MAP_SIZE):
			var tile_coord = Vector2i(q, r)
			var sprite = Sprite2D.new()
			var is_road = road_tiles.has(tile_coord)
			sprite.texture = TILE_ROAD if is_road else _pick_ground_tile(tile_coord)
			var pos = _iso_to_world_from_grid(tile_coord)
			sprite.position = pos
			sprite.centered = true
			sprite.modulate = Color(1, 1, 1, 0.95) if is_road else Color(1, 1, 1, 0.85)
			decor.add_child(sprite)
			min_x = min(min_x, pos.x)
			min_y = min(min_y, pos.y)
			max_x = max(max_x, pos.x)
			max_y = max(max_y, pos.y)
	_map_bounds = Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _pick_ground_tile(tile_coord: Vector2i) -> Texture2D:
	if GROUND_TILES.is_empty():
		return TILE_ROAD
	var seed = int(tile_coord.x * 734287 + tile_coord.y * 912271)
	var idx = abs(seed) % GROUND_TILES.size()
	return GROUND_TILES[idx]

func _generate_roads() -> Dictionary:
	var result: Dictionary = {}
	for base_tile in _base_tiles.values():
		_carve_path(result, base_tile, _grid_center, 1)
	return result

func _carve_path(roads: Dictionary, start: Vector2i, target: Vector2i, half_width: int) -> void:
	var current = start
	while current != target:
		_stamp_road(roads, current, half_width)
		if current.x != target.x:
			current.x += 1 if current.x < target.x else -1
		elif current.y != target.y:
			current.y += 1 if current.y < target.y else -1
	_stamp_road(roads, target, half_width)

func _stamp_road(roads: Dictionary, coord: Vector2i, half_width: int) -> void:
	for dx in range(-half_width, half_width + 1):
		for dy in range(-half_width, half_width + 1):
			var key = Vector2i(coord.x + dx, coord.y + dy)
			if key.x >= 0 and key.x < MAP_SIZE and key.y >= 0 and key.y < MAP_SIZE:
				roads[key] = true

func _define_base_tiles() -> void:
	_base_tiles = {
		FactionsConfig.FACTION_KPMG: Vector2i(8, 12),
		FactionsConfig.FACTION_PWC: Vector2i(MAP_SIZE - 9, 12),
		FactionsConfig.FACTION_EY: Vector2i(MAP_SIZE - 9, MAP_SIZE - 12),
		FactionsConfig.FACTION_DELOITTE: Vector2i(8, MAP_SIZE - 12),
	}

func _iso_to_world_from_grid(tile: Vector2i) -> Vector2:
	var centered = tile - _grid_center
	return Vector2((centered.x - centered.y) * HALF_TILE_W, (centered.x + centered.y) * HALF_TILE_H)

func get_map_bounds() -> Rect2:
	return _map_bounds

func _build_ground() -> void:
	var decor = get_node("Decor")
	_queue_free_children(decor)

func _build_lanes() -> void:
	lanes.clear()
	for from_id in spawn_points.keys():
		for to_id in spawn_points.keys():
			if from_id == to_id:
				continue
			var key = "%s->%s" % [from_id, to_id]
			var path: Array[Vector2] = [
				spawn_points[from_id],
				lane_center,
				spawn_points[to_id],
			]
			lanes[key] = path

func get_spawn_point_for_faction(faction_id: String) -> Vector2:
	return spawn_points.get(faction_id, Vector2.ZERO)

func get_lane_path(from_faction_id: String, to_faction_id: String) -> Array[Vector2]:
	var key = "%s->%s" % [from_faction_id, to_faction_id]
	if lanes.has(key):
		return lanes[key].duplicate()
	return []

func get_neutral_spawn_points() -> Array[Vector2]:
	if neutral_zone and neutral_zone.has_method("get_spawn_points"):
		return neutral_zone.get_spawn_points()
	return []

func bind_factions(registry: Node) -> void:
	if not registry:
		return
	for faction_id in bases.keys():
		var base: FactionBase = bases[faction_id]
		var state = registry.get_faction(faction_id)
		if state:
			base.set_faction_color(state.color)
			state.hq = base.get_hq()
			state.towers = base.get_tower_slots()

func _clear_children() -> void:
	if has_node("BaseContainer"):
		_queue_free_children(get_node("BaseContainer"))
	if has_node("NeutralContainer"):
		_queue_free_children(get_node("NeutralContainer"))

func _queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
