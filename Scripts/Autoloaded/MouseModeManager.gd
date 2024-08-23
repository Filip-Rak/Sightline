extends Node

# Attributes
# --------------------

enum MOUSE_MODE{
	# Normal mouse mode with no raycasting
	STANDARD,
	
	# For selecting units and tiles
	INSPECTION,
	
	# For actions with common logic
	ACTION,
}

var current_mouse_mode : MOUSE_MODE = MOUSE_MODE.STANDARD
var raycast_camera = null
var game_manager : Game_Manager = null
var game_ui : Game_UI = null
var _suppress_raycast : bool = false

# Process Functions
# --------------------

func _process(_delta : float):
	if current_mouse_mode == MOUSE_MODE.STANDARD || !game_manager || !raycast_camera: return
	
	var select = null
	if !_suppress_raycast:
		select = get_hovered_on_selectable()
		
	if !select: game_manager.highlight_manager.clear_mouse_over_highlight()
	
	match current_mouse_mode:
		MOUSE_MODE.STANDARD: pass
		MOUSE_MODE.INSPECTION: handle_inspection(select)
		MOUSE_MODE.ACTION: handle_action(select)
		_: print ("INVALID MOUSE MODE")
			
func handle_inspection(select):
	
	if select && Input.is_action_just_pressed("main_interaction"):
		game_manager.set_mouse_selection(select)
		
		if select.is_in_group(game_manager.get_unit_group_name()):
			print ("SELECTED UNIT: %s" % [select])
			if game_ui: game_ui.inspect_unit(select)
			
		elif select.is_in_group(game_manager.get_tile_group_name()):
			print ("SELECTED TILE: %s" % [select])
			if game_ui: game_ui.inspect_tile(select)

func handle_action(select):
	if select: 
		game_manager.highlight_manager.mouse_over_highlghted_tile(select)
		if Input.is_action_just_pressed("main_interaction"):
			# Clear highlighting
			game_manager.highlight_manager.clear_mouse_over_highlight()
			game_manager.highlight_manager.clear_mass_highlight()
			
			# Select a different entity in inspection
			set_mouse_mode(MOUSE_MODE.INSPECTION)
			handle_inspection(select)
	
	if Input.is_action_just_pressed("secondary_interaction"): 
		game_manager.execute_action(select)

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

func set_game_ui(ui : Game_UI):
	game_ui = ui

func set_suppress_raycast(value : bool):
	_suppress_raycast = value
