extends VehicleBody3D

const STEER_SPEED = 1.7
const STEER_LIMIT = 0.5

## Hinweistexte
static var MSG_TRAILER_ATTACH = "Trailer can be attach"
static var MSG_TRAILER_BREAK_FIRST = "Activate Hanbrake first !"
static var MSG_TRAILER_FAILURE = "Activate Hanbrake first !"


@export var engine_force_value := 1000.0
@export var brake_force_value := 10.0
@export var current_speed : float = 0.0
var previous_speed := linear_velocity.length()
var _steer_target := 0.0

## Status Variablen
var handbrake : bool = false
var trailerattached : bool = false
var _canAttach : bool = false

## Trailer
var _trailer : VehicleBody3D = null
var trailer_attacher_mark : Marker3D = null


## Wichtige nodes Shorts

## Joint punkt
@onready var joint : PinJoint3D = get_node("StaticBody3D/AttachPlate/HingeJoint3D")
## Label für Hinweise
@onready var msglabel : Label3D = get_node("AttachMessage")
## Trailer detection
@onready var area_3d = $StaticBody3D/AttachPlate/Area3D
## Marker für Ziel Position des Trailers
@onready var attacher_mark = $StaticBody3D/AttachPlate/HingeJoint3D/AttacherMark
## GUI: Handbremse & Attach Status
@onready var hand_brake = $"../CanvasLayer/HandBrake"
#@onready var trailer_attached = $"../CanvasLayer/TrailerAttached"
@onready var trailer_attached = $"../CanvasLayer/TrailerTexture"


## Signal wenn Trailer in Reichweite
signal trailer_can_attach(canAttach, trailer)
#signal trailer_has_detached
#signal trailer_has_attached


#@onready var desired_engine_pitch: float = $EngineSound.pitch_scale

func _ready():
	trailer_can_attach.connect(_on_TrailerCanAttach)
	pass

func _process(_delta):

	## Hinweis anzeigen wenn Trailer in Reichweite
	## Bedingungen: Handbremse angezogen, Kein Trailer angehängt, Trailer in Reichweite
	if handbrake and not trailerattached and _canAttach:
		msglabel.text = MSG_TRAILER_ATTACH
		msglabel.visible = _canAttach

	## Aktion: Trailer anhängen (E)
	var ac = Input.is_action_just_pressed("attach")
	if ac and handbrake:
		if _canAttach and _trailer:
			# Attach the Trailer
			var trmark := _trailer.attacher_marker as Marker3D
			if is_instance_valid(trmark):
				trailerattached = true
				msglabel.visible = false
				_canAttach = false
				area_3d.get_node("CollisionShape3D").disabled = true
				var dir : Vector3 = trmark.global_position.direction_to(Vector3(attacher_mark.global_position.x, _trailer.global_position.y, attacher_mark.global_position.z))
				var attdist = trmark.global_position.distance_to(attacher_mark.global_position)
				var target_pos = _trailer.global_transform.origin + dir * (attdist)

				target_pos.y = _trailer.global_transform.origin.y

				# tween
				## Trailerposition per Tween anpassen
				var tween : Tween = create_tween()
				tween.set_parallel(true)
				tween.tween_property(get_node("../Marker3D"),"global_position",target_pos,0.5)
				await tween.tween_property(_trailer,"global_position",target_pos,1).finished

				_trailer.emit_signal("trailer_attached")

				## Truck und Trailer zusammenhängen
				joint.node_a = joint.get_path_to(self)
				joint.node_b = joint.get_path_to(_trailer)

		## Trailer abhängen (E)
		elif trailerattached:
			joint.node_a = ""
			joint.node_b = ""
			_trailer.emit_signal("trailer_detached")
			_trailer = null
			trailerattached = false
			area_3d.get_node("CollisionShape3D").disabled = false
			trailer_attached.color = Color.PALE_GREEN
			trailer_attached.get_child(1).visible = trailerattached

	## Hinweis wenn Trailer in Reichweite und keine Handbremse aktiv
	elif not handbrake:
		msglabel.text = MSG_TRAILER_BREAK_FIRST

	## Farbe für GUI ICON anpassen
	if trailerattached:
		trailer_attached.color = Color.PALE_GREEN
		trailer_attached.get_child(1).visible = trailerattached

func _physics_process(delta: float):
	var fwd_mps := (linear_velocity * transform.basis).x

	_steer_target = Input.get_axis(&"turn_right", &"turn_left")
	_steer_target *= STEER_LIMIT

	# Engine sound simulation (not realistic, as this car script has no notion of gear or engine RPM).
#	desired_engine_pitch = 0.05 + linear_velocity.length() / (engine_force_value * 0.5)
	# Change pitch smoothly to avoid abrupt change on collision.
#	$EngineSound.pitch_scale = lerpf($EngineSound.pitch_scale, desired_engine_pitch, 0.2)

#	if abs(linear_velocity.length() - previous_speed) > 1.0:
		# Sudden velocity change, likely due to a collision. Play an impact sound to give audible feedback,
		# and vibrate for haptic feedback.
#		$ImpactSound.play()
#		Input.vibrate_handheld(100)
#		for joypad in Input.get_connected_joypads():
#			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)

	## Aktion: Handbremse (SPACE)
	if Input.is_action_just_pressed("break"):
		if not handbrake:
			# Bremskraft
			brake = 50
			engine_force = 0
			handbrake = true
		else:
			handbrake = false

	## GUI Icon anzeigen, wenn aktiv
	hand_brake.visible = handbrake

	if Input.is_action_pressed(&"accelerate") and not handbrake:
		# Increase engine force at low speeds to make the initial acceleration faster.
		brake = 0.0
#		var speed := linear_velocity.length()
		if current_speed < 5.0 and not is_zero_approx(current_speed):
			engine_force = clampf(engine_force_value * 5.0 / current_speed, 0.0, 250)
		else:
			engine_force = engine_force_value

		# Apply analog throttle factor for more subtle acceleration if not fully holding down the trigger.
		engine_force *= Input.get_action_strength(&"accelerate")
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"reverse") and not handbrake:
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1.0:
#			var speed := linear_velocity.length()
			if current_speed < 5.0 and not is_zero_approx(current_speed):
				engine_force = -clampf(engine_force_value * 5.0 / current_speed, 0.0, 100.0)
			else:
				engine_force = -engine_force_value

			# Apply analog brake factor for more subtle braking if not fully holding down the trigger.
			engine_force *= Input.get_action_strength(&"reverse")
		else:
			brake = 0.0
#	else:
#	brake = 3.0 #clampf(brake_force_value, 0.0, brake_force_value) * delta

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	## Wenn angehängt, Kraft auf Trailer weitergeben
	## TODO: Notwendig ?
#	if trailerattached and is_instance_valid(_trailer):
#		_trailer.engine_force = engine_force

	previous_speed = linear_velocity.length()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	current_speed = state.linear_velocity.length()
	pass
## Ereignis/Signal Wenn Trailer in Reichweite
func _on_TrailerCanAttach(canAttach : bool = true, trailer : VehicleBody3D = null):
#	print("_on_canTrailerAttach")

	if is_instance_valid(trailer):
		_trailer = trailer as VehicleBody3D
		msglabel.text = MSG_TRAILER_ATTACH
		msglabel.visible = canAttach
		trailer_attached.color = Color.YELLOW
		_canAttach = canAttach
	else:
		msglabel.text = MSG_TRAILER_FAILURE
		msglabel.visible = false
