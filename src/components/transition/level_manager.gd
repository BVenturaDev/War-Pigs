extends Node

"""
Responsible for changing scenes.
"""

# General function to transition to a given scene
func transition_to(scene: String):
	var _ch_sc = get_tree().change_scene(scene)
