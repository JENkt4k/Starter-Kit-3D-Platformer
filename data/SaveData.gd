class_name SaveData extends Resource
@export var scores: Dictionary = {} # "name,score,time":<score int>

func save()->void:
	ResourceSaver.save(self, "user://testdata.tres")
	
static func load_or_create() -> SaveData:
	var res: SaveData = load("user://testdata.tres") as SaveData
	if !res:
		res = SaveData.new()
	return res
	
	
