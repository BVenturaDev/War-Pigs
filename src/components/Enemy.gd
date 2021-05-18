extends KinematicBody

# States
enum states {IDLE, CHARGE, ATTACK, KO}
var state: int = states.IDLE

# Preloads
var pig_scene = preload("res://scenes/components/Minion.tscn")

# Exports
export var hit_damage: int = 10
export var max_speed: float = 300.0
export var accel: float = 6.0

# Scene Variables
onready var label = $Recruit_Label
onready var path_finder = $Path_Finder
onready var attack_time = $Attack_Timer

# Enemy Variables
var hp: int = 100
var alive: bool = true
var target: Node = null
var attacking: bool = false

func _on_Search_Timer_timeout():
	# Update our path finding
		if target:
			path_finder.update_path(target)
	
func _on_Area_body_entered(body):
	if state == states.IDLE and not target == null:
		if body.is_in_group("Minions"):
			target = body
			state = states.CHARGE

func _physics_process(var delta: float) -> void:
	var vel: Vector3 = path_finder.calculate_vel(max_speed, accel, delta)
	# Do gravity
	if not is_on_floor():
		vel.y = Globals.GRAV
	# Do movement
	if state == states.CHARGE and not attacking:
	var _v = move_and_slide(vel, Vector3.UP)
		for i in get_slide_count():
			if col.has_method("is_in_group"):
			var col = get_slide_collision(i).collider
				if col.is_in_group("Minions") and attack_time.is_stopped():
					
	# Check if KO'd
					state = states.ATTACK
	if hp < 1 and alive:
		get_tree().call_group("Minions", "enemy_killed", self)
		alive = false
		label.visible = true
		state = states.KO

# Convert to a minion
func recruit() -> void:
	if state == states.KO:
		var pig = pig_scene.instance()
		get_parent().add_child(pig)
		pig.global_transform = global_transform
		pig.join_formation()
		get_tree().call_group("Minions", "target_killed", self)
		queue_free()
		


func damage(var dam: int) -> void:
	hp -= dam
