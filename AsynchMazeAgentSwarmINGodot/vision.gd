extends Node2D
var vision_radius
@onready var detection_shape = $Detection

var peers = []

func get_los_peers() -> Array:
	var peers_los = []
	for body in peers:
		if body == null or !is_instance_valid(body) or body == get_parent():
			continue
		var space_state := get_world_2d().direct_space_state
		var params := PhysicsRayQueryParameters2D.create(global_position, body.global_position)
		params.collision_mask = 1 << 0
		var hit := space_state.intersect_ray(params)
		if hit.is_empty():
			peers_los.append(body)
	return peers_los


func _on_body_entered(body: Node2D) -> void:
	peers.append(body)

func _on_detection_body_exited(body: Node2D) -> void:
	peers.erase(body)
