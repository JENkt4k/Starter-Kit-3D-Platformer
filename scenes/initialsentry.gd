extends Control

signal save_complete

@export var player_initials: String = "PLA"
@export var player_id: int = 0
@export var player_coins: int = 0
@export var player_time: String = "00:00"

var high_scores: SaveData = Global.scores

# Called when the node enters the scene tree for the first time.
func _ready():
	#var _values = "Player %s #%d Coins: %d Time %s" % [player_initials,player_id,player_coins,player_time]
	#self = values
	pass # Replace with function body.
	
func _add_highscore():
	if high_scores:
		var key = "%s_%d,%d,%d" % [player_initials,player_id,player_coins,player_coins]
		high_scores.scores[key] = player_coins
		high_scores.save()
	
func refresh():
	$ScoreMargin/MarginContainer2/VBoxContainer/HBoxContainer3/PlayerStatLabel.text = "Player %s #%d Coins: %d Time %s" % [player_initials,player_id,player_coins,player_time]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_save_pressed():
	player_initials = $ScoreMargin/MarginContainer2/VBoxContainer/EntryLine/initials_input.text
	if high_scores:
		var key = "%s_%d,%d,%d" % [player_initials,player_id,player_coins,player_coins]
		high_scores.scores[key] = player_coins
		high_scores.save()
		emit_signal("save_complete")
	
	pass # Replace with function body.

