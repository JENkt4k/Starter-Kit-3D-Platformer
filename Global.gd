extends Node

var scores: SaveData

func _ready():
	scores = SaveData.load_or_create()

#var score1 = 0
#var score2 = 0

