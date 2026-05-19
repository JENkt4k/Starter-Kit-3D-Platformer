extends Control
@onready var gameover_buttons : Control = $gameovergui

var timerS

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_timer(init: int = 0):
	return init

func show_scores() -> void:
	visible = true
	$gameovergui.visible = false
	$CountdownTimer.stop()
	$Border/ScrollContainer/Scores.display_high_scores()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_countdown_timer_timeout() -> void:
	pass
