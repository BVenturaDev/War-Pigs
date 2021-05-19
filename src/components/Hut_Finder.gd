extends Spatial

var huts: Array = []

func _process(var _delta: float) -> void:
	for i in huts.size():
		if huts[i] == null or not is_instance_valid(huts[i]):
			huts[i] = null


func _ready() -> void:
	var hut_group: Array  = get_tree().get_nodes_in_group("Huts")
	for i in hut_group:
		huts.append(i)
			
func find_nearest_hut(var pos: Vector3) -> Node:
	var nearest: Node = null
	var shortest_dist: float = 0
	for hut in huts:
		if is_instance_valid(hut) or not hut == null:
			var dist: float = abs(hut.global_transform.origin.x - pos.x) + abs(hut.global_transform.origin.y - pos.y)
			if shortest_dist == 0:
				shortest_dist = dist
				nearest = hut
			elif shortest_dist > dist:
				shortest_dist = dist
				nearest = hut
	return nearest
