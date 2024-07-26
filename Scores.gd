extends ItemList

var high_scores: SaveData = Global.scores
@export var buffer: int = 100



# Called when the node enters the scene tree for the first time.
func _ready():
	#var parent: Control = get_parent().get_parent()
	var root: Window = get_tree().root
	#print(root.to_string())
	var parent: MarginContainer = get_parent().get_parent()
	#print(parent.to_string())
	position = parent.size
	#print(self.fixed_column_width)
	#print(position.x)
	var width = position.x - buffer
	width =  width - (parent.get_theme_constant("margin_left") + parent.get_theme_constant("margin_right"))
	self.fixed_column_width = width/(self.max_columns)
	print(self.fixed_column_width)
	#high_scores = SaveData.load_or_create()
	if high_scores:
		#self.clear()
		#self.max_columns = 3
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

func resize_columns():
	var parent: MarginContainer = get_parent().get_parent()
	print(parent.to_string())
	var rec = parent.get_rect()
	position = parent.get_rect().size
	#print(self.fixed_column_width)
	#print(position.x)
	print(rec.size)
	var width = position.x - buffer
	width =  width - (parent.get_theme_constant("margin_left") + parent.get_theme_constant("margin_right"))
	self.fixed_column_width = width/(self.max_columns)
	print(self.fixed_column_width)


func _on_scoreboard_resized():
	resize_columns()
	pass
	#pass # Replace with function body.


func _on_scoreboard_size_flags_changed():
	#resize_columns()
	pass # Replace with function body.
