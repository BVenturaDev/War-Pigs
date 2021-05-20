extends Area

var DEBUG = false

onready var flag = $Flag

# count pigs for next scene
export (bool) var count_pigs = true

var has_huts: bool = true

func _ready():
	flag.visible = false

func _physics_process(_delta):
	var hut_group: Array  = get_tree().get_nodes_in_group("Huts")
	if hut_group.size() <= 0 or DEBUG == true:
		flag.visible = true
		has_huts = false
		
func transition():
	if not has_huts:
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
		# Store minions alive for shop
		body.count_minions(count_pigs)
		transition()
