extends Area

# Scenes to transition to
export (Array, String, FILE,"*.tscn") var scenes

func transition():
	LevelManager.scenes_to_transition(scenes)
