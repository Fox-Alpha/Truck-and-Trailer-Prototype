extends CharacterBody3D

var walk_speed := 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	pass
#	steering = lerp(steering, Input.get_axis("right", "left") * 0.4, 5 * _delta)
#	engine_force = Input.get_axis("back", "forward") * 30


func _input(event):
	if event is InputEventKey:
		var move_direction = Input.get_vector(
				"left",
				"right",
				"forward",
				"back"
		)
		velocity.x += move_direction.x * walk_speed
		velocity.z += move_direction.y * walk_speed

		move_and_slide()
