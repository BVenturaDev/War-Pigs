extends Spatial

"""
Abstract script for all objects that are raidable
"""

export (float) var max_health
onready var health: float = max_health

# Positions for pigs to go to inside
var positions_available: Array = []
var position_occupied: Array = []

func decrease_health(value: float):
	health -= value
	
func increase_health(value: float):
	health += value

func give_position(entity: Spatial):
	var pos = positions_available.pop_front()
	# Pass position to spatial
	position_occupied.append(entity)
	
func retrieve_position(entity: Spatial):
	# Get position from entity
	pass
