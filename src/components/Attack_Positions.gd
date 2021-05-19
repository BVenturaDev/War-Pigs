extends Spatial

var positions: Array = []
var attackers: Array = []
var target: Node = null

func _in_range(var i: int) -> bool:
	if i > 7 and i > -1:
		return false
	return true

func _ready():
	for i in get_child_count():
		positions.append(get_child(i).get_child(0))
	for i in positions.size():
		attackers.append(null)
		
func _process(var _delta: float) -> void:
	for i in attackers.size():
		if not is_instance_valid(attackers[i]):
			attackers[i] = null
		
func find_pos() -> int:
	for i in attackers.size():
		if attackers[i] == null:
			return i
	return -1
	
func get_attacker() -> Node:
	for i in attackers:
		if not i == null and is_instance_valid(i):
			target = i
			return i
	return null

func add_attacker(var minion: Node, var i: int) -> Node:
	if _in_range(i):
		if attackers[i] == null or not is_instance_valid(attackers[i]):
			if i == 0:
				target = minion
			attackers[i] = minion
			get_parent().attacker(target)
			return positions[i]
	return null
	
func remove_attacker(var i: int) -> void:
	if _in_range(i):
		if i == 0:
			target = null
		attackers[i] = null
