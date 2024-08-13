extends Control
@onready var gameover_buttons : Control = $gameovergui

var timerS

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_timer(init: int = 0):
	return init

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if self.visible == true and !$gameovergui.visible:
		if $CountdownTimer.is_stopped() or $CountdownTimer.paused:
			$CountdownTimer.start()
			print("Timer started: x secs = %d" % [$CountdownTimer.time_left])
	pass


func _on_countdown_timer_timeout() -> void:
	print("_on_countdown_timer_timeout")
	$gameovergui.visible = true
