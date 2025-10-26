class_name SimInstance
extends Node2D
var no_agents = 50
var beaconing = true
var diffusing = true
var subgoaling = true
@onready var Spawner := $AgentSpawner as Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawner.target_count = no_agents
	Spawner.beaconing = beaconing
	Spawner.diffusing = diffusing
	Spawner.subgoaling = subgoaling
