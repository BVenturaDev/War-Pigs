extends Area

func transition():
	var hut_group: Array  = get_tree().get_nodes_in_group("Huts")
	if hut_group.size() <= 0:
		var next_scene = Globals.next_level()
		var current_scene = get_tree().current_scene.filename

		if next_scene != null:
			# Avoid changing to current level
			if current_scene == next_scene:
				next_scene = Globals.next_level()
				if next_scene != null:
					LevelManager.transition_to(next_scene)
				else:
					printerr("No more scenes")
			else:
				LevelManager.transition_to(next_scene)
		else:
			printerr("No more scenes")
	


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		transition()
