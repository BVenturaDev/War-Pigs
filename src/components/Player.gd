extends KinematicBody

# Exports
export var mouse_sensitivity: float = 0.06
export var max_speed: float = 30.0
export var accel: float = 6.0

# Player Variables
var main: Node = null
var vel: Vector3 = Vector3()

# Scene Variables
onready var camera_control = $Camara_Control
onready var formations = $Formations
onready var interact_tar = $Camara_Control/interact_Target

func _interact():
	var col = interact_tar.get_collider()
	if col:
		if col.is_in_group("Enemies"):
			if not col.alive:
				col.recruit()
		if col.is_in_group("buyable"):
			print_debug("I can buy it!")

func _ready():
	main = get_parent()

func _input(var event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		camera_control.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		camera_control.rotation.x = clamp(camera_control.rotation.x, deg2rad(-89.0), deg2rad(50.0))

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
		formations.attack_individual()
	if Input.is_action_just_pressed("secondary"):
		formations.return_to_formation()
	if Input.is_action_just_pressed("charge"):
		formations.charge()
	if Input.is_action_just_pressed("ui_select"):
		_interact()
