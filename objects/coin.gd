extends Area3D

@export var respawn_delay := 5.0

var time := 0.0
var grabbed := false

@onready var mesh = $Mesh
@onready var particles = $Particles
@onready var collider = $CollisionShape3D

# Collecting coins

func _on_body_entered(body):
	if body.has_method("collect_coin") and !grabbed:
		
		body.collect_coin()
		
		Audio.play("res://sounds/coin.ogg") # Play sound
		
		mesh.visible = false
		particles.emitting = false
		collider.set_deferred("disabled", true)
		
		grabbed = true
		get_tree().create_timer(respawn_delay).timeout.connect(_respawn)

# Rotating, animating up and down

func _process(delta):
	
	rotate_y(2 * delta) # Rotation
	position.y += (cos(time * 5) * 1) * delta # Sine movement
	
	time += delta

func _respawn() -> void:
	grabbed = false
	mesh.visible = true
	particles.emitting = true
	collider.set_deferred("disabled", false)
