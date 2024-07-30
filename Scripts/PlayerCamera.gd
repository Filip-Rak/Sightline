extends Node3D

# Attributes
# --------------------

# Nodes
@onready var focal_y = $YAxisFocal
@onready var focal_x = $YAxisFocal/XAxisFocal
@onready var camera := $YAxisFocal/XAxisFocal/Camera3D

# Positional Movement
@export var positional_speed_max : float = 4.0
@export var positional_speed_min : float = 2.2
@export var positional_smoothing_factor : float = 0.02
@export var positional_speed_zoom_multiplier : float = 0.5
var target_position : Vector3
var current_positional_speed : float

# Rotational Movement
@export var mouse_sensitivity : float = 0.15
@export var rotational_dampness_y : float = 0.985
@export var rotational_dampness_x : float = 0.985
@export var min_rotation_offset : float = 0.0
@export var max_rotation_x : float = 60
@export var min_rotation_x : float = 25
@export var collision_avoidance_speed_multiplier : float = 0.2
@export var collision_avoidance_abruptance_shift : float = 90
var mouse_twist_input : float = 0.0
var mouse_pitch_input : float = 0.0
var inner_collision : bool = false
var outer_collision : bool = false

# Zoom
@export var zoom_speed : float = 1.2
@export var zoom_min : float = 0.7
@export var zoom_max : float = 2
@export var zoom_dampness : float = 0.98
@export var zoom_increase_on_collision = 5
var target_zoom : float
var zoom_direction = 0

# Panning
@export var pan_margin : int = 60
@export var pan_speed_multiplier : float = 0.25

# Ready Functions
# --------------------
func _ready():
	target_zoom = camera.position.z

# Process Functions
# --------------------
func _process(delta:float):
	handle_positional_movement(delta)
	handle_zoom(delta)
	handle_panning(delta)
	handle_collision(delta)
	handle_rotational_movement(delta)
	move_focal_point()
	
func handle_positional_movement(delta:float):
	# Read keyboard input
	var velocity_direction = Vector3.ZERO
	if Input.is_action_pressed("camera_forward"): velocity_direction -= focal_y.transform.basis.z
	if Input.is_action_pressed("camera_backward"): velocity_direction += focal_y.transform.basis.z
	if Input.is_action_pressed("camera_right"): velocity_direction += focal_y.transform.basis.x
	if Input.is_action_pressed("camera_left"): velocity_direction -= focal_y.transform.basis.x
	
	# Combine keyboard and mouse inputs for a target position
	var combination = velocity_direction.normalized()
	
	# Modify speed based on zoom
	var zoom_factor = normalize_value(camera.position.z, zoom_max, zoom_min)
	current_positional_speed = (positional_speed_max - positional_speed_min) * zoom_factor + positional_speed_min
	
	# Smoothly interpolate focal position to target_position
	target_position += combination * current_positional_speed * delta 
	
func handle_zoom(delta:float):
	# Caluclate new zoom
	target_zoom = camera.position.z + zoom_speed * zoom_direction * delta
	target_zoom = clamp(target_zoom, zoom_min, zoom_max)
		
	# Apply dampness over time
	zoom_direction *= zoom_dampness
		
	# Apply zoom
	camera.position.z = target_zoom
	
func handle_panning(delta: float):
	if !Input.is_action_pressed("camera_pan_unlock"):
		return
		
	var current_viewport: Viewport = get_viewport()
	var pan_direction: Vector2 = Vector2(0, 0)  # Default to no panning
	var viewport_size: Vector2i = current_viewport.get_visible_rect().size
	var current_mouse_position: Vector2 = current_viewport.get_mouse_position()
	var pan_speed = current_positional_speed * pan_speed_multiplier
	
	# Panning on X
	if current_mouse_position.x < pan_margin || current_mouse_position.x > viewport_size.x - pan_margin:
		if current_mouse_position.x > viewport_size.x * 0.5:
			pan_direction.x = 1
		else:
			pan_direction.x = -1
	
	# Panning on Y
	if current_mouse_position.y < pan_margin || current_mouse_position.y > viewport_size.y - pan_margin:
		if current_mouse_position.y > viewport_size.y * 0.5:
			pan_direction.y = 1
		else:
			pan_direction.y = -1
	
	# Combine the pan directions into a single Vector3 and apply the focal point's rotation
	var pan_vector = Vector3(pan_direction.x, 0, pan_direction.y) * delta * pan_speed
	pan_vector = focal_y.transform.basis * pan_vector
	
	# Update the target position based on the rotated pan vector
	target_position += pan_vector
	
func move_focal_point():
	focal_y.position = focal_y.position.lerp(target_position, positional_smoothing_factor)
	
func handle_rotational_movement(delta:float):
	if Input.is_action_pressed("camera_rotation_unlock"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
	# print("ITERATION:\n\tTWIST: %s \n\tPitch: %s" % [mouse_twist_input, mouse_pitch_input])
	
	if outer_collision && mouse_pitch_input > 0:
		mouse_pitch_input = 0
	
	if abs(mouse_twist_input) > min_rotation_offset: focal_y.rotate_y(mouse_twist_input * delta)
	if abs(mouse_pitch_input) > min_rotation_offset: focal_x.rotate_x(mouse_pitch_input * delta)
	
	# Constrain rotation on x axis
	var rotation_x = focal_x.rotation_degrees.x
	rotation_x = clamp(rotation_x, -max_rotation_x, -min_rotation_x)
	focal_x.rotation_degrees.x = rotation_x
	
	# Reset the inputs after applying
	mouse_twist_input *= rotational_dampness_y
	mouse_pitch_input *= rotational_dampness_x
	
func handle_collision(delta):
	if inner_collision:
		# Calculate base rotation speed
		var base_rotation_speed = collision_avoidance_speed_multiplier * delta
		
		# Apply a function
		var speed_power = 1.0 / (1.0 + exp(-collision_avoidance_abruptance_shift * (current_positional_speed - 1.0)))
		
		# Normalize speed_power to a reasonable range
		var normalized_speed_power = clamp(speed_power, positional_speed_min, positional_speed_max)
		
		# Adjust the rotation speed based on normalized power
		var adjusted_rotation_speed = base_rotation_speed * normalized_speed_power
		
		# Apply the rotation
		focal_x.rotate_x(-adjusted_rotation_speed)
	
# Special Input Functions
# --------------------
func _unhandled_input(event):
	if Input.is_action_pressed("camera_zoom_in"):
		zoom_direction = -1
	elif Input.is_action_pressed("camera_zoom_out"):
		zoom_direction = 1
		
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_twist_input = -event.relative.x * mouse_sensitivity
			mouse_pitch_input = -event.relative.y * mouse_sensitivity
		else: 
			mouse_pitch_input = 0.0
			mouse_twist_input = 0.0

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
	return Vector3(focal_x.position)
	

# Links
# --------------------
func _on_area_3d_body_entered(_body):
	inner_collision = true
	
func _on_area_3d_body_exited(_body):
	inner_collision = false

func _on_area_3d_2_body_entered(_body):
	outer_collision = true

func _on_area_3d_2_body_exited(_body):
	outer_collision = false
