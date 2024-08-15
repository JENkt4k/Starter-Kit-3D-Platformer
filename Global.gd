extends Node

var scores: SaveData

var player_count: int = 1

func _ready():
	scores = SaveData.load_or_create("user://testdata.tres")#SaveData.data_path)

func _is_steam_deck() -> bool: # 1
	if RenderingServer.get_rendering_device().get_device_name().contains("RADV VANGOGH") or OS.get_processor_name().contains("AMD CUSTOM APU 0405"): # 2
		return true
	else: # 3
		return false
