extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var player_initials = "AAA"
@export var player_id = 1

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0

var high_scores: SaveData = Global.scores

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var endgame = false

# Functions

func _physics_process(delta):
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects(delta)
	
	# Movement

	var applied_velocity: Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# Falling/respawning
	if endgame:
		_end_game()
		
	if position.y < -10:
		_reload_game()
		#get_tree().reload_current_scene()
	
	# Animation for scale (jumping and landing)
	
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
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
	
	coins += 1
	
	coin_collected.emit(coins)


func _on_flagcolision_body_entered(body):
	#don't remove nodes in signal, use bool instead
	endgame = true
	#get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	#print("wtf")
	#pass # Replace with function body.
	
func _add_highscore():
	if high_scores:
		var key = "%s_%d,%d,%d" % [player_initials,player_id,coins,coins]
		high_scores.scores[key] = coins
		high_scores.save()
	
func _reload_game():
	endgame = false
	#falling doesnt end game
	#TODO: globals and lives, per player
	get_tree().reload_current_scene()
	
func _end_game():
	_add_highscore()
	endgame = false
	get_tree().change_scene_to_file("res://scoreboard.tscn")
	#get_tree().change_scene_to_file("res://scenes/gameovergui.tscn")
