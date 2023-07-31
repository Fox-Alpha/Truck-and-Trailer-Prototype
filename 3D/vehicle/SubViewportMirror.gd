extends SubViewport

@export var camparent : MeshInstance3D
@export var cambase : Node3D

func _process(_delta):
	cambase.global_transform = camparent.global_transform
