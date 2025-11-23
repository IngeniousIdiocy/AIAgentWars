class_name FactionBase
extends Node2D

@export var faction_id: String = ""
@export var base_color: Color = Color.WHITE

@onready var hq: Node2D = $HQ
@onready var spawn_point: Marker2D = $SpawnPoint
var tower_slots: Array[Node] = []

func _ready() -> void:
	var container = get_node_or_null("TowerSlots")
	tower_slots = []
	if container:
		tower_slots = container.get_children()
	_apply_color()

func get_hq() -> Node2D:
	return hq

func get_spawn_point() -> Vector2:
	var node = _get_spawn_node()
	return node.global_position if node else global_position

func get_tower_slots() -> Array:
	return tower_slots

func set_faction_color(color: Color) -> void:
	base_color = color
	_apply_color()

func _apply_color() -> void:
	var visual = get_node_or_null("Visual")
	if visual:
		visual.modulate = base_color

func _get_spawn_node() -> Marker2D:
	if spawn_point:
		return spawn_point
	if has_node("SpawnPoint"):
		spawn_point = get_node("SpawnPoint")
		return spawn_point
	return null
