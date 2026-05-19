extends Node3D

@export_group("Properties")
@export var target: Node
@export var player_id: int = 1

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120

var camera_rotation:Vector3
var zoom = 10

@onready var camera = $Camera

func _ready():
	
	camera_rotation = rotation_degrees # Initial rotation
	_ensure_camera_input_actions()
	
	pass

func set_player_id(value: int) -> void:
	player_id = value
	_ensure_camera_input_actions()

func set_active(value: bool) -> void:
	set_physics_process(value)

func _physics_process(delta):
	
	# Set position and rotation to targets
	
	self.position = self.position.lerp(target.position, delta * 4)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
	
	handle_input(delta)

# Handle input

func handle_input(delta):
	
	# Rotation
	
	var input := Vector3.ZERO
	
	input.y = Input.get_axis("camera_left_%s" % [player_id], "camera_right_%s" % [player_id])
	input.x = Input.get_axis("camera_up_%s" % [player_id], "camera_down_%s" % [player_id])
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -80, -10)
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in_%s" % [player_id], "zoom_out_%s" % [player_id]) * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)

func _ensure_camera_input_actions() -> void:
	var device: int = player_id - 1
	_ensure_joy_motion_action("camera_left_%s" % [player_id], device, JOY_AXIS_RIGHT_X, -1.0)
	_ensure_joy_motion_action("camera_right_%s" % [player_id], device, JOY_AXIS_RIGHT_X, 1.0)
	_ensure_joy_motion_action("camera_up_%s" % [player_id], device, JOY_AXIS_RIGHT_Y, -1.0)
	_ensure_joy_motion_action("camera_down_%s" % [player_id], device, JOY_AXIS_RIGHT_Y, 1.0)
	_ensure_joy_motion_action("zoom_in_%s" % [player_id], device, JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_ensure_joy_motion_action("zoom_out_%s" % [player_id], device, JOY_AXIS_TRIGGER_LEFT, 1.0)

	if player_id == 1:
		_ensure_key_action("camera_left_1", KEY_LEFT)
		_ensure_key_action("camera_right_1", KEY_RIGHT)
		_ensure_key_action("camera_up_1", KEY_UP)
		_ensure_key_action("camera_down_1", KEY_DOWN)
		_ensure_key_action("zoom_in_1", KEY_PLUS)
		_ensure_key_action("zoom_out_1", KEY_MINUS)

func _ensure_joy_motion_action(action_name: String, device: int, axis: int, axis_value: float) -> void:
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.5)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadMotion and event.device == device and event.axis == axis and event.axis_value == axis_value:
			return

	var joy_event := InputEventJoypadMotion.new()
	joy_event.device = device
	joy_event.axis = axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action_name, joy_event)

func _ensure_key_action(action_name: String, keycode: int) -> void:
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.5)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.keycode == keycode:
			return

	var key_event := InputEventKey.new()
	key_event.device = -1
	key_event.keycode = keycode
	InputMap.action_add_event(action_name, key_event)
