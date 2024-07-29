extends Node3D

# Attributes
# --------------------

# Nodes
@onready var focal_point = $CameraFocal
@onready var camera := $CameraFocal/Camera3D

# Positional Movement
@export var positional_speed : float = 10.0
@export var positional_smoothing_factor : float = 0.03
var target_position: Vector3

# Zoom
@export var zoom_speed : float = 2.6
@export var zoom_min : float = 0.2
@export var zoom_max : float = 3.0
@export var zoom_dampness : float = 0.98
var target_zoom : float
var zoom_direction = 0

# Ready Functions
# --------------------
func _ready():
	target_zoom = camera.position.z

# Process Functions
# --------------------
func _process(delta:float):
	handle_positional_movement(delta)
	handle_zoom(delta)
	
func handle_positional_movement(delta:float):
	
	# Read input
	var velocity_direction = Vector3.ZERO
	if Input.is_action_pressed("camera_forward"): velocity_direction -= transform.basis.z
	if Input.is_action_pressed("camera_backward"): velocity_direction += transform.basis.z
	if Input.is_action_pressed("camera_right"): velocity_direction += transform.basis.x
	if Input.is_action_pressed("camera_left"): velocity_direction -= transform.basis.x
	
	# Smoothly interpolate focal position to target_position
	target_position += velocity_direction.normalized() * positional_speed * delta 
	focal_point.position = focal_point.position.lerp(target_position, positional_smoothing_factor)
	
func handle_zoom(delta:float):
	
	target_zoom = camera.position.z + zoom_speed * zoom_direction * delta
	target_zoom = clamp(target_zoom, zoom_min, zoom_max)
	zoom_direction *= zoom_dampness
	camera.position.z = target_zoom

# Special Input Functions
# --------------------
func _unhandled_input(_event:InputEvent):
	if Input.is_action_pressed("camera_zoom_in"):
		zoom_direction = -1
	elif Input.is_action_pressed("camera_zoom_out"):
		zoom_direction = 1
