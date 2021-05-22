extends KinematicBody

export var max_speed: float = 350.0
export var accel: float = 6.0

onready var pig = $pig
onready var search_timer = $Search_Timer
onready var path_finder = $Path_Finder

var player: Node = null
var target: Node = null

func _ready():
	for i in get_tree().get_nodes_in_group("player"):
		player = i
	pig.set_banner()
	target = player.banner_pos
	
func _physics_process(delta):
	var vel: Vector3 = path_finder.calculate_vel(max_speed, accel, delta)
	# Stick to the floor
	if not is_on_floor():
		vel.y = Globals.GRAV
	var _v = move_and_slide(vel, Vector3.UP)
	if abs(vel.x) + abs(vel.z) > Globals.ANIM_VEL:
		pig.set_banner_run()
	else:
		pig.set_banner()


func _on_Search_Timer_timeout():
	# Update our path finding
	if target:
		path_finder.update_path(target)
