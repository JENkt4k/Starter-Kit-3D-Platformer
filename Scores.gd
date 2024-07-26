extends ItemList

var high_scores: SaveData = Global.scores


# Called when the node enters the scene tree for the first time.
func _ready():
	#high_scores = SaveData.load_or_create()
	if high_scores:
		#self.clear()
		self.max_columns = 3
		self.same_column_width = true
		#self.add_item("Initials")
		#self.add_item("Coins (?Time)")
		#self.add_item("Coins")
		for score in high_scores.scores:
			var key: String = score
			var values = key.split(",")
			if values.size() > 2:
				self.add_item(values[0])
				self.add_item(values[1])
				self.add_item(values[2])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass #self.set_item_text(1,"%d" % [Global.score1])

