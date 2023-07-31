extends SubViewport

#@onready var mirror = $"../Mirror"
@export var player : MeshInstance3D
@export var camera : Node3D
#@onready camera := $Basis

func _process(_delta):
#	delta = delta
#	var img = get_viewport().get_texture().get_data()
#	var tex = ImageTexture.new()
#	tex.create_from_image(img)
#	mirror.texture = tex
	camera.global_transform = player.global_transform
#	camera.rotation_degrees.y = player.rotation_degrees.y
