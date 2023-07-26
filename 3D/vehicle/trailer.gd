extends VehicleBody3D

## Status
var attached : bool = false

signal trailer_detached
signal trailer_attached

@onready var attacher_marker = $StaticBody3D/AttachPlate/AttacherMarker

# Called when the node enters the scene tree for the first time.
func _ready():
	trailer_attached.connect(_on_trailer_attached)
	trailer_detached.connect(_on_trailer_detached)


func _on_trailer_attached():
	attached = true
	print("trailer_attached")
	pass

func _on_trailer_detached():
	print("_on_trailer_detached")
	attached = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	## Wenn nicht angehängt Bremsen des Trailers aktivieren
	if not attached:
		brake = 50
	else:
		brake = 0
	pass
