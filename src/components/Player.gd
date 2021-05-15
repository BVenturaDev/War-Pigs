extends KinematicBody

# Preloads
var targ_pos_spawn = preload("res://scenes/components/Target_Pos_Spawn.tscn")

# Exports
export var mouse_sensitivity: float = 0.06
export var max_speed: float = 30.0
export var accel: float = 6.0

# Player Variables
var main: Node = null
var vel: Vector3 = Vector3()
var form1: Array = []
var form1_pos: Array = []
var form1_cur_i: int = 0
var form1_sel_i: int = 0

# Scene Variables
onready var camera_control = $Camara_Control
onready var Line1 = $Formations/Line1
onready var target_pos = $Target_Pos

func _ready():
	main = get_parent()
	# Add the formation positions to the Array
	for i in Line1.get_child_count():
		form1_pos.append(Line1.get_child(i))
	get_tree().call_group("Minions", "join_formation")

func _set_target(var i: int, var tar: Node) -> void:
	form1[i].target = tar 
	form1[i].update_path()

# Add a minion to an available position
func add_minion(var minion: KinematicBody):
	if form1_cur_i < 10:
		form1.append(minion)
		# Set the target to the position in formation
		form1[form1_cur_i].form_id = form1_cur_i
		_set_target(form1_cur_i, form1_pos[form1_cur_i])
		print("Added Minion: " + str(minion.name))
		form1_cur_i += 1

# Give the minion it's target in formation
func update_target(var i: int) -> void:
	_set_target(i, form1_pos[i])

func _input(var event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		camera_control.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		camera_control.rotation.x = clamp(camera_control.rotation.x, deg2rad(-89.0), deg2rad(50.0))

func _create_pos(var pos: Node) -> Node:
	var new_pos = targ_pos_spawn.instance()
	main.add_child(new_pos)
	new_pos.global_transform = pos.global_transform
	return new_pos

func _update_sel_i() -> void:
	for i in form1:
		if i.in_formation:
			form1_sel_i = i.form_id
			break

func _attack_pos() -> void:
	if form1_sel_i == 10:
		form1_sel_i = 0
		return
		
	_update_sel_i()
	print("Attack")
	if form1[form1_sel_i].in_formation:
		print("Attacking with minion: " + str(form1_sel_i))
		# Send minion forward to attack position
		form1[form1_sel_i].target = _create_pos(target_pos)
		form1[form1_sel_i].in_formation = false
		form1[form1_sel_i].update_path()
		form1_sel_i += 1
	# Select next minion
	else:
		form1_sel_i += 1
		# Hella Recursion Bro
		_attack_pos()
		
func _return_to_formation() -> void:
		for i in form1:
			if not i.in_formation:
				i.line_up()
		
func _physics_process(var delta: float) -> void:
	# Get player movement controls
	var in_vec: Vector2 = Vector2()
	in_vec.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	in_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var dir: Vector3 = Vector3()
	# Set forward / backward
	dir += transform.basis.z * in_vec.y
	# Set left / right
	dir += transform.basis.x * in_vec.x
	dir = dir.normalized()
	
	# Set vel based on input
	vel = vel.linear_interpolate(dir * max_speed, accel * delta)
	vel.y = 0
	# Stay on floor
	if not is_on_floor():
		vel.y = Globals.GRAV
		
	var _collisions = move_and_slide(vel, Vector3.UP)
	
	# Handle other controls
	if Input.is_action_just_pressed("primary"):
		_attack_pos()
	if Input.is_action_just_pressed("secondary"):
		_return_to_formation()
