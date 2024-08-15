extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_countdown_timer_timeout() -> void:
	$VBoxContainer/Start.grab_focus()
	self.visible = true


#func _on_countdown_timer_ready() -> void:
	#print("_on_countdown_timer_ready")
