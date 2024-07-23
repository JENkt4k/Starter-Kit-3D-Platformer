extends CanvasLayer

func _on_coin_collected(coins):
	
	$Coins.text = str(coins)


#func _on_player_2_coin_collected(coins):
	#$Coins2.text = str(coins)
