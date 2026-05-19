extends CanvasLayer

func set_coins(coins: int) -> void:
	var label := get_node_or_null("Coins") as Label
	if label == null:
		label = get_node_or_null("Coins2") as Label

	if label != null:
		label.text = str(coins)
