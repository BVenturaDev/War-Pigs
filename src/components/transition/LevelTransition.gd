extends Area

# Scenes to transition to
export (Array, String, FILE,"*.tscn") var scenes

func transition():
	if scenes.size() > 0:
		# GIve Manager scenes to transition to
		LevelManager.scenes_to_transition(scenes)
	else:
		# Check for a scene stored in LevelManager
		LevelManager.back_to_raid()


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		transition()
