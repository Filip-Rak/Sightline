extends Node

# Attributes
# --------------------

enum GAME_STATE {
	DEBUG_LOBBY,
	MAP_TEST
}

var current_state: GAME_STATE = GAME_STATE.DEBUG_LOBBY

# Functions
# --------------------

# Change the state and load the corresponding scene
func change_state(new_state: GAME_STATE, parameters = {}):
	if current_state == new_state:
		return

	current_state = new_state

	var scene_path = ""
	match current_state:
		GAME_STATE.DEBUG_LOBBY: scene_path = "res://scenes/DebugLobby.tscn"
		GAME_STATE.MAP_TEST: scene_path = "res://scenes/MapTest.tscn"

	# Load the new scene
	var new_scene = load(scene_path).instantiate()

	# Use a deferred call to change the scene
	call_deferred("_change_scene", new_scene, parameters)

func _change_scene(new_scene, parameters):
	# Safely free the current scene and set the new one
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
		
	# Add the new scene to the root node first
	get_tree().root.add_child(new_scene)
	
	# Set the new scene as the current scene
	get_tree().set_current_scene(new_scene)
	
	# Initialize the new scene with the provided parameters
	if new_scene.has_method("set_up"):
		new_scene.set_up(parameters)
