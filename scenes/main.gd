extends Node3D

# Reference to the GridContainer in your main scene
@onready var view_container = $GridContainer
@onready var player1_subview_container = $GridContainer/PlayerViewportContainer1
@onready var player2_subview_container = $GridContainer/PlayerViewportContainer2
@onready var player3_subview_container = $GridContainer/PlayerViewportContainer3
@onready var player4_subview_container = $GridContainer/PlayerViewportContainer4
@onready var minimap_subview_container = $GridContainer/MiniViewportContainer 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setViews(view_container, Global.player_count)
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
		
	
