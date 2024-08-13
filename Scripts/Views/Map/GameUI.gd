extends Control

# Attributes
# --------------------

# Nodes
@export var game_manager : Game_Manager
@onready var current_turn_label : Label = $CurrentTurnLabel
@onready var player_name_label : Label = $PlayerNameLabel

func _ready():
	game_manager.set_game_ui(self)
	player_name_label.text = "Player: " + PlayerManager.get_player_name(multiplayer.get_unique_id()) + " " + str(multiplayer.get_unique_id())

# External Control Functions
# --------------------

func update_turn_ui(player_id : int, _given_time : float):
	current_turn_label.text = "Current turn: " + PlayerManager.get_player_name(player_id) + " " + str(player_id)

# Links
# --------------------
func select_unit_for_spawn(type : PlayerUnit.unit_type):
	game_manager.select_unit_for_spawn(type)


func _on_end_turn_button_button_down():
	game_manager.turn_manager.try_skip_turn()
