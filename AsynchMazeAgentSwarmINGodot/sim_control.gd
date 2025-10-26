class_name SimControl
extends Node
@export_range(10, 150) var number_of_agents: int = 10
@export var TPS = 60
@export var max_timesteps = 2500
@export var percentage_for_success = 95
@export var grace_period = 200

var beaconing
var diffusing
var subgoaling


@export var world_2d: Node2D
@onready var top_menu = $CanvasLayer/TopMenu

var current_sim

signal timestep_changed(value: int)
signal t_1_changed(value: int)
signal t_2_changed(value: int)

var goal_sighted
var t_1 = -1
var t_2 = -1
var no_goal_reached = 0

var _timesteps: int
var timesteps: int:
	get: return _timesteps
	set(value):
		_timesteps = value
		timestep_changed.emit(value)
		
		
var _started = false
	
	
func _ready() -> void:
	Engine.set_physics_ticks_per_second(TPS)
	await get_tree().physics_frame
	await get_tree().physics_frame 
	_started = true
	Globals.goal_sighted.connect(_on_goal_sighted)
	Globals.goal_reached.connect(_on_goal_reached)
	load_sim()
	
	
func _physics_process(delta: float) -> void:
	if not _started:
		return
	
	
	if timesteps >= max_timesteps:
		end_sim()
		get_tree().paused = true
		return
	timesteps += 1
	
func end_sim() -> void:
	var stragglers = number_of_agents - no_goal_reached
	print(diffusing, beaconing, subgoaling, number_of_agents, t_1, t_2, timesteps, stragglers)


func load_sim() -> void:
	timesteps = 0
	t_1 = -1
	t_1_changed.emit(t_1)
	t_2 = -1
	t_2_changed.emit(t_2)

	goal_sighted = false
	no_goal_reached = 0
	number_of_agents = top_menu.number_of_agents
	max_timesteps = top_menu.max_timesteps
	beaconing = top_menu.beaconing
	diffusing = top_menu.diffusing
	subgoaling = top_menu.subgoaling
	grace_period = top_menu.grace_period
	percentage_for_success = top_menu.target_percent
	
	if current_sim != null:
		current_sim.queue_free()
	var new = load("res://sim.tscn").instantiate()
	new.no_agents = number_of_agents
	new.beaconing = beaconing
	new.diffusing = diffusing
	new.subgoaling = subgoaling

	self.add_child(new)
	current_sim = new
	
func _on_top_menu_reset_sim_button() -> void:
	load_sim()
	
func _on_goal_sighted() -> void:
	if goal_sighted:
		return
	goal_sighted = true
	t_1 = timesteps
	t_1_changed.emit(t_1)
	
func _on_goal_reached() -> void:
	no_goal_reached += 1
	if no_goal_reached == number_of_agents:
		end_sim()
	if t_2 == -1 and float(no_goal_reached)/float(number_of_agents) > float(percentage_for_success)/100:
		t_2 = timesteps
		max_timesteps = timesteps + grace_period
		t_2_changed.emit(t_2)
	
	
