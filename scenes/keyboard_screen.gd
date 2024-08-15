extends Control
signal saved 

@export var outputLine: TextEdit
@onready var buttonContainer = %ButtonRowHBox_1 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$ButtonColumnVBox/ButtonRowHBox_1/Button_A.grab_focus()
	focus_button()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func focus_button():
	if buttonContainer:
		var button = buttonContainer.get_child(0)
		if button is Button:
			button.grab_focus()


func _on_button_row_h_box_1_visibility_changed() -> void:
	focus_button()
	pass # Replace with function body.


func _on_button_save_pressed() -> void:
	outputLine.text = $ButtonColumnVBox/DisplayLineEdit.text
	emit_signal("saved")
	pass # Replace with function body.
