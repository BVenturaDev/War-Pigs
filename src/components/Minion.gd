extends KinematicBody

# States
enum states {FOLLOW, ATTACK, RAID}
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

# Raid variables
var raid_position: Position3D
var raiding_entity: Raidable

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
		elif body.is_in_group("raidable"):
			# Acquire position in hut
			var position = body.give_position()
			if position != null:	# Position available
				raid_position = position
				# MESS... Have target be position to move towards.
				"""
				Not setting target caused the pig to move to another direction.
				This caused me a lot of time to figure it out.
				"""
				target = null
				target = raid_position
				# Move to that position in Hut
				path_finder.move_to(raid_position.global_transform.origin)
				#path_finder.move_to(raid_position.translation)
				raiding_entity = body
				state = states.RAID
			

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
	
func target_killed(var tar: Node) -> void:
	if attack_tar == tar or target == tar:
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
	# RAID STATE
	if state == states.RAID:
		# Reached position in Hut
		if path_finder.has_path() == false:
			# Avoid checking on a freed object
			if is_instance_valid(raiding_entity):
				if raiding_entity.is_destroyed():
					# Clean up
					raiding_entity.retrieve_position(raid_position)
					raid_position = null
					raiding_entity = null
					line_up()	# Objective complete
				else:	# Attack Hut
					if $Raid_Timer.is_stopped():
						raiding_entity.decrease_health(damage)
						$Raid_Timer.start()
			else:	# Hut destroyed
				raiding_entity = null
				raid_position = null
				line_up()
