#fixed controls issue as much as possible, focus on last player keyboard
#multiplayer input is currenly and issue: https://github.com/godotengine/godot-proposals/issues/4295
extends Control

signal save_complete

@export var scoreboard: Control
@export var player_stats: Label
@export var player_initials: String = "PLA"
@export var player_id: int = 0
@export var player_coins: int = 0
@export var player_time: String = "00:00"

@onready var keyboard_screen_a : Control = $ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#keyboard_screen_ ButtonColumnVBox/ButtonRowHBox_1/Button_A @onready var keyboard_screen : Control = $ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen
@onready var line :TextEdit = $ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input

var high_scores: SaveData = Global.scores


# Called when the node enters the scene tree for the first time.
func _ready():
	#line.grab_focus()
	keyboard_screen_a.focus_mode = FOCUS_ALL
	#keyboard_screen.grab_focus()
	#$ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen.grab_focus()
	#$ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input.grab_focus()
		 # Assuming you have a LineEdit or TextEdit for text input
	#var text_field = $ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input  # Adjust the path to your actual node

	# Connect the focus event to trigger the virtual keyboard
	#text_field.connect("focus_entered", self, "_on_focus_entered")
	#text_field.connect("focus_exited", self, "_on_focus_exited")
	#$ScoreMargin/MarginContainer2/VBoxContainer/OnscreenKeyboard.show() #.visible = true
	#$ScoreMargin/MarginContainer2/VBoxContainer/OnscreenKeyboard.grab_focus()
	#var _values = "Player %s #%d Coins: %d Time %s" % [player_initials,player_id,player_coins,player_time]
	#self = values
	pass # Replace with function body.
	
func _add_highscore():
	if high_scores:
		var key = "%s_%d,%d,%d" % [player_initials,player_id,player_coins,player_coins]
		high_scores.scores[key] = player_coins
		high_scores.save()
	
func refresh():
	player_stats.text = "Player %s #%d Coins: %d Time %s" % [player_initials,player_id,player_coins,player_time]
	#line.grab_focus()
	keyboard_screen_a.focus_mode = FOCUS_ALL  #.set_focus_mode()

######################################################################################################
#func handle_controls(delta):
	#
	## Player differenciable UI Movement
	#
	#var input := Vector3.ZERO
	#
	#input.x = Input.get_axis("ui_left_%s" % [player_id], "ui_right_%s" % [player_id])
	#input.z = Input.get_axis("ui_up_%s" % [player_id], "ui_down_%s" % [player_id])
	#
	##input = input.rotaed(Vector3.UP, view.rotation.y)
	#
	#if input.length() > 1:
		#input = input.normalized()
		#
	##movement_velocity = input * movement_speed * delta
	#
	## Jumping
	#
	##if Input.is_action_just_pressed("jump_%s" % [player_id]):
		#
		##if jump_single or jump_double:
			##jump()
######################################################################################################
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _show_scoreboard():
	scoreboard.visible = true
	#get_tree().change_scene_to_file("res://scoreboard.tscn")

func _on_save_pressed():
	player_initials = $ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input.text
	if high_scores:
		var key = "%s_%d,%d,%d" % [player_initials,player_id,player_coins,player_coins]
		high_scores.scores[key] = player_coins
		high_scores.save()
		emit_signal("save_complete")
	
	pass # Replace with function body.



#func _on_entry_line_focus_entered() -> void:
	##$ScoreMargin/MarginContainer2/VBoxContainer/OnscreenKeyboard.visible = true
	#pass # Replace with function body.


func _on_initials_input_focus_entered() -> void:
	#OS.show_virtual_keyboard()
	var is_supported = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
	if is_supported:
		DisplayServer.virtual_keyboard_show("")
	pass # Replace with function body.


func _on_initials_input_focus_exited() -> void:
	var is_supported = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
	if is_supported:
		DisplayServer.virtual_keyboard_hide()
	#OS.hide_virtual_keyboard()
	pass # Replace with function body.


func _on_keyboard_screen_saved() -> void:
	player_initials = $ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input.text
	if high_scores:
		var key = "%s_%d,%d,%d" % [player_initials,player_id,player_coins,player_coins]
		high_scores.scores[key] = player_coins
		high_scores.save()
		emit_signal("save_complete")
	pass # Replace with function body.
