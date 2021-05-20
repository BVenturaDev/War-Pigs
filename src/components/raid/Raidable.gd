extends Spatial
class_name Raidable

"""
Abstract script for all objects that are raidable
"""

export (bool) var DEBUG
var poiner_debug = load("res://scenes/components/raid/Pointer.tscn")
var currency_item = load("res://scenes/components/currency/Currency.tscn")

export (float) var max_health
onready var health: float = max_health

# object that is to be interacted by the minions
export (NodePath) var raidable_trigger_path
var raidable_trigger

# Positions for pigs to go to inside
var positions_available: Array = []
var position_occupied: Array = []



# Pigs that are inside the hut
var pigs_attacking: Array = []
var max_pigs: int

func _ready():
	# Pass raidable to trigger
	if raidable_trigger_path != "":
		raidable_trigger = get_node(raidable_trigger_path)
		raidable_trigger.set_raidable(self)
		
	for p in $Positions.get_children():
		positions_available.append(p)
		if DEBUG:
			spawn_pointer(p)
			
	max_pigs = $Positions.get_children().size()
		
	

func decrease_health(value: float):
	health -= value
	if is_destroyed():
		die()
	
func increase_health(value: float):
	health += value

func is_destroyed():
	return health < 0

# Position where the pig will go to raid
func give_position(entity: KinematicBody) -> Position3D:
	var pos = positions_available.pop_front()
	if pos != null:	# Avoid giving all pigs that are near a spot
		# Pass position to spatial
		position_occupied.append(pos)
		pigs_attacking.append(entity)
		return pos
	else:
		return pos

# Return the position given to the pigs back to the hut
func retrieve_position(position: Position3D, entity: KinematicBody):
	position_occupied.erase(position)
	positions_available.append(position)
	# Keep pigs to iterate through them
	if is_destroyed() == false:
		pigs_attacking.erase(entity)

func die():
	# Give currency
	for p in pigs_attacking:
		# Create currency
		# Pass currency to pigs
		var currency_scene = currency_item.instance()
		p.pass_currency(currency_scene)
		p.line_up()
	get_tree().call_group("Minions", "target_killed", self)
	call_deferred("queue_free")

func spawn_pointer(point: Position3D):
	var packed: Spatial = poiner_debug.instance()
	add_child(packed)
	packed.translation = point.translation
	#print_debug(packed.transform)
