extends KinematicBody

# Constants
const MAXHP: int = 100

# States
enum states {IDLE, CHARGE, ATTACK, KO, TUTORIAL}
var state: int = states.IDLE

# Preloads
var pig_scene = preload("res://scenes/components/Minion.tscn")

# Exports
export var hit_damage: int = 20
export var max_speed: float = 300.0
export var max_crawl: float = 150.0
export var accel: float = 6.0
export var player_attack_chance: float = 9.9

export (bool) var tutorial_behaviour = false
export (int) var tutorial_health = 0

# Debug Colors
export (Color) var debug_idle
export (Color) var debug_charge
export (Color) var debug_attack
export (Color) var debug_ko 

onready var debug_status = $DebugStatus

# Scene Variables
onready var label = $Recruit_Label
onready var path_finder = $Path_Finder
onready var attack_time = $Attack_Timer
onready var attack_pos = $Attack_Positiions
onready var aggro_rad = $Area
onready var hut_finder = $Hut_Finder
onready var blood_spot = $Blood_Spot
onready var boar = $boar

# Enemy Variables
var hp: int = MAXHP
var alive: bool = true
var target: Node = null
var attack_tar: Node = null
var player: Node = null
var attacking: bool = false
var crawling: bool = false
var player_aggro: bool = false
var fighting_player: bool = false
var fighting_minion: bool = false

func _ready():
	for p in get_tree().get_nodes_in_group("player"):
		player = p
	if Globals.DEBUG:
		debug_status.visible = true
	if tutorial_behaviour:
		hp = 0 + tutorial_health
		state = states.TUTORIAL

func minion_killed(var minion: Node) -> void:
	if minion == target or minion == attack_tar:
		fighting_minion = false
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
	attacking = false
	# Focused on player
	if player_aggro and fighting_player:
		if player and is_instance_valid(player):
			boar.set_attack()
			# Don't deal damage to player
			look_at(player.global_transform.origin, Vector3.UP)
			rotation.x = 0
			rotation.z = 0
			player.damage()
		
	# Decide whether or not to attack player
	elif player_aggro and fighting_minion:
		if rand_range(0.0, 10.0) > player_attack_chance:
			if player and is_instance_valid(player):
				boar.set_attack()
				# Don't deal damage to player
				if not tutorial_behaviour:
					player.damage()
				look_at(player.global_transform.origin, Vector3.UP)
				rotation.x = 0
				rotation.z = 0
				return
	# Attack minion	
	elif alive and fighting_minion:
		if is_instance_valid(attack_tar):
			boar.set_attack()
			look_at(attack_tar.global_transform.origin, Vector3.UP)
			rotation.x = 0
			rotation.z = 0
			if attack_tar.damage(hit_damage):
				_find_attacker()
		else:
			_find_attacker()
		
func _check_bodies():
	for body in aggro_rad.get_overlapping_bodies():
		if body.is_in_group("Minions"):
			if not fighting_minion:
				fighting_minion = true
				fighting_player = false
				target = body
				attack_tar = null
				state = states.CHARGE
				break
				
		if body.is_in_group("player"):
			if not state == states.ATTACK or state == states.CHARGE and not fighting_minion and not fighting_player:
				fighting_player = true
				fighting_minion = false
				target = body
				attack_tar = body
				state = states.ATTACK

func _physics_process(var delta: float) -> void:
	if not is_instance_valid(target):
		target = null
	if not is_instance_valid(attack_tar):
		attack_tar = null
	if not tutorial_behaviour and not state == states.KO:
		_check_bodies()
	var vel: Vector3 = Vector3()
	# Do movement
	vel = path_finder.calculate_vel(max_speed, accel, delta)
	
	if state == states.CHARGE and target:
		if Globals.DEBUG:
			debug_status.change_color(debug_charge)
		var tar: Node = attack_pos.get_attacker()
		if tar:
			attacker(tar)
	
	# Attack the target
	if state == states.ATTACK :
		if Globals.DEBUG:
			debug_status.change_color(debug_attack)
		if attack_tar:
			if not attacking:
				attacking = true
				attack_time.start()
		else:
			_find_attacker()
			
	if state == states.KO:
		if Globals.DEBUG:
			debug_status.change_color(debug_ko)
			
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
				
	if state == states.TUTORIAL:
		if hp < 1 and alive:
			alive = false
			label.visible = true
	# Check if KO'd
	elif hp < 1 and alive:
		get_tree().call_group("Minions", "enemy_killed", self)
		attack_pos.clear_attackers()
		alive = false
		label.visible = true
		
		state = states.KO
		boar.set_crawl_idle()
	
	# Do gravity
	if not is_on_floor():
		vel.y = Globals.GRAV
	var _v = move_and_slide(vel, Vector3.UP)
	var dist = abs(vel.x) + abs(vel.z)
	if dist >= Globals.ANIM_VEL and alive:
		boar.set_run()
	elif alive:
		boar.set_idle()
	elif dist >= Globals.ANIM_VEL:
		boar.set_crawl()
	else:
		boar.set_crawl_idle()
	

func attacker(var tar: Node) -> void:
	target = tar
	#path_finder.stop()
	attack_tar = tar
	attack_tar.attack(self)
	state = states.ATTACK
	
func _find_attacker():
	attack_tar = attack_pos.get_attacker()
	if not attack_tar:
		target = null
		attack_tar = null
		state = states.IDLE
		fighting_minion = false
	
# Convert to a minion
func recruit() -> void:
	if state == states.KO or state == states.TUTORIAL:
		var pig = pig_scene.instance()
		get_parent().add_child(pig)
		pig.global_transform = global_transform
		pig.join_formation()
		get_tree().call_group("Minions", "target_killed", self)
		call_deferred("queue_free")

func damage(var dam: int) -> bool:
	if alive:
		Globals.make_blood(blood_spot.global_transform.origin)
		hp -= dam
		if hp < 1:
			return true
		return false
	return true


func _on_Player_Aggro_body_entered(body):
	if body.is_in_group("player"):
		player_aggro = true


func _on_Player_Aggro_body_exited(body):
	if body.is_in_group("player"):
		player_aggro = false
