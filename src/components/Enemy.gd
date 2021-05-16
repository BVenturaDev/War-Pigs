extends KinematicBody

var hp: int = 100
var alive: bool = true

func _on_Search_Timer_timeout():
	pass # Replace with function body.

func _physics_process(var delta: float) -> void:
	if hp < 1:
		get_tree().call_group("Minions", "enemy_killed", self)
		alive = false

func damage(var dam: int) -> void:
	hp -= dam

