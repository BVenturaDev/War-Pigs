extends Node

"""
Responsible for changing scenes.
"""

# List of scenes to transition to
var transition_scenes: Array

# Goes to the next scene in the transition_scene list	
func back_to_raid():
	var next_scene = transition_scenes.pop_front()
	if next_scene != null:
		transition_to(next_scene)
	else:
		printerr("[Level Manager]Scenes empty. Please add a scene path.")

# Acquires a list of scenes to transition
func scenes_to_transition(scenes: Array):
	# Get the immediate scene
	var next_scene = scenes.pop_front()
	# Store the other scenes for later use
	transition_scenes = scenes
	
	transition_to(next_scene)

# General function to transition to a given scene
func transition_to(scene: String):
	var _ch_sc = get_tree().change_scene(scene)
