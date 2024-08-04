extends Control

# Attributes
# --------------------

# Nodes
@export var game_manager : Game_Manager

# Links
# --------------------
func select_unit_for_spawn(type : PlayerUnit.unit_type):
	game_manager.select_unit_for_spawn(type)
	
