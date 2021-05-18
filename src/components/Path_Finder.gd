extends Spatial

onready var par: Node = get_parent()
onready var nav: Navigation = par.get_parent()

var path: Array = []
var path_node: int = 0

func has_path() -> bool:
	return path_node < path.size() 

func move_to(target_pos) -> void:
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func update_path(target) -> void:
	if not target == null:
		# Go to the closest position to target
		move_to(nav.get_closest_point(target.global_transform.origin))

func calculate_vel(var max_speed: float, var accel: float, var delta: float) -> Vector3:
	if has_path():
		var dir = (path[path_node] - global_transform.origin)
		if dir.length() < 1:
			path_node += 1
		else:
			# Set velocity and rotation based on dir
			dir = dir.normalized()
			#var old_angle: float = rotation.y
			par.look_at(path[path_node], Vector3.UP)
			#var new_angle: float = rotation.y
			par.rotation.x = 0
			par.rotation.z = 0
			var vel: Vector3 = Vector3()
			return vel.linear_interpolate(dir * max_speed, accel * delta)
			
	return Vector3()
	
func stop() -> void:
	path = []
	path_node = 0
