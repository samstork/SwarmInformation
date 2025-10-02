class_name Agent
extends CharacterBody2D

enum DirectionMode {FORWARD = 1, REVERSE = -1}
enum State {EXPLORING, BEACON, SUBGOAL, SUBGOAL_F, BACKTRACK_B, BACKTRACK_G, EXPLOITING}
const MIN_DISTANCE = 0.0001
const deltat: float = 1.0/120



var _vision_radius: float = 150.0
@export var VISION_RADIUS: float:
	get: return _vision_radius
	set(value):
		_vision_radius = value
		_apply_vision_radius()
@export var SPEED = 300
@export var starting_state: State
@export_range(1, 75) var density_distance: float = 50  
@export_range(0, 1) var cohesion_wt: float
@export_range(0, 10) var alignment_wt: float
@export_range(0, 1) var explore_separation_wt: float = 0
@export_range(0, 0.5) var noise_wt: float = 0
@export_range(0, 0.8) var diffusion_wt: float = .35
@export_range(0, 1) var wall_avoid_wt: float = 0.35

@onready var vision = $Vision
@onready var sprite = $Sprite
@onready var _detect_cs = $Vision/Detection/DetectionShape as CollisionShape2D
@onready var ray_right = $Vision/RayRight as RayCast2D
@onready var ray_left = $Vision/RayLeft as RayCast2D

var _current_state: State
var current_state: State:
	get: return _current_state
	set(value):
		_current_state = value
		match value:
			State.EXPLORING:
				sprite.color = Color(0.151, 0.392, 1.0, 1.0)
			State.SUBGOAL:
				sprite.color = Color(0.0, 0.663, 0.0, 1.0)
			State.BEACON:
				sprite.color = Color(0.888, 0.704, 0.0, 1.0)
			State.EXPLOITING:
				sprite.color = Color(0.286, 1.0, 0.788, 1.0)
			State.BACKTRACK_B:
				sprite.color = Color(0.633, 0.036, 0.156, 1.0)
			State.BACKTRACK_G:
				sprite.color = Color(0.633, 0.036, 0.156, 1.0)

var target_pos: Vector2

var los_peers: Array = []
var _started := false

var _direction_vector
var direction_vector: Vector2:
	set(value):
		_direction_angle = value.angle()
		rotation = _direction_angle
		_direction_vector = value
	get:
		return _direction_vector
var _direction_angle
var direction_angle:
	set(value):
		_direction_angle = value
		rotation = direction_angle
		_direction_vector = Vector2(cos(direction_angle), sin(direction_angle))
	get:
		return _direction_angle

func _apply_vision_radius() -> void:
	# Only act when the node is ready and the path exists
	if !is_node_ready() or _detect_cs == null:
		return
	_detect_cs.shape.radius = _vision_radius

func _ready() -> void:
	_apply_vision_radius()
	current_state = starting_state
	direction_angle = randf_range(0, TAU)
	
	await get_tree().physics_frame
	await get_tree().physics_frame  # (two frames is extra-safe for complex setups)
	_started = true
	
	
func get_diffusion_vector(peers: Array) -> Vector2:
	var grad := Vector2.ZERO
	var sep := Vector2.ZERO
	var density_distance_2 = density_distance ** 2
	for peer in peers:
		var dir_vec = position - peer.position
		var dir_distance = max(dir_vec.length(), MIN_DISTANCE)
		if dir_distance > density_distance:
			continue
		var dir_distance_2 = dir_distance ** 2
		var w = exp((dir_distance_2) / (2 * density_distance_2))
		grad += (dir_vec * w) / dir_distance
		sep += (dir_vec / dir_distance) / (dir_distance_2 + 1.0)
	var diffusion_vector = grad + sep * explore_separation_wt
	if not diffusion_vector:
		return direction_vector.rotated(randf_range(-0.2, 0.2))
	return diffusion_vector
	
func _physics_process(delta: float) -> void:
	if not _started:
		return
	los_peers = vision.get_los_peers()
	
	var visible_beacons = []
	var visible_goals = []
	var visible_explorers = []
	var visible_exploiters = []
	
	for agent in los_peers:
		match agent.current_state:
			State.BEACON:
				visible_beacons.append(agent)
			State.SUBGOAL, State.SUBGOAL_F:
				visible_goals.append(agent)
			State.EXPLORING:
				visible_explorers.append(agent)
			State.EXPLOITING:
				visible_exploiters.append(agent)


	match current_state:
		State.EXPLORING:
			if len(visible_beacons) == 0:
				self.current_state = State.BACKTRACK_B
			elif visible_goals:
				current_state = State.BACKTRACK_G
				target_pos = visible_goals[0].position
			else:
				direction_vector = (direction_vector * (1 - diffusion_wt) + 
					get_diffusion_vector(visible_explorers) * diffusion_wt)
				if ray_left.is_colliding():
					direction_angle += wall_avoid_wt * PI
				if ray_right.is_colliding():
					direction_angle -= wall_avoid_wt * PI
				direction_angle += (noise_wt * randf_range(-3, 3))
				move(deltat, DirectionMode.FORWARD)

		State.BACKTRACK_B:
			if visible_goals:
				current_state = State.EXPLOITING
			elif len(visible_beacons) == 1:
				current_state = State.BEACON
				direction_vector = self.position.direction_to(visible_beacons[0].position)
				direction_angle += PI
			elif len(visible_beacons) > 1:
				current_state = State.EXPLORING
			else:
				move(deltat, DirectionMode.REVERSE)

		State.BACKTRACK_G:
			if len(visible_goals) == 0:
				current_state = State.SUBGOAL
				direction_vector = self.position.direction_to(target_pos)
			elif len(visible_goals) > 1:
				current_state = State.EXPLOITING
			else:
				move(deltat, DirectionMode.REVERSE)
	
		State.BEACON:
			if len(visible_goals):
				current_state = State.SUBGOAL
				direction_vector = self.position.direction_to(visible_goals[0].position)
		
		State.EXPLOITING:
			var heading = direction_vector
			var cohesion = Vector2()
			var goal_position = Vector2(0, 0)
			for agent in visible_goals:
				if agent is Goal:
					goal_position = agent.position
				elif agent is Agent:
					heading += agent.direction_vector * 10 / self.position.distance_to(agent.position)
					cohesion += agent.position / len(visible_goals)
			if goal_position:
				direction_vector = direction_vector * 0.65 + 0.35 * self.position.direction_to(goal_position)
				if self.position.distance_to(goal_position) < 5:
					queue_free()
				
			else:
				direction_vector = (direction_vector +
					heading * alignment_wt + 
					self.position.direction_to(cohesion) * cohesion_wt).normalized()
			if ray_left.is_colliding():
				direction_angle += wall_avoid_wt * PI
			if ray_right.is_colliding():
				direction_angle -= wall_avoid_wt * PI

			direction_angle = direction_angle + randf_range(-3, 3) * noise_wt
			move(deltat, DirectionMode.FORWARD)
			
		State.SUBGOAL:
			if visible_exploiters:
				current_state = State.SUBGOAL_F
		State.SUBGOAL_F:
			if not visible_exploiters:
				current_state = State.EXPLOITING

func move(delta: float, mode: DirectionMode) -> void:
	velocity = direction_vector.normalized() * (mode * SPEED)
	var collision = move_and_collide(velocity * delta)
	if collision:
		direction_vector = direction_vector.reflect(collision.get_normal()).normalized()
		direction_angle += PI
