extends Area3D

@export var bounce_strength := 14.0

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var character := body as CharacterBody3D
		body.set("gravity", -bounce_strength)
		character.velocity.y = bounce_strength
