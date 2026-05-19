extends Area3D

@export var rotation_speed := 3.0

func _process(delta: float) -> void:
	rotate_y(rotation_speed * delta)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("reset_body"):
		body.reset_body()
