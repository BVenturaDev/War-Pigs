extends KinematicBody

# Constants
const MAXHP: int = 100

# States
enum states {IDLE, CHARGE, ATTACK, KO}
var state: int = states.IDLE

# Preloads
var pig_scene = preload("res://scenes/components/Minion.tscn")

# Exports
export var hit_damage: int = 20
export var max_speed: float = 300.0
export var max_crawl: float = 150.0
export var accel: float = 6.0

# Scene Variables
onready var label = $Recruit_Label
onready var path_finder = $Path_Finder
onready var attack_time = $Attack_Timer
onready var attack_pos = $Attack_Positiions
onready var aggro_rad = $Area
onready var hut_finder = $Hut_Finder

# Enemy Variables
var hp: int = MAXHP
var alive: bool = true
var target: Node = null
var attack_tar: Node = null
var attacking: bool = false
var crawling: bool = false

func minion_killed(var minion: Node) -> void:
	if minion == target or minion == attack_tar:
		target = null
		attack_tar = null
		path_finder.stop()
		if state == states.ATTACK:
			_find_attacker()

func _on_Search_Timer_timeout() -> void:
	# Update our path finding
	if is_instance_valid(target):
		path_finder.update_path(target)
	
func _on_Attack_Timer_timeout():
	if is_instance_valid(attack_tar):
		attacking = false
		look_at(attack_tar.global_transform.origin, Vector3.UP)
		if attack_tar.damage(hit_damage):
			_find_attacker()
	else:
		_find_attacker()
		
func _check_bodies():
	for body in aggro_rad.get_overlapping_bodies():
		if not target:
			if body.is_in_group("Minions"):
				if not body.state == body.states.ATTACK:
					target = body
					state = states.CHARGE
					break

func _physics_process(var delta: float) -> void:
	if not is_instance_valid(target):
		target = null
	if not is_instance_valid(attack_tar):
		attack_tar = null
	if state == states.IDLE:
		_check_bodies()
	var vel: Vector3 = Vector3()
	# Do gravity
	if not is_on_floor():
		vel.y = Globals.GRAV
	# Do movement
	vel = path_finder.calculate_vel(max_speed, accel, delta)
	
	if state == states.CHARGE and target:
		var tar: Node = attack_pos.get_attacker()
		if tar:
			attacker(tar)
	
	# Attack the target
	if state == states.ATTACK :
		if attack_tar:
			if not attacking:
				attacking = true
				attack_time.start()
		else:
			_find_attacker()
			
	if state == states.KO:
		vel = path_finder.calculate_vel(max_crawl, accel, delta)
		if not crawling or not is_instance_valid(target) or target == null:
			target = hut_finder.find_nearest_hut(global_transform.origin)
			crawling = true
			path_finder.update_path(target)
		else:
			if is_instance_valid(target) and not path_finder.has_path() and target:
				state = states.IDLE
				crawling = false
				target = null
				attack_tar = null
				alive = true
				hp = MAXHP
				label.visible = false
				
	# Check if KO'd
	if hp < 1 and alive:
		get_tree().call_group("Minions", "enemy_killed", self)
		alive = false
		label.visible = true
		state = states.KO
		
	var _v = move_and_slide(vel, Vector3.UP)

func attacker(var tar: Node) -> void:
	target = null
	path_finder.stop()
	attack_tar = tar
	attack_tar.attack(self)
	state = states.ATTACK
	
func _find_attacker():
	attack_tar = attack_pos.get_attacker()
	if not attack_tar:
		target = null
		attack_tar = null
		state = states.IDLE
	
# Convert to a minion
func recruit() -> void:
	if state == states.KO:
		var pig = pig_scene.instance()
		get_parent().add_child(pig)
		pig.global_transform = global_transform
		pig.join_formation()
		get_tree().call_group("Minions", "target_killed", self)
		call_deferred("queue_free")

func damage(var dam: int) -> bool:
	hp -= dam
	if hp < 1:
		return true
	return false
