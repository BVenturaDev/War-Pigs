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
onready var charge_sound = $ChargeSound
onready var recall_sound = $RecallSound
onready var banner_pos = $Banner_Pos

func _interact():
	var col = interact_tar.get_collider()
	if col:
		if col.is_in_group("Enemies"):
			if not col.alive:
				col.recruit()
		if col.is_in_group("buyable"):
			var total_spent = buy_item(col, Globals.total_currency)
			Globals.total_currency -= total_spent
		if col.is_in_group("sellable"):
			sell_item(col)

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
		recall_sound.play()
	if Input.is_action_just_pressed("charge"):
		formations.charge()
		charge_sound.play()
	if Input.is_action_just_pressed("ui_select"):
		_interact()

func count_minions(save_pigs: bool):
	if save_pigs:
		var total_minions = formations.total_minions()
		Globals.total_pigs = total_minions
	

#######
## Buying/Selling Interface
#######
func buy_item(item: Buyable, amount: int) -> int:
	if item.can_buy(amount):
		var total_spent = item.spent(amount)
		item_logic(item)
		
		# Have item remain available
		if item.is_consumable():
			item.destroy_item()
		return total_spent
	else:
		print_debug("can't buy anything")
		# Did not spend anything
		return 0

# Deals with the various kinds of items that can be bought
# Not the most scalable approach
func item_logic(item: Buyable):
	match item.get_type():
		"helmet":
			buy_helmet()
		"shoulder":
			buy_shoulders()
		"breastplate":
			buy_breastplate()
		"pig":
			buy_pig()

func buy_shoulders():
	print_debug("Bought Shoulders")
	
func buy_helmet():
	print_debug("Bought Helmet")
	
func buy_breastplate():
	print_debug("Bought Breastplate")
	
func buy_pig():
	Globals.total_pigs += 1
	
func sell_item(item: Sellable):
	if can_sell_item(item):
		var item_type = item.get_type()
		match item_type:
			"pig":
				sell_pig()
		var profit = item.get_profit()
		Globals.total_currency += profit

func sell_pig():
	Globals.total_pigs -= 1
	
func can_sell_item(item: Sellable):
	match item.get_type():
		"pig":
			return Globals.total_pigs > 0
	return false
