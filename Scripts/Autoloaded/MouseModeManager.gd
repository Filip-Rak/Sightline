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
	
	# Left button pressed
	if Input.is_action_just_pressed("main_interaction"):
		game_manager.set_mouse_selection(select)
		
		# Raycast hit an item
		if select:
			# Decide based on item type
			if select.is_in_group(game_manager.get_unit_group_name()):
				print ("SELECTED UNIT: %s" % [select])
				if game_ui: game_ui.inspect_unit(select)
				
			elif select.is_in_group(game_manager.get_tile_group_name()):
				print ("SELECTED TILE: %s" % [select])
				if game_ui: game_ui.inspect_tile(select)
				
		# Raycast was enabled and missed
		elif !_suppress_raycast:
			remove_selection()

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
	
	# If we're suppressing raycast, then the mouse must be over UI
	# If thats not the case, and we just got no hits
	# Then we have undone the selection
	elif Input.is_action_just_pressed("main_interaction") && !_suppress_raycast:
		remove_selection()

	if Input.is_action_just_pressed("secondary_interaction"): 
		game_manager.execute_action(select)

# Public Methods
# --------------------
func remove_selection():
	# Iform UI
	if game_ui: game_ui.deselect_inspection()
			
	# Clear highlighting and selected action
	game_manager.highlight_manager.clear_mouse_over_highlight()
	game_manager.highlight_manager.clear_mass_highlight()
	game_manager.selected_action = null
	game_manager.set_mouse_selection(null)
	
	# Set Mouse Mode to Inspection
	current_mouse_mode = MOUSE_MODE.INSPECTION


# Private Methods
# --------------------

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

func _unhandled_input(_event):
	if Input.is_action_just_pressed("cancel_interaction"):
		remove_selection()

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
