extends Control

@onready var podium_slots := [
	$Viewport/SubViewport/VictoryWorld/PodiumSlots/Slot1,
	$Viewport/SubViewport/VictoryWorld/PodiumSlots/Slot2,
	$Viewport/SubViewport/VictoryWorld/PodiumSlots/Slot3,
	$Viewport/SubViewport/VictoryWorld/PodiumSlots/Slot4,
]
@onready var confetti_nodes := [$Confetti1, $Confetti2, $Confetti3, $Confetti4, $Confetti5]
@onready var play_again_button: Button = $Overlay/Margin/Layout/Actions/PlayAgain
@onready var main_menu_button: Button = $Overlay/Margin/Layout/Actions/MainMenu
@onready var quit_button: Button = $Overlay/Margin/Layout/Actions/Quit

func _ready() -> void:
	get_tree().paused = false
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_position_confetti()
	_populate_podium()
	play_again_button.grab_focus()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_position_confetti()

func _position_confetti() -> void:
	var size := get_viewport_rect().size
	var x_positions := [0.14, 0.31, 0.5, 0.69, 0.86]
	for i in range(confetti_nodes.size()):
		var confetti := confetti_nodes[i] as Node2D
		confetti.position = Vector2(size.x * x_positions[i], size.y * 0.13)

func _populate_podium() -> void:
	var results := _get_podium_results()
	for i in range(podium_slots.size()):
		var slot := podium_slots[i] as Node3D
		if i >= results.size():
			slot.visible = false
			continue

		var result := results[i]
		var rank := i + 1
		slot.visible = true
		_set_slot_labels(slot, result, rank)
		_show_player_model(slot, int(result["player_id"]))

func _set_slot_labels(slot: Node3D, result: Dictionary, rank: int) -> void:
	var rank_label := slot.get_node("RankLabel") as Label3D
	rank_label.text = "%d" % [rank]

	var name_label := slot.get_node("NameLabel") as Label3D
	var initials: String = str(result["initials"]).left(8)
	name_label.text = "%s\n%d coins\n%s" % [
		initials,
		int(result["coins"]),
		_format_time(float(result["time"])),
	]

func _show_player_model(slot: Node3D, player_id: int) -> void:
	var anchor := slot.get_node("CharacterAnchor") as Node3D
	for child in anchor.get_children():
		child.visible = false
		_prepare_display_model(child)

	var model := anchor.get_node_or_null("Player%dModel" % [player_id]) as Node3D
	if model == null:
		return

	model.visible = true
	_prepare_display_model(model)
	_play_idle(model)

func _get_podium_results() -> Array[Dictionary]:
	if !Global.victory_results.is_empty():
		return Global.victory_results

	var fallback: Array[Dictionary] = []
	for player_id in range(1, Global.player_count + 1):
		fallback.append({
			"player_id": player_id,
			"initials": "P%d" % [player_id],
			"coins": 0,
			"time": 0.0,
		})
	return fallback

func _format_time(seconds_float: float) -> String:
	var total_seconds := int(seconds_float)
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _prepare_display_model(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)

	if node is CollisionShape3D:
		var collider := node as CollisionShape3D
		collider.disabled = true

	if node is CPUParticles3D:
		var particles := node as CPUParticles3D
		particles.emitting = false

	if node is AudioStreamPlayer:
		var audio := node as AudioStreamPlayer
		audio.stop()

	for child in node.get_children():
		_prepare_display_model(child)

func _play_idle(character: Node) -> void:
	var animation := character.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation != null and animation.has_animation("idle"):
		animation.play("idle")

func _on_play_again_pressed() -> void:
	Global.victory_results.clear()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_main_menu_pressed() -> void:
	Global.victory_results.clear()
	get_tree().change_scene_to_file("res://scenes/startgui.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
