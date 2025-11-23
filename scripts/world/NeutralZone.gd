class_name NeutralZone
extends Node2D

func get_spawn_points() -> Array[Vector2]:
	var result: Array[Vector2] = []
	var container = get_node_or_null("SpawnPoints")
	if container:
		for child in container.get_children():
			if child is Marker2D:
				result.append(child.global_position)
	return result
