extends Node3D


@onready var player_camera = $"../PlayerCamera"





@onready var twist_pivot := $TwistPivot 
@onready var pitch_pivot := $TwistPivot/PitchPivot 
@onready var camera_3d = $TwistPivot/PitchPivot/SubViewportContainer/SubViewport/Camera3D
@onready var viewport = $TwistPivot/PitchPivot/SubViewportContainer

@export var mouse_sensitivity : float = 0.015
var mouse_twist_input : float = 0.0
var mouse_pitch_input : float = 0.0


#player camera still captures movement after debug camera is toggled


func _process(delta): 
	if viewport.is_visible():
		if Input.is_action_pressed("camera_rotation_unlock"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
		camera_3d.global_position = global_position
		camera_3d.global_rotation = twist_pivot.rotation + pitch_pivot.rotation
		
		
		var input := Vector3.ZERO 
		input.x = Input.get_axis("camera_left", "camera_right") 
		input.z = Input.get_axis("camera_forward", "camera_backward") 
		position += twist_pivot.basis*pitch_pivot.basis *input* delta
		twist_pivot.rotate_y(mouse_twist_input)
		pitch_pivot.rotate_x(mouse_pitch_input) 
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -1, 1)
		mouse_twist_input = 0 
		mouse_pitch_input = 0 

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_twist_input = -event.relative.x * mouse_sensitivity
			mouse_pitch_input = -event.relative.y * mouse_sensitivity
		else: 
			mouse_pitch_input = 0.0
			mouse_twist_input = 0.0
	if event.is_action_pressed("debug_unlock"):
		if viewport.is_visible():
			player_camera.enable_positional_movement = true
			player_camera.enable_rotational_movement = true
			viewport.set_visible(false)
		else:
			player_camera.enable_positional_movement = false 
			player_camera.enable_rotational_movement = false
			viewport.set_visible(true)
