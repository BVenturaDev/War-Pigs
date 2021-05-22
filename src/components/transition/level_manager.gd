extends Node

"""
Responsible for changing scenes.
"""

# General function to transition to a given scene
func transition_to(scene: String):
	Globals.total_combat_pigs = 0
	var _ch_sc = get_tree().change_scene(scene)
