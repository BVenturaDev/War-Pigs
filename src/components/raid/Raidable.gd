extends StaticBody
class_name Raidable

"""
Abstract script for all objects that are raidable
"""

export (bool) var DEBUG
var poiner_debug = load("res://scenes/components/raid/Pointer.tscn")

export (float) var max_health
onready var health: float = max_health

# Positions for pigs to go to inside
var positions_available: Array = []
var position_occupied: Array = []

func _ready():
	add_to_group("raidable")
	for p in $Positions.get_children():
		positions_available.append(p)
		if DEBUG:
			spawn_pointer(p)
		
	

func decrease_health(value: float):
	health -= value
	if is_destroyed():
		die()
	
func increase_health(value: float):
	health += value

func is_destroyed():
	return health < 0

func give_position() -> Position3D:
	var pos = positions_available.pop_front()
	# Pass position to spatial
	position_occupied.append(pos)
	return pos
	
func retrieve_position(position: Position3D):
	position_occupied.erase(position)
	positions_available.append(position)

func die():
	get_tree().call_group("Minions", "target_killed", self)
	queue_free()

func spawn_pointer(point: Position3D):
	var packed: Spatial = poiner_debug.instance()
	add_child(packed)
	packed.translation = point.translation
	print_debug(packed.transform)
