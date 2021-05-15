extends KinematicBody

# Exports
export var max_speed: float = 300.0
export var accel: float = 6.0
#export var turn_speed: float = 10.0

# Scene Nodes
onready var nav: Navigation = get_parent()
onready var player: KinematicBody = $"../../Player"

# Minion Variables
var path: Array = []
var path_node: int = 0
var target: Node = null
var in_formation: bool = false
var form_id: int = -1

func join_formation() -> void:
	player.add_minion(self)
	in_formation = true

func line_up():
	player.update_target(form_id)
	in_formation = true

func move_to(target_pos) -> void:
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func update_path() -> void:
	if target:
		# Go to the closest position to target
		move_to(nav.get_closest_point(target.global_transform.origin))

func _physics_process(var delta: float) -> void:
	var vel: Vector3 = Vector3()
	# Find direction along path
	if path_node < path.size():
		var dir = (path[path_node] - global_transform.origin)
		if dir.length() < 1:
			path_node += 1
		else:
			# Set velocity and rotation based on dir
			dir = dir.normalized()
			#var old_angle: float = rotation.y
			look_at(path[path_node], Vector3.UP)
			#var new_angle: float = rotation.y
			rotation.x = 0
			rotation.z = 0
			vel = vel.linear_interpolate(dir * max_speed, accel * delta)
	elif target:
		if in_formation:
			look_at(player.global_transform.origin, Vector3.UP)
			rotation.x = 0
			rotation.z = 0
		elif target.is_in_group("Target_Spawn"):
			target.queue_free()
			line_up()
			print("Coming back: " + str(form_id))
	# Stick to the floor
	if not is_on_floor():
		vel.y = Globals.GRAV		
	var _collisions = move_and_slide(vel, Vector3.UP)

func _on_Search_Timer_timeout():
	if target:
		update_path()
