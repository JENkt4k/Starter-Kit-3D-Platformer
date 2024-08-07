extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var player_initials = "AAA"
@export var player_id = 1
@export var spawn_position : Node3D 

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0

var p1saved = false
var p2saved = false
var initialsNode
var InitialsNode2
var score_screen = false
var initials_entry 
#var initials_entry2 
#var initials_entry3
#var initials_entry4

#var high_scores: SaveData = Global.scores

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var endgame = false
#@onready var initials_entry = $"../GridContainer/PlayerViewportContainer1/SubViewport/initialsentry" #$"../GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2" $"../GridContainer/PlayerViewportContainer1/SubViewport/initialsentry"
#@onready var initials_entry2 = $"../GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2"#$"../GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2"
#$"../initialsentry2"

# Functions
#func _ready():
	#initials_entry.connect("save_complete", _on_save1_complete )
	#initials_entry2.connect("save_complete", _on_save2_complete )
	#ie2.player_id = player_id
	#ie2.player_coins = coins
func _ready():
	# this check is due to start screen using a copy of the main scene/player scenes (current script) 
	var current =  get_path().get_concatenated_names()
	if current.find("startgui") == -1:
		call_deferred("_initialize") # we are not in the start sceen
		
func is_set(object)->bool:
	if object == null:
		return false
	else:
		return true
	

func _initialize():
	if !is_set(initials_entry):
		initials_entry = get_node("../GridContainer/PlayerViewportContainer%d/SubViewport/initialsentry%d" % [player_id, player_id])
	#if !is_set(initials_entry2):
		#initials_entry2 = get_node("../GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2")
	#if !is_set(initials_entry3):
		#initials_entry3 = get_node("../GridContainer/PlayerViewportContainer3/SubViewport/initialsentry3")
	#if !is_set(initials_entry4):
		#initials_entry4 = get_node("../GridContainer/PlayerViewportContainer4/SubViewport/initialsentry4")

	if !is_set(initials_entry):
		print("Node not found: ./GridContainer/PlayerViewportContainer1/SubViewport/initialsentry")

	#if !is_set(initials_entry2): #initials_entry2 == null:
		#print("Node not found: ./GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2")
		#
	#if !is_set(initials_entry):
		#print("Node not found: ./GridContainer/PlayerViewportContainer3/SubViewport/initialsentry3")
#
	#if !is_set(initials_entry2): #initials_entry2 == null:
		#print("Node not found: ./GridContainer/PlayerViewportContainer4/SubViewport/initialsentry4")
		return
	
	
func apply_velocity(_delta):
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, _delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	

func _physics_process(_delta):
	# Handle functions
	handle_controls(_delta)
	handle_gravity(_delta)
	
	handle_effects(_delta)
	
	# Movement
	apply_velocity(_delta)
	#var applied_velocity: Vector3
	#
	#applied_velocity = velocity.lerp(movement_velocity, _delta * 10)
	#applied_velocity.y = -gravity
	#
	#velocity = applied_velocity
	#move_and_slide()
	
	# Rotation
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, _delta * 10)
	
	# Falling/respawning
	if endgame:
		_end_game()
		
	if score_screen:
		_show_scoreboard()
		
	if position.y < -10:
		_reload_game()
		#get_tree().reload_current_scene()
	
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
	
	coins += 1
	
	coin_collected.emit(coins)


func _on_flagcolision_body_entered(_body):
	#don't remove nodes in signal, use bool instead
	endgame = true
	#get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	#print("wtf")
	#pass # Replace with function body.
	
#func _add_highscore():
	#if high_scores:
		#var key = "%s_%d,%d,%d" % [player_initials,player_id,coins,coins]
		#high_scores.scores[key] = coins
		#high_scores.save()
		
func reset_body():
	position = spawn_position.position
	movement_velocity = Vector3.ZERO
	#velocity = Vector2.ZERO 
	
func _reload_game():
	endgame = false
	#falling doesnt end game
	#TODO: globals and lives, per player
	#get_tree().reload_current_scene()
	reset_body()
	
#called once for each player
func _end_game():
	#_add_highscore()
	endgame = false
	#TODO: get/save initials before scoreboard display
	show_scene()
	#get_tree().change_scene_to_file("res://scoreboard.tscn")
	#get_tree().change_scene_to_file("res://scenes/gameovergui.tscn")
	
func show_scene():
	#multi-player mode issue, lets get to 2 players
	#TODO: add second player
	if initials_entry == null:
		return
		
	initials_entry.connect("save_complete", _on_save_complete )

	initials_entry.player_id = player_id
	initials_entry.player_coins = coins
	initials_entry.refresh()
	#initials_entry2.connect("save_complete", _on_save2_complete )
	#initials_entry3.connect("save_complete", _on_save3_complete )
	#initials_entry4.connect("save_complete", _on_save4_complete )
	#if player_id == 1:
		#initials_entry.player_id = player_id
		#initials_entry.player_coins = coins
		#initials_entry.refresh()
	
	#if player_id == 2:
		#initials_entry2.player_id = player_id
		#initials_entry2.player_coins = coins
		#initials_entry2.refresh()
		#
	#if player_id == 3:
		#initials_entry3.player_id = player_id
		#initials_entry3.player_coins = coins
		#initials_entry3.refresh()
		#
	#if player_id == 4:
		#initials_entry4.player_id = player_id
		#initials_entry4.player_coins = coins
		#initials_entry4.refresh()
	
	initials_entry.visible = true  # Show the scene
	#initials_entry2.visible = true
	#initials_entry3.visible = true
	#initials_entry4.visible = true
	
func _on_save_complete():
	#maybe use a timer instead of saving each user?
	Global.player_count
	score_screen = true


#func _on_save1_complete():
	#if  Global.player_count == 1:
		#score_screen = true
		#return
	#if p2saved:
		#p2saved = false
		#p1saved = p2saved
		#score_screen = true
		##get_tree().change_scene_to_file("res://scoreboard.tscn")
	#else:
		#p1saved = true


#func _on_save2_complete():
	#if p1saved:
		#p1saved = false
		#p2saved = p1saved
		#score_screen = true
		##get_tree().change_scene_to_file("res://scoreboard.tscn")
	#else:
		#p2saved = true
		#
#
#func _on_save3_complete():
	#if p1saved:
		#p1saved = false
		#p2saved = p1saved
		#score_screen = true
		##get_tree().change_scene_to_file("res://scoreboard.tscn")
	#else:
		#p2saved = true
		#
		#
#func _on_save4_complete():
	#if p1saved:
		#p1saved = false
		#p2saved = p1saved
		#score_screen = true
		##get_tree().change_scene_to_file("res://scoreboard.tscn")
	#else:
		#p2saved = true
		
func _show_scoreboard():
	get_tree().change_scene_to_file("res://scoreboard.tscn")
	
