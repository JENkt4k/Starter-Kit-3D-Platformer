extends Node3D

const MAX_PLAYERS := 4
const PAUSE_ACTION := "pause_menu"
const SCOREBOARD_SCENE := preload("res://scoreboard.tscn")

# Reference to the GridContainer in your main scene
@onready var view_container = $GridContainer
@onready var player1_subview_container = $GridContainer/PlayerViewportContainer1
@onready var player2_subview_container = $GridContainer/PlayerViewportContainer2
@onready var player3_subview_container = $GridContainer/PlayerViewportContainer3
@onready var player4_subview_container = $GridContainer/PlayerViewportContainer4
@onready var minimap_subview_container = $GridContainer/MiniViewportContainer 
@onready var players = [$Player, $Player2, $Player3, $Player4]
@onready var player_views = [
	$GridContainer/PlayerViewportContainer1/SubViewport/View,
	$GridContainer/PlayerViewportContainer2/SubViewport/View2,
	$GridContainer/PlayerViewportContainer3/SubViewport/View3,
	$GridContainer/PlayerViewportContainer4/SubViewport/View4,
]
@onready var initials_entries = [
	$GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1,
	$GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2,
	$GridContainer/PlayerViewportContainer3/SubViewport/initialsentry3,
	$GridContainer/PlayerViewportContainer4/SubViewport/initialsentry4,
]
#@onready var player_1_iniital_entry = $GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1
@onready var player_1_iniital_entry_screen : Button = $GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1/ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#$ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#@onready var player_iniital_entry_screen = [$GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1/ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input, $GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2, $GridContainer/PlayerViewportContainer3/SubViewport/initialsentry3, $GridContainer/PlayerViewportContainer4/SubViewport/initialsentry4]

var pause_menu_layer: CanvasLayer
var resume_button: Button
var shared_scoreboard: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_pause_input()
	_build_pause_menu()
	_build_shared_scoreboard()
	_configure_player_slots()
	setViews(view_container, Global.player_count)
	#player_1_iniital_entry.visibility_changed.connect(func(): 
		#self._on_initialsentry_visibility_changed(1)
		#)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(PAUSE_ACTION):
		get_viewport().set_input_as_handled()
		_set_paused(!get_tree().paused)
	
func setViews(viewContainer: GridContainer, player_count: int):
	player_count = clampi(player_count, 1, MAX_PLAYERS)
	Global.player_count = player_count

	var player_containers = [player1_subview_container, player2_subview_container, player3_subview_container, player4_subview_container]
	# Set columns based on player count
	viewContainer.columns = 1 if player_count == 1 else 2

	# Hide all containers initially
	for container in player_containers:
		container.visible = false
	
	# Show necessary containers based on player count
	for i in range(player_count):
		player_containers[i].visible = true

	for i in range(MAX_PLAYERS):
		players[i].set_active(i < player_count)
		player_views[i].set_active(i < player_count)

	# Optional: Add a mini-map or score display for 3 players
	minimap_subview_container.visible = false
	if player_count == 3:
		minimap_subview_container.visible = true
		
	
func _ensure_pause_input() -> void:
	if !InputMap.has_action(PAUSE_ACTION):
		InputMap.add_action(PAUSE_ACTION)

	var has_escape := false
	var has_start := false
	for event in InputMap.action_get_events(PAUSE_ACTION):
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			has_escape = true
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_START:
			has_start = true

	if !has_escape:
		var escape_event := InputEventKey.new()
		escape_event.keycode = KEY_ESCAPE
		InputMap.action_add_event(PAUSE_ACTION, escape_event)

	if !has_start:
		var start_event := InputEventJoypadButton.new()
		start_event.device = -1
		start_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event(PAUSE_ACTION, start_event)

func _build_pause_menu() -> void:
	pause_menu_layer = CanvasLayer.new()
	pause_menu_layer.name = "PauseMenu"
	pause_menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu_layer.visible = false
	add_child(pause_menu_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 0)
	center.add_child(panel)

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	panel.add_child(buttons)

	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buttons.add_child(title)

	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.pressed.connect(_on_resume_pressed)
	buttons.add_child(resume_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.pressed.connect(_on_main_menu_pressed)
	buttons.add_child(menu_button)

	var quit_button := Button.new()
	quit_button.text = "Quit"
	quit_button.pressed.connect(_on_quit_pressed)
	buttons.add_child(quit_button)

func _build_shared_scoreboard() -> void:
	var scoreboard_layer := CanvasLayer.new()
	scoreboard_layer.name = "SharedScoreboard"
	add_child(scoreboard_layer)

	shared_scoreboard = SCOREBOARD_SCENE.instantiate()
	shared_scoreboard.visible = false
	scoreboard_layer.add_child(shared_scoreboard)

func _configure_player_slots() -> void:
	for i in range(MAX_PLAYERS):
		var player_id := i + 1
		players[i].configure_slot(player_id, initials_entries[i])
		player_views[i].set_player_id(player_id)

		if !players[i].is_connected("score_saved", _on_player_score_saved):
			players[i].connect("score_saved", _on_player_score_saved)

func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	pause_menu_layer.visible = paused
	if paused:
		resume_button.grab_focus()

func _on_resume_pressed() -> void:
	_set_paused(false)

func _on_main_menu_pressed() -> void:
	_set_paused(false)
	get_tree().change_scene_to_file("res://scenes/startgui.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_player_score_saved(_player) -> void:
	if shared_scoreboard.has_method("show_scores"):
		shared_scoreboard.show_scores()
	else:
		shared_scoreboard.visible = true

func _on_flag_body_entered(body: Node3D) -> void:
	if body != null and body.has_method("show_scene"):
		body.show_scene()



#func _on_initialsentry_visibility_changed(extra_arg_0: int) -> void:
	##player_1_iniital_entry_screen.grab_focus() 
	#player_1_iniital_entry_screen.focus_mode = Control.FOCUS_ALL
	##player_1_iniital_entry_screen.grab_focus()
	##player_iniital_entry_screen[0].get
	#pass # Replace with function body.


func _on_initialsentry_1_visibility_changed() -> void:
	#player_1_iniital_entry_screen.grab_focus() 
	player_1_iniital_entry_screen.focus_mode = Control.FOCUS_ALL
	pass # Replace with function body.


func _on_sub_viewport_gui_focus_changed(node: Control) -> void:
	print(node.name)
	pass # Replace with function body.
