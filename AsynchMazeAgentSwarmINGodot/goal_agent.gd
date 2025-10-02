class_name Goal
extends CharacterBody2D

enum State {EXPLORING, BEACON, SUBGOAL, SUBGOAL_F, BACKTRACK_B, BACKTRACK_G, EXPLOITING}
var current_state = State.SUBGOAL

var _vision_radius: float = 64.0
@onready var _detect_cs := $Vision/Detection/DetectionShape as CollisionShape2D

func _ready() -> void:
	_apply_vision_radius()

@export var VISION_RADIUS: float:
	get: return _vision_radius
	set(value):
		_vision_radius = value
		_apply_vision_radius()

func _apply_vision_radius() -> void:
	# Only act when the node is ready and the path exists
	if !is_node_ready() or _detect_cs == null:
		return
	_detect_cs.shape.radius = _vision_radius
	
