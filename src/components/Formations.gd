extends Spatial

# Preloads
var targ_pos_spawn = preload("res://scenes/components/Target_Pos_Spawn.tscn")
var line = preload("res://scenes/components/Line.tscn")

onready var player = get_parent()

# Formation Variables
var lines: Array = []
var line_pos: Array = []
var minions: Array = []

func _process(var _delta: float) -> void:
	for i in minions.size():
		if not is_instance_valid(minions[i]):
			minions[i] = null
			reshuffle(i)

func _create_pos(var pos: Node) -> Node:
	# Transform along local z axis
	pos.transform.origin.z += Globals.ATTACKDIST
	var new_pos = targ_pos_spawn.instance()
	player.main.add_child(new_pos)
	# Set global_transform to the attack position
	new_pos.global_transform = pos.global_transform
	# Return to original pos
	pos.transform.origin.z -= Globals.ATTACKDIST
	return new_pos

func _add_line():
	# Make the new line
	var new_line: Spatial = line.instance()
	add_child(new_line)
	# Place the new line
	var dist: float = (lines.size() + 1) * 10
	new_line.transform.origin.z = dist
	lines.append(new_line)
	# Get the new line positions
	var new_pos: Array = []
	for i in new_line.get_child_count():
		new_pos.append(new_line.get_child(i))
	line_pos.append(new_pos)

func _find_empty_position() -> int:
	if minions.size() > 0:
		for i in minions.size():
			if minions[i] == null:
				return i
			return minions.size()
	return 0

func _find_pos_loc(var i: int) -> Node:
	# Get the line the position is in
	var line_i: int = 0
	var i_calc: int = i
	while i_calc > 9:
		i_calc -= 10
		line_i += 1
	if line_i == line_pos.size():
		_add_line()
	if not line_pos[line_i] == null:
		return line_pos[line_i][i_calc]
	return null

# Set the minions new target for path finding
func _set_target(var i: int, var tar: Node) -> void:
	minions[i].target = tar 
	minions[i].path_finder.update_path(minions[i].target)

func _attack(var i: int) -> void:
	# Send the minion to the player target position
	minions[i].state = minions[i].states.FOLLOW
	minions[i].target = _create_pos(_find_pos_loc(i))
	minions[i].in_formation = false
	minions[i].path_finder.update_path(minions[i].target)

func _ready() -> void:
	_add_line()
	get_tree().call_group("Minions", "join_formation")

# Move minions above i down 1 position in formation
func reshuffle(var index: int) -> void:
	for i in range(index, minions.size()):
		if not i + 1 == minions.size():
			if is_instance_valid(minions[i + 1]) and not minions[i + 1] == null:
				minions[i] = minions[i + 1]
				minions[i].form_id -= 1
				if minions[i].in_formation:
					update_target(i)
				minions[i + 1] = null
		else:
			minions[i] = null

# Give the minion it's target in formation
func update_target(var i: int) -> void:
	_set_target(i, _find_pos_loc(i))

# Add a minion to an available position
func add_minion(var minion: KinematicBody) -> void:
	var i: int = _find_empty_position()
	minions.insert(i, minion)
	# Set the target to the position in formation
	minions[i].form_id = i
	_set_target(i, _find_pos_loc(i))
	Globals.add_pig_to_count()
	#print("Added Minion: " + str(minion.name))
	
func attack_individual() -> void:
	# Find the first minion in formation
	var i: int = -1
	for minion in minions:
		if is_instance_valid(minion):
			if minion.in_formation:
				i = minion.form_id
				break
	if not i == -1:
		_attack(i)
		
func return_to_formation() -> void:
		for i in minions:
			if is_instance_valid(i) and not i == null:
				i.line_up()

func charge() -> void:
	for i in minions:
		if i and is_instance_valid(i):
			if i.in_formation:
				_attack(i.form_id)

func total_minions() -> int:
	var total_minions: int = 0
	for m in minions:
		if m != null and is_instance_valid(m):
			total_minions += 1
	return total_minions


func remove_pig(position: int):
	if minions.size() > 0:
		minions[position].queue_free()

func remove_last_pig():
	remove_pig(0)
