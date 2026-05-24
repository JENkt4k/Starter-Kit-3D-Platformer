extends Control

@warning_ignore("unused_signal")
signal saved

@export var outputLine: TextEdit
@export var player_id := 1

@onready var display_line := $ButtonColumnVBox/DisplayLineEdit as LineEdit
@onready var keyboard_rows := [
	$ButtonColumnVBox/ButtonRowHBox_1,
	$ButtonColumnVBox/ButtonRowHBox_2,
	$ButtonColumnVBox/ButtonRowHBox_3,
	$ButtonColumnVBox/ButtonRowHBox_Numbers,
	$ButtonColumnVBox/ButtonRowHBox_Special,
]

var selected_row := 0
var selected_column := 0
var repeat_delay := 0.16
var move_repeat_timer := 0.0

func _ready() -> void:
	_disable_button_focus()
	_update_selection()

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return

	move_repeat_timer = maxf(move_repeat_timer - delta, 0.0)
	var move := _read_move()
	if move != Vector2i.ZERO and move_repeat_timer <= 0.0:
		_move_selection(move)
		move_repeat_timer = repeat_delay

	if Input.is_action_just_pressed("jump_%d" % [player_id]):
		_activate_selected_key()

func configure_player(slot_player_id: int) -> void:
	player_id = slot_player_id

func set_text(value: String) -> void:
	display_line.text = value
	display_line.caret_column = display_line.text.length()
	_update_selection()

func _disable_button_focus() -> void:
	for row in keyboard_rows:
		for child in row.get_children():
			if child is Button:
				var button := child as Button
				button.focus_mode = Control.FOCUS_NONE

func _read_move() -> Vector2i:
	var suffix := "%d" % [player_id]
	if Input.is_action_pressed("move_left_%s" % [suffix]):
		return Vector2i.LEFT
	if Input.is_action_pressed("move_right_%s" % [suffix]):
		return Vector2i.RIGHT
	if Input.is_action_pressed("move_forward_%s" % [suffix]):
		return Vector2i.UP
	if Input.is_action_pressed("move_back_%s" % [suffix]):
		return Vector2i.DOWN
	return Vector2i.ZERO

func _move_selection(move: Vector2i) -> void:
	if move.y != 0:
		selected_row = clampi(selected_row + move.y, 0, keyboard_rows.size() - 1)
		selected_column = mini(selected_column, _row_button_count(selected_row) - 1)

	if move.x != 0:
		selected_column = clampi(selected_column + move.x, 0, _row_button_count(selected_row) - 1)

	_update_selection()

func _row_button_count(row_index: int) -> int:
	return keyboard_rows[row_index].get_child_count()

func _selected_button() -> Button:
	return keyboard_rows[selected_row].get_child(selected_column) as Button

func _update_selection() -> void:
	for row_index in range(keyboard_rows.size()):
		var row = keyboard_rows[row_index]
		for column_index in range(row.get_child_count()):
			var button := row.get_child(column_index) as Button
			var selected := row_index == selected_row and column_index == selected_column
			button.modulate = Color(1.0, 0.86, 0.34, 1.0) if selected else Color.WHITE
			button.scale = Vector2(1.04, 1.04) if selected else Vector2.ONE

func _activate_selected_key() -> void:
	var key := _selected_button().name.split("_")[1]
	match key:
		"Space":
			display_line.insert_text_at_caret(" ")
		"Del":
			_delete_before_caret()
		"Left":
			display_line.caret_column = max(display_line.caret_column - 1, 0)
		"Right":
			display_line.caret_column = min(display_line.caret_column + 1, display_line.text.length())
		"Save":
			_save()
		_:
			display_line.insert_text_at_caret(key.strip_edges())

func _delete_before_caret() -> void:
	var caret := display_line.caret_column
	if caret > 0:
		display_line.delete_text(caret - 1, caret)
		display_line.caret_column = caret - 1

func _save() -> void:
	outputLine.text = display_line.text
	emit_signal("saved")

func _on_button_row_h_box_1_visibility_changed() -> void:
	_update_selection()

func _on_button_save_pressed() -> void:
	_save()
