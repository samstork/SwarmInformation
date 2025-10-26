extends Node2D

@export var scene_to_spawn: PackedScene                 # The scene to instance
@export var target_count: int = 50                     # Desired total instances
@export var container: NodePath                         # Optional parent for instances
@export var maintain_count: bool = false                 # Keep topping up when some are freed
@export var randomize_rotation: bool = false 
@export var spawn_radius: float = 7.0    

var beaconing = true
var diffusing = true
var subgoaling = true

var _group_name: String
var _parent: Node

func _enter_tree() -> void:
	_group_name = "spawner_" + str(get_instance_id())

func _ready() -> void:
	if container.is_empty():
		_parent = self 
	else: 
		_parent = get_node(container)

func _process(delta: float) -> void:
	top_up()


func top_up() -> void:
	if scene_to_spawn == null:
		push_error("%s: scene_to_spawn is not set." % name)
		return

	var existing = get_tree().get_nodes_in_group(_group_name).size()
	var need = max(0, target_count - existing)
	if need <= 0:
		return

	for i in range(need):
		var inst = scene_to_spawn.instantiate()
		inst.beaconing = beaconing
		inst.diffusing = diffusing
		inst.subgoaling = subgoaling
		_parent.add_child(inst)
		
		if inst is Node2D:
			var pos
			pos = self.global_position
			if spawn_radius > 0.0:
				var a = randf() * TAU
				var r = randf() * spawn_radius
				pos += Vector2(cos(a), sin(a)) * r
			(inst as Node2D).position = pos
			if randomize_rotation:
				(inst as Node2D).rotation = randf() * TAU

		inst.add_to_group(_group_name)

		if not maintain_count:
			self.queue_free()

func _on_spawned_tree_exited() -> void:
	# Defer to let the tree update before recounting
	call_deferred("top_up")

# Optional utility: clear all instances from this spawner
func clear_all() -> void:
	for n in get_tree().get_nodes_in_group(_group_name):
		if is_instance_valid(n):
			n.queue_free()
