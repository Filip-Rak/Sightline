extends Control

# Attributes
# --------------------

# Nodes
@export var game_manager : Game_Manager
@onready var current_turn_label : Label = $CurrentTurnLabel
@onready var player_name_label : Label = $PlayerNameLabel
@onready var time_left_label : Label = $TimeLeftLabel

var game_in_progress = false

# Ready
# --------------------
func _ready():
	game_manager.set_game_ui(self)
	player_name_label.text = "Player: " + PlayerManager.get_player_name(multiplayer.get_unique_id()) + " " + str(multiplayer.get_unique_id())

# Proccess
# --------------------
func _process(_delta : float):
	handle_timer()

func handle_timer():
	if game_in_progress:
		var time_spent = game_manager.turn_manager.time_spent_in_turn
		var time_max = game_manager.turn_manager.time_limit
		
		if game_manager.turn_manager.set_timer_type == game_manager.turn_manager.TIMER_TYPE.DISABLED:
			time_left_label.text = "Time passed: " + str(floor(time_spent))
		else:
			time_left_label.text = "Time left: " + str(floor(time_max - time_spent))
		
		
# External Control Functions
# --------------------
func update_turn_ui(player_id : int, _given_time : float):
	current_turn_label.text = "Current turn: " + PlayerManager.get_player_name(player_id) + " " + str(player_id)
	game_in_progress = true

# Links
# --------------------
func select_unit_for_spawn(type : PlayerUnit.unit_type):

	var action_arg = PlayerUnit.get_actions(type)[0]
	if action_arg:
			game_manager.set_mouse_selection(type)
			game_manager.select_action(action_arg)
			
	else:
		print("Unit not spawnable")


func _on_end_turn_button_button_down():
	game_manager.turn_manager.try_skip_turn()
	

func _on_move_button_button_down():
	game_manager.select_action(PlayerUnit.type_properties[PlayerUnit.unit_type.IFV]["actions"][1])
