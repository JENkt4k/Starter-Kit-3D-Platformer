extends HBoxContainer
@export var displayLineEdit : LineEdit 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func _on_button_space_pressed() -> void:
	displayLineEdit.text += " "
	pass # Replace with function body.

func _on_button_del_pressed() -> void:
	displayLineEdit.delete_char_at_caret()
	pass # Replace with function body.


func _on_button_left_pressed() -> void:
	if displayLineEdit.caret_column >= 1:
		displayLineEdit.caret_column = displayLineEdit.caret_column -1
	pass # Replace with function body.


func _on_button_right_pressed() -> void:
	displayLineEdit.caret_column += 1
	pass # Replace with function body.


func _on_button_save_pressed() -> void:
	var outputText = displayLineEdit.text
	var outputEditor: TextEdit = $"../..".outputLine
	outputEditor.text = outputText
	outputEditor.grab_focus()
	pass # Replace with function body.
