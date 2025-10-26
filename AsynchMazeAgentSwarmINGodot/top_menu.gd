extends Control

signal reset_sim_button
var number_of_agents 
var max_timesteps
var beaconing
var diffusing
var grace_period
var target_percent
var subgoaling



@onready var timestep_text = $HBoxContainer/PanelContainer/HBoxContainer/GridContainer3/TimestepText
@onready var t_1_text = $HBoxContainer/PanelContainer/HBoxContainer/GridContainer3/GoalSightedText
@onready var t_2_text = $HBoxContainer/PanelContainer/HBoxContainer/GridContainer3/SuccessText
@onready var speed_ctrl = $HBoxContainer/PanelContainer/HBoxContainer/SimSpeedControls/SimSpeedSlider

func _ready() -> void:
	number_of_agents = $HBoxContainer/PanelContainer/HBoxContainer/TargetAgents/AgentBox.value
	max_timesteps = $HBoxContainer/PanelContainer/HBoxContainer/TargetTimesteps/MaxTSBox.value
	beaconing = $HBoxContainer/PanelContainer/HBoxContainer/AlgorithmToggles/BeaconButton.button_pressed
	diffusing = $HBoxContainer/PanelContainer/HBoxContainer/AlgorithmToggles/DiffusionButton.button_pressed
	subgoaling = $HBoxContainer/PanelContainer/HBoxContainer/AlgorithmToggles/SubgoalButton.button_pressed
	grace_period = $HBoxContainer/PanelContainer/HBoxContainer/TargetTimesteps/GracePeriodBox.value
	target_percent = $HBoxContainer/PanelContainer/HBoxContainer/TargetAgents/TargetBox.value
	print(beaconing)
	print(subgoaling)


func set_timestep_text(value: int) -> void:
	timestep_text.text = str(value)

func _on_program_timestep_changed(value: int) -> void:
	set_timestep_text(value)
		
func _on_pause_button_toggled(toggled_on: bool) -> void:
	get_tree().paused = toggled_on

func _on_reset_button_pressed() -> void:
	reset_sim_button.emit()

func _on_sim_speed_slider_value_changed(value: float) -> void:
	Engine.set_physics_ticks_per_second(value)

func _on_agent_box_value_changed(value: float) -> void:
	number_of_agents = int(value)

func _on_target_box_value_changed(value: float) -> void:
	target_percent = value
	
func _on_max_ts_box_value_changed(value: float) -> void:
	max_timesteps = int(value)

func _on_step_button_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		await get_tree().physics_frame
		await get_tree().physics_frame
		get_tree().paused = true


func _on_beacon_button_toggled(toggled_on: bool) -> void:
	beaconing = toggled_on
	
func _on_diffusion_button_toggled(toggled_on: bool) -> void:
	diffusing = toggled_on

func _on_subgoal_button_toggled(toggled_on: bool) -> void:
	subgoaling = toggled_on


func _on_program_t_1_changed(value: int) -> void:
	t_1_text.text = str(value)

func _on_program_t_2_changed(value: int) -> void:
	t_2_text.text = str(value)
