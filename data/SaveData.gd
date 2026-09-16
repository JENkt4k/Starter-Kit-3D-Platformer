class_name SaveData extends Resource
@export var scores: Dictionary = {} # "name,score,time":<score int>
#@export var data_path = "user://testdata.tres"
var data_path = "user://testdata.tres"

func save() -> void:
	ResourceSaver.save(self, data_path)

static func load_or_create(save_path: String) -> SaveData:
	var save_data: SaveData
	if ResourceLoader.exists(save_path):
		save_data = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData

	if save_data == null:
		save_data = SaveData.new()

	save_data.data_path = save_path
	return save_data
	
	
