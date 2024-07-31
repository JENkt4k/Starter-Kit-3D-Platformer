extends Label
@export var player_initials: String = "PLA"
@export var player_id: int = 0
@export var player_coins: int = 0
@export var player_time: String = "00:00"

# Called when the node enters the scene tree for the first time.
func _ready():
	var values = "Player %s #%d Coins: %d Time %s" % [player_initials,player_id,player_coins,player_time]
	self.text = values
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
