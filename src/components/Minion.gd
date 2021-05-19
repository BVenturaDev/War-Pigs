extends KinematicBody

# States
enum states {FOLLOW, ATTACK, RAID}
var state: int = states.FOLLOW

# Exports
export var max_speed: float = 300.0
export var accel: float = 6.0
export var hit_damage: int = 5
export var hp: int = 100
#export var turn_speed: float = 10.0

# Scene Nodes
onready var player: KinematicBody = $"../../Player"
onready var path_finder: Spatial = $Path_Finder
onready var attack_time: Timer = $Attack_Timer
onready var baggage: Spatial = $Baggage
onready var aggro_rad: Area = $Area

# Minion Variables
var target: Node = null
var attack_tar: Node = null
var in_formation: bool = false
var form_id: int = -1
var attacking: bool = false
var alive: bool = true
var attack_i: int = -1

# Raid variables
var raid_position: Position3D
var raiding_entity: Raidable

func _state_follow() -> void:
	# Find direction along path
	if is_instance_valid(target) and not path_finder.has_path():
		if in_formation:
			look_at(player.global_transform.origin, Vector3.UP)
			rotation.x = 0
			rotation.z = 0
			# Accumulate Raid Wealth
			accumulate_wealth()
		elif target.is_in_group("Target_Spawn"):
			# Reached target, return
			target.queue_free()
			line_up()
			print("Coming back: " + str(form_id))

func _state_attack() -> void:
	if is_instance_valid(target) and not path_finder.has_path() and not in_formation:
		attack_tar = target.get_parent().get_parent().get_parent()
		look_at(attack_tar.global_transform.origin, Vector3.UP)
		rotation.x = 0
		rotation.z = 0
		target = null
	if attack_tar and not attacking:
		attacking = true
		attack_time.start()

func _state_raid() -> void:
	# Reached position in Hut
	if path_finder.has_path() == false:
		# Avoid checking on a freed object
		if is_instance_valid(raiding_entity):
			if raiding_entity.is_destroyed():
				# Clean up
				raiding_entity.retrieve_position(raid_position, self)
				raid_position = null
				raiding_entity = null
				line_up()	# Objective complete
			else:	# Attack Hut
				if $Raid_Timer.is_stopped():
					raiding_entity.decrease_health(hit_damage)
					$Raid_Timer.start()
		else:	# Hut destroyed
			raiding_entity = null
			raid_position = null
			line_up()

func _on_Search_Timer_timeout():
	# Update our path finding
	if target:
		path_finder.update_path(target)

func _check_bodies():
	for body in aggro_rad.get_overlapping_bodies():
		if state == states.FOLLOW:
			if body.is_in_group("Enemies"):
				if body.alive:
					# Found a live enemy, engage them
					attack_i = body.attack_pos.find_pos()
					# Check if enemy has room for more attackers
					if attack_i > -1:
						target = body.attack_pos.add_attacker(self, attack_i)
						path_finder.update_path(target)
						state = states.ATTACK
						break
			elif body.is_in_group("raidable"):
				# Acquire position in hut
				var position = body.give_position(self)
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
					break
			

func _on_Attack_Timer_timeout():
	attacking = false
	if attack_tar:
		look_at(attack_tar.global_transform.origin, Vector3.UP)
		if attack_tar.damage(hit_damage):
			line_up()
	else:
		line_up()

func damage(var dam: int) -> bool:
	hp -= dam
	if hp < 1:
		return true
	return false

func join_formation() -> void:
	player.formations.add_minion(self)
	in_formation = true
	state = states.FOLLOW
	attack_tar = null

func line_up():
	path_finder.stop()
	attack_tar = null
	player.formations.update_target(form_id)
	in_formation = true
	state = states.FOLLOW
	
func target_killed(var tar: Node) -> void:
	if attack_tar == tar or target == tar:
		line_up()

func _physics_process(var delta: float) -> void:
	_check_bodies()
		
	var vel: Vector3 = path_finder.calculate_vel(max_speed, accel, delta)
	if state == states.FOLLOW:
		_state_follow()
	# Stick to the floor
	if not is_on_floor():
		vel.y = Globals.GRAV
	var _v = move_and_slide(vel, Vector3.UP)
	
	if state == states.ATTACK:
		_state_attack()
	
	if state == states.RAID:
		_state_raid()
		
	if hp < 1 and alive:
		alive = false
		get_tree().call_group("Enemies", "minion_killed", self)
		player.formations.reshuffle(form_id)
		if attack_tar:
			attack_tar.attack_pos.remove_attacker(attack_i)
		call_deferred("queue_free")

######
## Currency
######

func accumulate_wealth():
	if baggage.has_currency():
		remove_currency()

### Baggage Interface
func pass_currency(c):
	baggage.give_currency(c)
	
func remove_currency():
	var c: CurrencyData = baggage.remove_currency()
	#print_debug("Wealth Acquired: " + str(c.get_amount()))
	Globals.add_to_currency(c.get_amount())
	# Do something with currency
	
