extends Area3D

## Area3D
## Wenn Trailer in Reichweite
## Signal ausgeben

@export var joint : PinJoint3D = null

func _on_area_entered(area):
	print("_on_area_entered")

	var p :VehicleBody3D = area.get_owner()
	if is_instance_valid(p) and is_instance_valid(joint):
		owner.trailer_can_attach.emit(true, p)


func _on_area_exited(_area):
	print("_on_area_exited")
	owner.trailer_can_attach.emit(false)
	pass # Replace with function body.
