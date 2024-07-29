extends Node3D

# Attributes
# --------------------

# Nodes
@onready var focal_point = $CameraFocal
@onready var camera := $CameraFocal/Camera3D

# Positional Movement
@export var positional_speed_max : float = 4.0
@export var positional_speed_min : float = 2.2
@export var positional_smoothing_factor : float = 0.02
@export var positional_speed_zoom_multiplier : float = 0.5
@export var mouse_keyboard_blend_factor : float = 0.2
var target_position : Vector3

# Zoom
@export var zoom_speed : float = 1.8
@export var zoom_min : float = 0.2
@export var zoom_max : float = 1.5
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
	# Read keyboard input
	var velocity_direction = Vector3.ZERO
	if Input.is_action_pressed("camera_forward"): velocity_direction -= transform.basis.z
	if Input.is_action_pressed("camera_backward"): velocity_direction += transform.basis.z
	if Input.is_action_pressed("camera_right"): velocity_direction += transform.basis.x
	if Input.is_action_pressed("camera_left"): velocity_direction -= transform.basis.x
	
	# Read mouse position
	# var mouse_pos = screen_point_to_ray()
	
	# Combine keyboard and mouse inputs for a target position
	var combination = velocity_direction.normalized()
	# if(zoom_direction != 0):
		# combination = velocity_direction.normalized().lerp(mouse_pos, mouse_keyboard_blend_factor)
	
	# Modify speed based on zoom
	var zoom_factor = normalize_value(camera.position.z, zoom_max, zoom_min)
	var positional_speed = (positional_speed_max - positional_speed_min) * zoom_factor + positional_speed_min
	
	# Smoothly interpolate focal position to target_position
	target_position += combination * positional_speed * delta 
	focal_point.position = focal_point.position.lerp(target_position, positional_smoothing_factor)
	
func handle_zoom(delta:float):
	# Caluclate new zoom
	target_zoom = camera.position.z + zoom_speed * zoom_direction * delta
	target_zoom = clamp(target_zoom, zoom_min, zoom_max)
		
	# Apply dampness over time
	zoom_direction *= zoom_dampness
		
	# Apply zoom
	camera.position.z = target_zoom

# Special Input Functions
# --------------------
func _unhandled_input(_event:InputEvent):
	if Input.is_action_pressed("camera_zoom_in"):
		zoom_direction = -1
	elif Input.is_action_pressed("camera_zoom_out"):
		zoom_direction = 1


# Utility Functions
# --------------------
func normalize_value(value : float, max_val : float, min_val : float) -> float:
	# Ensure min is not equal to max to avoid division by zero
	if min_val == max_val: return 0.0

	# Clamp the value to ensure it is within the range
	var clamped_value = clamp(value, min_val, max_val)
	
	# Normalize the value to the range [0, 1]
	return (clamped_value - min_val) / (max_val - min_val)
	
func screen_point_to_ray() -> Vector3:
	# Get releavnt positions
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Set ray ends
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 9000
	
	# Prepare query and fire the ray
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var ray_hit = space_state.intersect_ray(query)
	
	# Return ray hit position
	if ray_hit:
		return ray_hit['position']
	
	# If no hit, return focal point position
	return Vector3(focal_point.position)
	
	
	
	
