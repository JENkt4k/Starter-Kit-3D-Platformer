extends Node3D

# Reference to the GridContainer in your main scene
@onready var view_container = $GridContainer
@onready var player1_subview_container = $GridContainer/PlayerViewportContainer1
@onready var player2_subview_container = $GridContainer/PlayerViewportContainer2
@onready var player3_subview_container = $GridContainer/PlayerViewportContainer3
@onready var player4_subview_container = $GridContainer/PlayerViewportContainer4
@onready var minimap_subview_container = $GridContainer/MiniViewportContainer 
@onready var player_1_iniital_entry = $GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1
@onready var player_1_iniital_entry_screen : Button = $GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1/ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#$ScoreMargin/MarginContainer2/VBoxContainer/KeyboardScreen/ButtonColumnVBox/ButtonRowHBox_1/Button_A
#@onready var player_iniital_entry_screen = [$GridContainer/PlayerViewportContainer1/SubViewport/initialsentry1/ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input, $GridContainer/PlayerViewportContainer2/SubViewport/initialsentry2, $GridContainer/PlayerViewportContainer3/SubViewport/initialsentry3, $GridContainer/PlayerViewportContainer4/SubViewport/initialsentry4]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setViews(view_container, Global.player_count)
	player_1_iniital_entry.visibility_changed.connect(func(): 
		self._on_initialsentry_visibility_changed(1)
		)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func setViews(viewContainer: GridContainer, player_count: int):
	var player_containers = [player1_subview_container, player2_subview_container, player3_subview_container, player4_subview_container]
	# Set columns based on player count
	viewContainer.columns = 1 if player_count == 1 else 2

	# Hide all containers initially
	for container in player_containers:
		container.visible = false
	
	# Show necessary containers based on player count
	for i in range(player_count):
		player_containers[i].visible = true
		

	# Optional: Add a mini-map or score display for 3 players
	if player_count == 3:
		minimap_subview_container.visible = true
		
	


func _on_initialsentry_visibility_changed(extra_arg_0: int) -> void:
	#player_1_iniital_entry_screen.grab_focus() 
	player_1_iniital_entry_screen.focus_mode = Control.FOCUS_ALL
	#player_1_iniital_entry_screen.grab_focus()
	#player_iniital_entry_screen[0].get
	pass # Replace with function body.


func _on_initialsentry_1_visibility_changed() -> void:
	#player_1_iniital_entry_screen.grab_focus() 
	player_1_iniital_entry_screen.focus_mode = Control.FOCUS_ALL
	pass # Replace with function body.


func _on_sub_viewport_gui_focus_changed(node: Control) -> void:
	print(node.name)
	pass # Replace with function body.
