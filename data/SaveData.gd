class_name SaveData extends Resource
@export var scores: Dictionary = {} # "name,score,time":<score int>
#@export var data_path = "user://testdata.tres"
static var data_path = "user://testdata.tres"

func save()->void:
	ResourceSaver.save(self, data_path)
	
static func load_or_create(data_path) -> SaveData:
	var res: SaveData = load(data_path) as SaveData
	if !res:
		res = SaveData.new()
	return res
	
	
