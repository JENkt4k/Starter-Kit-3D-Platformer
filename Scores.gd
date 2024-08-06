extends ItemList

var high_scores: SaveData = Global.scores
@export var buffer: int = 100



# Called when the node enters the scene tree for the first time.
func _ready():
	#var root: Window = get_tree().root

	var parent: MarginContainer = get_parent().get_parent()

	position = parent.size

	var width = position.x - buffer
	width =  width - (parent.get_theme_constant("margin_left") + parent.get_theme_constant("margin_right"))
	self.fixed_column_width = width/(self.max_columns)

	if high_scores:
		display_high_scores()

		#for score in high_scores.scores:
			#var key: String = score
			#var values = key.split(",")
			#if values.size() > 2:
				#self.add_item(values[0])
				#self.add_item(values[1])
				#self.add_item(values[2])

func sort_high_scores():
	var sorted_scores = high_scores.scores.keys()
	sorted_scores.sort_custom(dictionary_value_comparator) 
	 #.sort_custom(dictionary_value_comparator) #.keys().sort_custom(high_scores, "dictionary_value_comparator")
	return sorted_scores

# Comparator function to use with sort_custom
func dictionary_value_comparator(a, b) -> bool:
	return high_scores.scores[a] > high_scores.scores[b]

func display_high_scores():
	var sorted_players = sort_high_scores()
	#var list_container = $ListContainer  # Assume you have a VBoxContainer or similar node to hold the list items
#
	#list_container.clear()  # Clear any existing items
	for player in sorted_players:
		var key: String = player
		var values = key.split(",")
		if values.size() > 2:
			self.add_item(values[0])
			self.add_item(values[1])
			self.add_item(values[2])
		#var score = high_scores[player]
		#var list_item = Label.new()
		#list_item.text = "%s: %d" % [player, score]
		#list_container.add_child(list_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass #self.set_item_text(1,"%d" % [Global.score1])

func resize_columns():
	var parent: MarginContainer = get_parent().get_parent()
	var rec = parent.get_rect()
	position = parent.get_rect().size
	var width = position.x - buffer
	width =  width - (parent.get_theme_constant("margin_left") + parent.get_theme_constant("margin_right"))
	self.fixed_column_width = width/(self.max_columns)


func _on_scoreboard_resized():
	resize_columns()
	pass
	#pass # Replace with function body.


func _on_scoreboard_size_flags_changed():
	#resize_columns()
	pass # Replace with function body.
