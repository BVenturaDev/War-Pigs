extends Spatial

# Preloads
var targ_pos_spawn = preload("res://scenes/components/Target_Pos_Spawn.tscn")
var line = preload("res://scenes/components/Line.tscn")

onready var player = get_parent()

# Formation Variables
var lines: Array = []
var line_pos: Array = []
var minions: Array = []

func _create_pos(var pos: Node) -> Node:
	pos.transform.origin.z += Globals.ATTACKDIST
	var new_pos = targ_pos_spawn.instance()
	player.main.add_child(new_pos)
	new_pos.global_transform = pos.global_transform
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
	minions[i].target = _create_pos(_find_pos_loc(i))
	minions[i].in_formation = false
	minions[i].path_finder.update_path(minions[i].target)

func _ready() -> void:
	_add_line()
	get_tree().call_group("Minions", "join_formation")

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
	print("Added Minion: " + str(minion.name))
	
func attack_individual() -> void:
	# Find the first minion in formation
	var i: int = -1
	for minion in minions:
		if minion.in_formation:
			i = minion.form_id
			break
	if not i == -1:
		_attack(i)
		
func return_to_formation() -> void:
		for i in minions:
			if not i.in_formation:
				i.line_up()

func charge() -> void:
	for i in minions:
		if i.in_formation:
			_attack(i.form_id)
