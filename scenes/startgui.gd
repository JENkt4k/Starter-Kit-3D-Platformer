extends Control

@onready var player_count_spin_box: SpinBox = $Overlay/MenuStack/PlayerControls/PlayerCountSpinBox
@onready var player_slider: HSlider = $Overlay/MenuStack/PlayerSlider
@onready var play_button: Button = $Overlay/MenuStack/ButtonList/Play
@onready var player_count_label: Label = $Overlay/MenuStack/PlayerControls/PlayerCountLabel
@onready var options_panel: PanelContainer = $Overlay/OptionsPanel
@onready var leaderboard_panel: PanelContainer = $Overlay/LeaderboardPanel
@onready var leaderboard_list: ItemList = $Overlay/LeaderboardPanel/Margin/VBox/LeaderboardList
@onready var system_check: Label = $Overlay/OptionsPanel/Margin/VBox/SystemCheck
@onready var steam_deck_badge: Label = $Overlay/OptionsPanel/Margin/VBox/SteamDeckBadge

func _ready() -> void:
	player_count_spin_box.value = clampi(Global.player_count, 1, 4)
	player_slider.value = player_count_spin_box.value
	_update_player_count_label()
	_update_system_info()
	_populate_leaderboard()
	play_button.grab_focus()

func _on_play_pressed() -> void:
	Global.player_count = clampi(int(player_count_spin_box.value), 1, 4)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_local_play_pressed() -> void:
	var next_count := int(player_count_spin_box.value) + 1
	if next_count > 4:
		next_count = 2
	player_count_spin_box.value = next_count
	player_slider.value = next_count
	_update_player_count_label()

func _on_options_pressed() -> void:
	options_panel.visible = !options_panel.visible
	leaderboard_panel.hide()

func _on_leaderboards_pressed() -> void:
	_populate_leaderboard()
	leaderboard_panel.visible = !leaderboard_panel.visible
	options_panel.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_player_count_spin_box_value_changed(value: float) -> void:
	player_slider.value = value
	_update_player_count_label()

func _on_player_slider_value_changed(value: float) -> void:
	player_count_spin_box.value = value
	_update_player_count_label()

func _update_player_count_label() -> void:
	var player_count := int(player_count_spin_box.value)
	player_count_label.text = "%d Player%s" % [player_count, "" if player_count == 1 else "s"]

func _populate_leaderboard() -> void:
	leaderboard_list.clear()
	leaderboard_list.max_columns = 3
	leaderboard_list.same_column_width = true
	leaderboard_list.add_item("Initials")
	leaderboard_list.add_item("Time")
	leaderboard_list.add_item("Coins")

	if Global.scores == null or Global.scores.scores.is_empty():
		leaderboard_list.add_item("AAA")
		leaderboard_list.add_item("00:00")
		leaderboard_list.add_item("0")
		return

	var score_keys := Global.scores.scores.keys()
	score_keys.sort_custom(func(a, b): return Global.scores.scores[a] > Global.scores.scores[b])
	for score_key in score_keys.slice(0, 8):
		var values := str(score_key).split(",")
		if values.size() >= 3:
			leaderboard_list.add_item(values[0])
			leaderboard_list.add_item(values[1])
			leaderboard_list.add_item(values[2])

func _update_system_info() -> void:
	system_check.text = "OS: %s\nDistro: %s\nCPU: %s\nGPU: %s" % [
		OS.get_name(),
		OS.get_distribution_name(),
		OS.get_processor_name(),
		RenderingServer.get_rendering_device().get_device_name()
	]
	steam_deck_badge.visible = Global._is_steam_deck()
