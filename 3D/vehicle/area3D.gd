extends Area3D


@export var joint : PinJoint3D = null

func _on_area_entered(area):
	print("_on_area_entered")

	var p :VehicleBody3D = area.get_owner()
	if is_instance_valid(p) and is_instance_valid(joint):
		owner.trailer_can_attach.emit(true, p)

#		joint.node_a = joint.get_path_to(owner)
#		joint.node_b = joint.get_path_to(p)
#		owner.trailerattached = true
#		print(p)
#		owner.trailer = p



func _on_area_exited(_area):
	print("_on_area_exited")
	owner.trailer_can_attach.emit(false)
	pass # Replace with function body.
