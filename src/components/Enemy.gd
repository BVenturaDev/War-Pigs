extends KinematicBody

# Preloads
var pig_scene = preload("res://scenes/components/Minion.tscn")

# Scene Variables
onready var label = $Recruit_Label
onready var dest_timer = $Destruction_Timer

# Enemy Variables
var hp: int = 100
var alive: bool = true

func _on_Search_Timer_timeout():
	pass # Replace with function body.

func _physics_process(var delta: float) -> void:
	if hp < 1 and alive:
		get_tree().call_group("Minions", "enemy_killed", self)
		alive = false
		label.visible = true

# Convert to a minion
func recruit() -> void:
	var pig = pig_scene.instance()
	get_parent().add_child(pig)
	pig.global_transform = global_transform
	pig.join_formation()
	get_tree().call_group("Minions", "enemy_killed", self)
	queue_free()
	


func damage(var dam: int) -> void:
	hp -= dam
