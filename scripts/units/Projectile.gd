class_name Projectile
extends Area2D

var speed: float = 260.0
var damage: float = 1.0
var faction_id: String = ""
var direction: Vector2 = Vector2.RIGHT
var target: Node = null
var target_position: Vector2 = Vector2.ZERO

func set_target(new_target: Node) -> void:
	target = new_target
	if target:
		target_position = target.global_position

func _process(delta: float) -> void:
	if target and is_instance_valid(target):
		target_position = target.global_position
	var dir = (target_position - global_position)
	if dir.length() == 0:
		dir = direction
	position += dir.normalized() * speed * delta
	if target and is_instance_valid(target) and global_position.distance_to(target.global_position) < 12.0:
		_on_hit(target)

func _on_hit(target_node: Node) -> void:
	if target_node and target_node.has_method("take_damage"):
		target_node.take_damage(damage, faction_id)
	queue_free()
