extends Node3D

const MAX_PLAYERS := 4
const PAUSE_ACTION := "pause_menu"
const SCOREBOARD_SCENE := preload("res://scoreboard.tscn")

@export var level_scenes: Array[PackedScene] = []

# Reference to the GridContainer in your main scene
@onready var view_container = $GridContainer
@onready var player1_subview_container = $GridContainer/PlayerViewportContainer1
@onready var player2_subview_container = $GridContainer/PlayerViewportContainer2
@onready var player3_subview_container = $GridContainer/PlayerViewportContainer3
@onready var player4_subview_container = $GridContainer/PlayerViewportContainer4
@onready var minimap_subview_container = $GridContainer/MiniViewportContainer 
@onready var embedded_world = $World
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
@onready var player_subviewports = [
	$GridContainer/PlayerViewportContainer1/SubViewport,
	$GridContainer/PlayerViewportContainer2/SubViewport,
	$GridContainer/PlayerViewportContainer3/SubViewport,
	$GridContainer/PlayerViewportContainer4/SubViewport,
]
#@onready var player_1_iniital_entry = $GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1
@onready var player_1_iniital_entry_screen : Button = $GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1/ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#$ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#@onready var player_iniital_entry_screen = [$GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1/ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input, $GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2, $GridContainer/PlayerViewportContainer3/SubViewport/initialsentry3, $GridContainer/PlayerViewportContainer4/SubViewport/initialsentry4]

var pause_menu_layer: CanvasLayer
var resume_button: Button
var level_complete_menu_layer: CanvasLayer
var continue_button: Button
var level_complete_title: Label
var scoreboards: Array[Control] = []
var current_level_index := 0
var finished_player_ids := {}
var current_level_root: Node3D
var level_transition_pending := false
var campaign_results_by_level := {}
var finish_queue: Array = []
var queued_finish_player_ids := {}
var active_initials_player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.victory_results.clear()
	_ensure_pause_input()
	_build_pause_menu()
	_build_level_complete_menu()
	_build_player_scoreboards()
	_configure_player_slots()
	setViews(view_container, Global.player_count)
	_load_level(current_level_index)
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
		if level_complete_menu_layer != null and level_complete_menu_layer.visible:
			return
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
		
func _load_level(level_index: int) -> void:
	finished_player_ids.clear()
	finish_queue.clear()
	queued_finish_player_ids.clear()
	active_initials_player = null
	level_transition_pending = false
	_hide_level_complete_menu()
	_hide_scoreboards()

	if current_level_root != null:
		if current_level_root != embedded_world:
			current_level_root.queue_free()
		current_level_root = null

	if level_scenes.size() > 0:
		if embedded_world != null:
			embedded_world.queue_free()
			embedded_world = null

		current_level_index = wrapi(level_index, 0, level_scenes.size())
		current_level_root = level_scenes[current_level_index].instantiate() as Node3D
		current_level_root.name = "LoadedLevel"
		add_child(current_level_root)
		move_child(current_level_root, 0)
	else:
		current_level_index = 0
		current_level_root = $World

	if current_level_index == 0:
		_start_campaign_identity_prompt()
	else:
		_use_saved_campaign_identities()

	_connect_level_goal(current_level_root)

	for player in players:
		player.reset_for_level()

func _advance_level() -> void:
	level_transition_pending = false
	if level_scenes.is_empty():
		_reset_current_level()
	elif current_level_index >= level_scenes.size() - 1:
		_prepare_victory_results()
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
	else:
		_load_level(current_level_index + 1)

func _reset_current_level() -> void:
	finished_player_ids.clear()
	finish_queue.clear()
	queued_finish_player_ids.clear()
	active_initials_player = null
	level_transition_pending = false
	_hide_level_complete_menu()
	_hide_scoreboards()
	if current_level_index == 0:
		_start_campaign_identity_prompt()
	for player in players:
		player.reset_for_level()

func _start_campaign_identity_prompt() -> void:
	campaign_results_by_level.clear()
	for player in players:
		if player.has_method("reset_campaign_identity"):
			player.reset_campaign_identity()

func _use_saved_campaign_identities() -> void:
	for player in players:
		player.require_initials_prompt = false

func _connect_level_goal(level_root: Node) -> void:
	if level_root == null:
		return

	var goal := level_root.find_child("flagcolision", true, false) as Area3D
	if goal == null:
		push_warning("Loaded level does not contain an Area3D named flagcolision.")
		return

	var callback := Callable(self, "_on_flag_body_entered")
	if !goal.is_connected("body_entered", callback):
		goal.connect("body_entered", callback)

func _hide_scoreboards() -> void:
	for scoreboard in scoreboards:
		scoreboard.visible = false
	
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

func _build_level_complete_menu() -> void:
	level_complete_menu_layer = CanvasLayer.new()
	level_complete_menu_layer.name = "LevelCompleteMenu"
	level_complete_menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	level_complete_menu_layer.visible = false
	add_child(level_complete_menu_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_complete_menu_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_complete_menu_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	center.add_child(panel)

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	panel.add_child(buttons)

	level_complete_title = Label.new()
	level_complete_title.text = "Level Complete"
	level_complete_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buttons.add_child(level_complete_title)

	continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.pressed.connect(_on_continue_pressed)
	buttons.add_child(continue_button)

	var replay_button := Button.new()
	replay_button.text = "Replay Level"
	replay_button.pressed.connect(_on_replay_level_pressed)
	buttons.add_child(replay_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.pressed.connect(_on_main_menu_pressed)
	buttons.add_child(menu_button)

	var quit_button := Button.new()
	quit_button.text = "Quit"
	quit_button.pressed.connect(_on_quit_pressed)
	buttons.add_child(quit_button)

func _show_level_complete_menu() -> void:
	if level_scenes.is_empty():
		level_complete_title.text = "Level Complete"
		continue_button.text = "Restart Level"
	elif current_level_index >= level_scenes.size() - 1:
		level_complete_title.text = "Campaign Complete"
		continue_button.text = "View Victory"
	else:
		level_complete_title.text = "Level Complete"
		continue_button.text = "Continue to Level %d" % [current_level_index + 2]

	level_complete_menu_layer.visible = true
	get_tree().paused = true
	continue_button.grab_focus()

func _hide_level_complete_menu() -> void:
	if level_complete_menu_layer != null:
		level_complete_menu_layer.visible = false

func _build_player_scoreboards() -> void:
	scoreboards.clear()
	for i in range(MAX_PLAYERS):
		var scoreboard := SCOREBOARD_SCENE.instantiate() as Control
		scoreboard.visible = false
		scoreboard.name = "scoreboard%d" % [i + 1]
		player_subviewports[i].add_child(scoreboard)
		scoreboard.set_anchors_preset(Control.PRESET_FULL_RECT)
		scoreboards.append(scoreboard)

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
	_hide_level_complete_menu()
	get_tree().change_scene_to_file("res://scenes/startgui.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_player_score_saved(player) -> void:
	if active_initials_player == player:
		active_initials_player = null

	var player_index: int = player.player_id - 1
	if player_index < 0 or player_index >= scoreboards.size():
		_process_next_finish_prompt()
		return

	finished_player_ids[player.player_id] = true
	_record_campaign_result(player)

	var scoreboard := scoreboards[player_index]
	if scoreboard.has_method("show_scores"):
		scoreboard.show_scores()
	else:
		scoreboard.visible = true

	if finished_player_ids.size() >= Global.player_count and !level_transition_pending:
		level_transition_pending = true
		_show_level_complete_menu()
	else:
		_process_next_finish_prompt()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	_hide_level_complete_menu()
	_advance_level()

func _on_replay_level_pressed() -> void:
	get_tree().paused = false
	_hide_level_complete_menu()
	if level_scenes.is_empty():
		_reset_current_level()
	else:
		_load_level(current_level_index)

func _on_flag_body_entered(body: Node3D) -> void:
	if body != null and body.has_method("show_scene"):
		_queue_finish_prompt(body)

func _queue_finish_prompt(player) -> void:
	if player == null:
		return
	if !player.active or player.finished:
		return
	if finished_player_ids.has(player.player_id) or queued_finish_player_ids.has(player.player_id):
		return

	queued_finish_player_ids[player.player_id] = true
	finish_queue.append(player)
	_process_next_finish_prompt()

func _process_next_finish_prompt() -> void:
	if active_initials_player != null:
		return

	while !finish_queue.is_empty():
		var player = finish_queue.pop_front()
		queued_finish_player_ids.erase(player.player_id)
		if player == null or !player.active or player.finished or finished_player_ids.has(player.player_id):
			continue

		active_initials_player = player
		player.show_scene()
		return

func _record_campaign_result(player) -> void:
	if !campaign_results_by_level.has(current_level_index):
		campaign_results_by_level[current_level_index] = {}

	var initials: String = player.player_initials
	if player.initials_entry != null:
		initials = player.initials_entry.player_initials

	campaign_results_by_level[current_level_index][player.player_id] = {
		"player_id": player.player_id,
		"initials": initials,
		"coins": player.coins,
		"time": player.elapsed_time,
	}

func _prepare_victory_results() -> void:
	var totals := {}
	for level_results in campaign_results_by_level.values():
		for result in level_results.values():
			var player_id: int = result["player_id"]
			if !totals.has(player_id):
				totals[player_id] = {
					"player_id": player_id,
					"initials": result["initials"],
					"coins": 0,
					"time": 0.0,
				}

			totals[player_id]["initials"] = result["initials"]
			totals[player_id]["coins"] += result["coins"]
			totals[player_id]["time"] += result["time"]

	var results: Array[Dictionary] = []
	for player_id in totals.keys():
		results.append(totals[player_id])

	results.sort_custom(_compare_victory_results)
	Global.victory_results = results

func _compare_victory_results(a: Dictionary, b: Dictionary) -> bool:
	if a["coins"] == b["coins"]:
		return a["time"] < b["time"]
	return a["coins"] > b["coins"]



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
