extends Node

# Attributes
# --------------------

enum MOUSE_MODE{
	# Normal mouse mode with no raycasting
	STANDARD,
	
	# For selecting units and tiles
	INSPECTION,
	
	# For spawning new units
	SPAWN,
	
	# For directing selected unit to move somwhere
	MOVE,
	
	# For directing selected unit to attack
	ATTACK
}

var current_mouse_mode : MOUSE_MODE = MOUSE_MODE.STANDARD
var raycast_camera = null
var game_manager = null

# Process Functions
# --------------------

func _process(_delta : float):
	process_hovering()

func process_hovering():
	var hit = get_hovered_on_selectable()
	if !hit && game_manager: game_manager.clear_mouse_over_highlight()
	
	match current_mouse_mode:
		MOUSE_MODE.STANDARD: pass
		MOUSE_MODE.INSPECTION: handle_inspection(hit)
		MOUSE_MODE.SPAWN: handle_spawn(hit)
		MOUSE_MODE.MOVE: handle_move(hit)
		MOUSE_MODE.ATTACK: handle_attack(hit)
		_: print ("INVALID MOUSE MODE")
			
func handle_inspection(_hit):
	# print ("INSPECTION")
	pass
	
func handle_spawn(hit):
	# print ("SPAWN")
	if hit: 
		game_manager.mouse_over_highlight_tile(hit)
		if Input.is_action_just_pressed("main_interaction"):
			game_manager.try_spawning_a_unit(hit)

func handle_move(_hit):
	# print ("MOVE")
	pass
	
func handle_attack(_hit):
	# print ("ATTACK")
	pass

# Return 'false' when:
# - no hit
# - hit is not selectable
# - no camera to fire the ray
func get_hovered_on_selectable():
	if !raycast_camera: return false
	
	var hit = raycast_camera.screen_point_to_ray()
	
	if hit:
		var parent = hit["collider"].get_parent()
		if parent:
			var grand_parent = parent.get_parent()
			if grand_parent:
				return grand_parent
		
	return false

# Setters
# --------------------
func set_mouse_mode(mode : MOUSE_MODE):
	current_mouse_mode = mode

func set_camera(camera : Node3D):
	raycast_camera = camera
	
func set_game_manager(gm : Game_Manager):
	game_manager = gm
