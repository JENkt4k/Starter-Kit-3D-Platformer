extends Control

@onready var player_count_spin_box = $VBoxContainer/HBoxContainer/PlayerCountSpinBox
@onready var player_slider : HSlider = $VBoxContainer/PlayerSlider
# Called when the node enters the scene tree for the first time.
func _ready():
	player_slider.grab_focus()
	player_count_spin_box.value = 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_pressed():
	Global.player_count = player_count_spin_box.value
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_player_count_spin_box_value_changed(value: float) -> void:
	print("Number of players set to: ", value)
	pass # Replace with function body.


func _on_player_count_spin_box_changed() -> void:
	print("Number of players changed", player_count_spin_box.value)
	pass # Replace with function body.


func _on_player_slider_changed() -> void:
	player_count_spin_box.value = player_slider.value
	pass # Replace with function body.


func _on_player_slider_value_changed(value: float) -> void:
	player_count_spin_box.value = player_slider.value
	pass # Replace with function body.
