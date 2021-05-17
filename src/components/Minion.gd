extends KinematicBody

# States
enum states {FOLLOW, ATTACK}
var state: int = states.FOLLOW

# Exports
export var max_speed: float = 300.0
export var accel: float = 6.0
export var damage: int = 5
#export var turn_speed: float = 10.0

# Scene Nodes
onready var player: KinematicBody = $"../../Player"
onready var path_finder: Spatial = $Path_Finder
onready var attack_time: Timer = $Attack_Timer

# Minion Variables
var path: Array = []
var path_node: int = 0
var target: Node = null
var attack_tar: Node = null
var in_formation: bool = false
var form_id: int = -1
var attacking: bool = false

func _state_follow() -> void:
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

func _on_Search_Timer_timeout():
	# Update our path finding
	if target:
		path_finder.update_path(target)

func _on_Area_body_entered(body):
	if state == states.FOLLOW:
		if body.is_in_group("Enemies"):
			if body.alive:
				# Found a live enemy, engage them
				target = body
				path_finder.update_path(target)
				state = states.ATTACK

func _on_Attack_Timer_timeout():
	attacking = false
	if attack_tar:
		attack_tar.damage(damage)
	else:
		line_up()

func join_formation() -> void:
	player.formations.add_minion(self)
	in_formation = true
	state = states.FOLLOW
	attack_tar = null

func line_up():
	attack_tar = null
	player.formations.update_target(form_id)
	in_formation = true
	state = states.FOLLOW
	
func enemy_killed(var enemy: Node) -> void:
	if attack_tar == enemy:
		line_up()

func _physics_process(var delta: float) -> void:
	var vel: Vector3 = path_finder.calculate_vel(max_speed, accel, delta)
	if state == states.FOLLOW:
		_state_follow()
	# Stick to the floor
	if not is_on_floor():
		vel.y = Globals.GRAV
	var _v = move_and_slide(vel, Vector3.UP)
	if state == states.ATTACK and not attacking:
		for i in get_slide_count():
			var col = get_slide_collision(i).collider
			if col.has_method("is_in_group"):
				if col.is_in_group("Enemies") and attack_time.is_stopped():
					attacking = true
					attack_tar = col
					attack_time.start()
					break
