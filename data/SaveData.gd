class_name SaveData extends Resource
@export var scores: Dictionary = {} # "name,score,time":<score int>
#@export var data_path = "user://testdata.tres"
var data_path = "user://testdata.tres"

func save()->void:
	ResourceSaver.save(self, data_path)
	
static func load_or_create(_data_path) -> SaveData:
	#data_path = _data_path
	var res: SaveData = load(_data_path) as SaveData
	if !res:
		res = SaveData.new()
		res.data_path = _data_path
	return res
	
	
