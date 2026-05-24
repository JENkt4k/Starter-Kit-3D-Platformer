extends HBoxContainer
@export var displayLineEdit : LineEdit 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func _on_button_space_pressed() -> void:
	displayLineEdit.insert_text_at_caret(" ")

func _on_button_del_pressed() -> void:
	var caret := displayLineEdit.caret_column
	if caret > 0:
		displayLineEdit.delete_text(caret - 1, caret)
		displayLineEdit.caret_column = caret - 1


func _on_button_left_pressed() -> void:
	displayLineEdit.caret_column = max(displayLineEdit.caret_column - 1, 0)


func _on_button_right_pressed() -> void:
	displayLineEdit.caret_column = min(displayLineEdit.caret_column + 1, displayLineEdit.text.length())


func _on_button_save_pressed() -> void:
	var outputText = displayLineEdit.text
	var outputEditor: TextEdit = $"../..".outputLine
	outputEditor.text = outputText
	pass # Replace with function body.
