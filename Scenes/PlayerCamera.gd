extends Node3D

# Attributes
# --------------------

# Nodes
@onready var focal_point = $CameraFocal
@onready var camera := $CameraFocal/Camera3D

# Controls
@export var positional_speed : float = 10.0

var target_position: Vector3

# Ready Functions
# --------------------
func _ready():
	pass

# Process Functions
# --------------------
func _process(delta:float):
	handle_positional_movement(delta)
	
func handle_positional_movement(delta:float):
	var velocity_direction = Vector3.ZERO
	
	if Input.is_action_pressed("camera_forward"): velocity_direction -= transform.basis.z
	if Input.is_action_pressed("camera_backward"): velocity_direction += transform.basis.z
	if Input.is_action_pressed("camera_right"): velocity_direction += transform.basis.x
	if Input.is_action_pressed("camera_left"): velocity_direction -= transform.basis.x
	
	# if velocity_direction != Vector3.ZERO:
	target_position += velocity_direction.normalized() * delta * positional_speed
		
	focal_point.position = focal_point.position.lerp(target_position, 0.1)
	
	
