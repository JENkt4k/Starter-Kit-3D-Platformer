extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	self.text = "" # 1

	self.text += "OS: " + OS.get_name() + "\n" # 2
	self.text += "Distro: " + OS.get_distribution_name() + "\n" # 3
	self.text += "CPU: " + OS.get_processor_name() + "\n" # 4
	self.text += "GPU: " + RenderingServer.get_rendering_device().get_device_name() + "\n" # 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _is_steam_deck() -> bool: # 1
	if RenderingServer.get_rendering_device().get_device_name().contains("RADV VANGOGH") or OS.get_processor_name().contains("AMD CUSTOM APU 0405"): # 2
		return true
	else: # 3
		return false
