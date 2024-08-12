extends Node

var scores: SaveData

var player_count: int = 1

func _ready():
	scores = SaveData.load_or_create("user://testdata.tres")#SaveData.data_path)

#var score1 = 0
#var score2 = 0

