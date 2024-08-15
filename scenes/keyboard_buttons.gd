extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in self.get_children():
		var currentButton : Button = button
		var keyValue = currentButton.name.split("_")[1]
		currentButton.pressed.connect(func (): 
			_on_button_pressed(keyValue)
			)
		print(button.name)
		print(keyValue)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed(keyValue):
	$"../DisplayLineEdit".text += keyValue
	pass
