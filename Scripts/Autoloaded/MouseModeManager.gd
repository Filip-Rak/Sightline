extends Node

# Attributes
# --------------------

enum MOUSE_MODE{
	# Normal mouse mode with no raycasting
	STANDARD,
	
	# For selecting units and tiles
	INSPECTION,
	
	# For actions, with common logic being
	# Displaying available targets
	# Highlighting them with mouse over
	# And executing with mouse click
	ACTION,
	
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
	if current_mouse_mode == MOUSE_MODE.STANDARD || !game_manager || !raycast_camera: return
	
	var select = get_hovered_on_selectable()
	if !select: game_manager.highlight_manager.clear_mouse_over_highlight()
	
	match current_mouse_mode:
		MOUSE_MODE.STANDARD: pass
		MOUSE_MODE.INSPECTION: handle_inspection(select)
		MOUSE_MODE.ACTION: handle_action(select)
		MOUSE_MODE.SPAWN: handle_spawn(select)
		MOUSE_MODE.MOVE: handle_move(select)
		MOUSE_MODE.ATTACK: handle_attack(select)
		_: print ("INVALID MOUSE MODE")
			
func handle_inspection(select):
	
	if select && Input.is_action_just_pressed("main_interaction"):
		game_manager.set_mouse_selection(select)
		
		if select.is_in_group(game_manager.get_unit_group_name()):
			print ("SELECTED UNIT: %s" % [select])
			
			if select.get_player_owner_id() == multiplayer.get_unique_id():
				# Change mouse mode to move
				# set_mouse_mode(MouseModeManager.MOUSE_MODE.MOVE)
				# game_manager.select_moveable_tiles()
				pass
			
		elif select.is_in_group(game_manager.get_tile_group_name()):
			print ("SELECTED TILE: %s" % [select])

func handle_action(select):
	if select: 
		game_manager.highlight_manager.mouse_over_highlghted_tile(select)
	
	if Input.is_action_just_pressed("secondary_interaction"): 
		game_manager.execute_action(select)
	
func handle_spawn(select):
	if select: 
		game_manager.highlight_manager.mouse_over_highlghted_tile(select)
		if Input.is_action_just_pressed("main_interaction"):
			game_manager.try_spawning_a_unit(select)

func handle_move(select):
	if select:
		game_manager.highlight_manager.mouse_over_highlghted_tile(select)
		if Input.is_action_just_pressed("main_interaction"):
			# Clear highlighting
			game_manager.highlight_manager.clear_mouse_over_highlight()
			game_manager.highlight_manager.clear_mass_highlight()
			
			# Select a different entity in inspection
			set_mouse_mode(MOUSE_MODE.INSPECTION)
			handle_inspection(select)
			
		elif Input.is_action_just_pressed("secondary_interaction"):
			if select.is_in_group("tiles"):
				game_manager.try_moving_a_unit(select)
	
func handle_attack(_select):
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
