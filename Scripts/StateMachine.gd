extends Node

# Attributes
# --------------------

enum GameState {
	LOBBY,
	GAME
}

var current_state: GameState = GameState.LOBBY

# Functions
# --------------------

# Change the state and load the corresponding scene
func change_state(new_state: GameState, parameters = {}):
	if current_state == new_state:
		return

	current_state = new_state

	var scene_path = ""
	match current_state:
		GameState.LOBBY: scene_path = "res://scenes/LobbyScene.tscn"
		GameState.GAME: scene_path = "res://scenes/GameScene.tscn"

	# Load the new scene
	var new_scene = load(scene_path).instantiate()

	# Use a deferred call to change the scene
	call_deferred("_change_scene", new_scene, parameters)

func _change_scene(new_scene, parameters):
	# Safely free the current scene and set the new one
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
		
	get_tree().current_scene = new_scene
	get_tree().root.add_child(new_scene)
	
	# Initialize the new scene with the provided parameters
	if new_scene.has_method("initialize"):
		new_scene.initialize(parameters)
