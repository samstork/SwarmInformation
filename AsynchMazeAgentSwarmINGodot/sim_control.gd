extends Node
@export_range(10, 150) var no_agents: int = 50
@export var TPS = 60

func _process(delta: float) -> void:
	Engine.set_physics_ticks_per_second(TPS)
