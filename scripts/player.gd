extends CharacterBody3D

signal coin_collected
signal score_saved(player)

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var player_initials: String = "AAA"
@export var player_id = 1
@export var spawn_position : Node3D 
@export var active = true

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0
var elapsed_time = 0.0
var finished = false
var has_saved_initials = false
var require_initials_prompt = true

var initials_entry : Control

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var endgame = false

# Functions

func _ready():
	if !active:
		_set_inactive_display_mode()
		return

	# this check is due to start screen using a copy of the main scene/player scenes (current script) 
	var current =  get_path().get_concatenated_names()
	if current.find("startgui") == -1:
		call_deferred("_initialize") # we are not in the start sceen

func _set_inactive_display_mode() -> void:
	set_physics_process(false)
	set_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	if has_node("Collider"):
		$Collider.disabled = true
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

func configure_slot(slot_player_id: int, slot_initials_entry: Control) -> void:
	player_id = slot_player_id
	initials_entry = slot_initials_entry
	if initials_entry != null and !initials_entry.is_connected("save_complete", _on_save_complete):
		initials_entry.connect("save_complete", _on_save_complete)
		
func is_set(object)->bool:
	if object == null:
		return false
	else:
		return true
	

func _initialize():
	if !is_set(initials_entry):
		print("Initials entry not configured for player %d" % [player_id])
	
func set_active(value: bool) -> void:
	active = value
	visible = value
	set_physics_process(value)
	set_process(value)
	set_process_input(value)
	set_process_unhandled_input(value)

	if has_node("Collider"):
		$Collider.disabled = !value

	if !value:
		movement_velocity = Vector3.ZERO
		velocity = Vector3.ZERO
		gravity = 0
		particles_trail.emitting = false
		sound_footsteps.stream_paused = true
	elif spawn_position != null:
		reset_body()

func reset_for_level() -> void:
	finished = false
	elapsed_time = 0.0
	coins = 0
	coin_collected.emit(coins)
	if initials_entry != null:
		initials_entry.hide()
	reset_body()

func reset_campaign_identity() -> void:
	has_saved_initials = false
	require_initials_prompt = true
	player_initials = ""
	
	
func apply_velocity(_delta):
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, _delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	

func _physics_process(_delta):
	if !active:
		return

	if finished:
		movement_velocity = Vector3.ZERO
		particles_trail.emitting = false
		sound_footsteps.stream_paused = true
		handle_gravity(_delta)
		apply_velocity(_delta)
		animation.play("idle", 0)
		return

	elapsed_time += _delta

	# Handle functions
	handle_controls(_delta)
	handle_gravity(_delta)
	
	handle_effects(_delta)
	
	# Movement
	apply_velocity(_delta)
	
	# Rotation
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, _delta * 10)
	
	# Falling/respawning
	if endgame:
		_end_game()
		
	if position.y < -10:
		reset_body()
	
	# Animation for scale (jumping and landing)	
	model.scale = model.scale.lerp(Vector3(1, 1, 1), _delta * 10)
	
	# Animation when landing
	
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects(delta):
	
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			animation.play("walk", 0, speed_factor)
				
			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor
				
			if speed_factor > 0.75:
				particles_trail.emitting = true
				
		else:
			animation.play("idle", 0)
	else:
		animation.play("jump", 0)

# Handle movement input

func handle_controls(delta):
	
	# Movement
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left_%s" % [player_id], "move_right_%s" % [player_id])
	input.z = Input.get_axis("move_forward_%s" % [player_id], "move_back_%s" % [player_id])
	
	#input = input.rotaed(Vector3.UP, view.rotation.y)
	
	if input.length() > 1:
		input = input.normalized()
		
	movement_velocity = input * movement_speed * delta
	
	# Jumping
	
	if Input.is_action_just_pressed("jump_%s" % [player_id]):
		
		if jump_single or jump_double:
			jump()

# Handle gravity

func handle_gravity(delta):
	
	gravity += 25 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func jump():
	
	Audio.play("res://sounds/jump.ogg")
	
	gravity = -jump_strength
	
	model.scale = Vector3(0.5, 1.5, 0.5)
	
	if jump_single:
		jump_single = false;
		jump_double = true;
	else:
		jump_double = false;

# Collecting coins

func collect_coin():
	if !active:
		return
	
	coins += 1
	
	coin_collected.emit(coins)

func reset_body():
	endgame = false
	if spawn_position != null:
		position = spawn_position.position
	movement_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	gravity = 0
	
#called once for each player
func _end_game():
	endgame = false
	#get/save initials before scoreboard display
	show_scene()
	
func show_scene():
	#multi-player mode, each player has an "instance" of this script
	if !active:
		return
	if finished:
		return

	if initials_entry == null:
		return

	finished = true
	
	if 	!initials_entry.is_connected("save_complete", _on_save_complete ):
		initials_entry.connect("save_complete", _on_save_complete )

	initials_entry.player_id = player_id
	initials_entry.player_initials = player_initials
	initials_entry.player_coins = coins
	initials_entry.player_time = _format_elapsed_time()
	initials_entry.refresh()

	if has_saved_initials and !require_initials_prompt and initials_entry.has_method("save_current_score"):
		initials_entry.save_current_score(player_initials)
		return

	initials_entry.show() #.visible = true  # Show the scene
	
func _on_save_complete():
	if initials_entry != null:
		player_initials = initials_entry.player_initials
		has_saved_initials = true
		initials_entry.hide()
	score_saved.emit(self)

func _format_elapsed_time() -> String:
	var total_seconds := int(elapsed_time)
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
