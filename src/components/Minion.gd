extends KinematicBody

# Exports
export var max_speed: float = 300.0
export var accel: float = 6.0
#export var turn_speed: float = 10.0

# Scene Nodes
onready var player: KinematicBody = $"../../Player"
onready var path_finder: Spatial = $Path_Finder

# Minion Variables
var path: Array = []
var path_node: int = 0
var target: Node = null
var in_formation: bool = false
var form_id: int = -1

func join_formation() -> void:
	player.formations.add_minion(self)
	in_formation = true

func line_up():
	player.formations.update_target(form_id)
	in_formation = true

func _physics_process(var delta: float) -> void:
	var vel: Vector3 = path_finder.calculate_vel(max_speed, accel, delta)
	# Find direction along path
	if target and not path_finder.has_path():
		if in_formation:
			look_at(player.global_transform.origin, Vector3.UP)
			rotation.x = 0
			rotation.z = 0
		elif target.is_in_group("Target_Spawn"):
			# Reached target, return
			target.queue_free()
			line_up()
			print("Coming back: " + str(form_id))
	# Stick to the floor
	if not is_on_floor():
		vel.y = Globals.GRAV		
	var _collisions = move_and_slide(vel, Vector3.UP)

func _on_Search_Timer_timeout():
	if target:
		path_finder.update_path(target)
