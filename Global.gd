extends Node

var scores: SaveData

var player_count: int = 1
var victory_results: Array[Dictionary] = []

func _ready() -> void:
	scores = SaveData.load_or_create("user://testdata.tres")

func get_gpu_name() -> String:
	var rendering_device := RenderingServer.get_rendering_device()
	if rendering_device == null:
		return "Unavailable (headless)"
	return rendering_device.get_device_name()

func _is_steam_deck() -> bool:
	return get_gpu_name().contains("RADV VANGOGH") or OS.get_processor_name().contains("AMD CUSTOM APU 0405")
