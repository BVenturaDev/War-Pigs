extends KinematicBody

# States
enum states {IDLE, CHARGE, ATTACK, KO}
var state: int = states.IDLE

# Preloads
var pig_scene = preload("res://scenes/components/Minion.tscn")

# Exports
export var hit_damage: int = 20
export var max_speed: float = 300.0
export var accel: float = 6.0

# Scene Variables
onready var label = $Recruit_Label
onready var path_finder = $Path_Finder
onready var attack_time = $Attack_Timer
onready var attack_pos = $Attack_Positiions

# Enemy Variables
var hp: int = 100
var alive: bool = true
var target: Node = null
var attack_tar: Node = null
var attacking: bool = false

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
		
func _on_Area_body_entered(body):
	if state == states.IDLE and not target:
		if body.is_in_group("Minions"):
			target = body
			state = states.CHARGE

func _physics_process(var delta: float) -> void:
	if not is_instance_valid(target):
		target = null
	if not is_instance_valid(attack_tar):
		attack_tar = null
		
	var vel: Vector3 = path_finder.calculate_vel(max_speed, accel, delta)
	# Do gravity
	if not is_on_floor():
		vel.y = Globals.GRAV
	# Do movement
	var _v = move_and_slide(vel, Vector3.UP)
	
	# Attack the target
	if state == states.ATTACK and is_instance_valid(attack_tar) and not attacking:
		attacking = true
		attack_time.start()
		
	# Check if KO'd
	if hp < 1 and alive:
		get_tree().call_group("Minions", "enemy_killed", self)
		alive = false
		label.visible = true
		state = states.KO

func attacker(var tar: Node) -> void:
	target = null
	path_finder.stop()
	attack_tar = tar
	state = states.ATTACK
	
func _find_attacker():
	attack_tar = attack_pos.get_attacker()
	if not attack_tar:
		target = null
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
