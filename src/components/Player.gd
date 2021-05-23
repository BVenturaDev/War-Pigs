extends KinematicBody

# Exports
export var mouse_sensitivity: float = 0.06
export var max_speed: float = 30.0
export var accel: float = 6.0
export var hit_damage: float = 40.0

# Scenes
var pig_scene = preload("res://scenes/components/Minion.tscn")

# Player Variables
var main: Node = null
var vel: Vector3 = Vector3()
var can_attack: bool = true
var can_hit: bool = true

# Scene Variables
onready var camera_control = $Camara_Control
onready var formations = $Formations
onready var interact_tar = $Camara_Control/interact_Target
onready var charge_sound = $ChargeSound
onready var recall_sound = $RecallSound
onready var banner_pos = $Banner_Pos
onready var pig = $pig
onready var sword_sound_player = $SwordSoundPlayer
onready var blood_spot = $Blood_Spot

# Signals
signal charge
signal return_formation
signal died

func _interact():
	var col = interact_tar.get_collider()
	if col:
		if col.is_in_group("Enemies"):
			if not col.alive:
				col.recruit()
		if col.is_in_group("buyable"):
			buy_item(col, Globals.total_currency)
		if col.is_in_group("sellable"):
			sell_item(col)

func _on_Swing_Timer_timeout():
	can_attack = true

func _attack() -> void:
	# Only hit while doing attack animation and only hit once per swing
	if can_hit and can_attack and pig.state_machine.get_current_node() == "Attack":
		for body in pig.sword_area.get_overlapping_bodies():
			if body.is_in_group("Enemies"):
				if body.alive:
					can_hit = false
					can_attack = false
					var _live: bool = body.damage(hit_damage)
					break

func _adjust_gear() -> void:
	if Globals.hp <= 4:
		pig.helmet.visible = false
	else:
		pig.helmet.visible = true
		
	if Globals.hp <= 3:
		pig.shoulder_pads.visible = false
	else:
		pig.shoulder_pads.visible = true
		
	if Globals.hp <= 2:
		pig.breastplate.visible = false
	else:
		pig.breastplate.visible = true
		
	if Globals.hp <= 1:
		pig.tunic.visible = false
	else:
		pig.tunic.visible = true

func _ready():
	main = get_parent()

func _input(var event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		camera_control.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		camera_control.rotation.x = clamp(camera_control.rotation.x, deg2rad(-89.0), deg2rad(50.0))

func _physics_process(var delta: float) -> void:
	_adjust_gear()
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
	
	if Input.is_action_pressed("attack"):
		if can_attack:
			can_attack = false
			pig.set_attack()
			can_hit = true
			sword_sound_player.play_random_sound()
	elif abs(vel.x) + abs(vel.z) >= max_speed and can_attack:
		pig.set_run()
	else:
		pig.set_idle()
	_attack()
	
	# Handle other controls
	if Input.is_action_just_pressed("primary"):
		formations.attack_individual()
	if Input.is_action_just_pressed("secondary"):
		emit_signal("return_formation")
		formations.return_to_formation()
		recall_sound.play()
	if Input.is_action_just_pressed("charge"):
		emit_signal("charge")
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
func buy_item(item: Buyable, amount: int):
	if item.can_buy(amount):
		item_logic(item, amount)
		
		# Have item remain available
		if item.is_consumable():
			item.destroy_item()
	else:
		print_debug("can't buy anything")
		# Did not spend anything


# Deals with the various kinds of items that can be bought
# Not the most scalable approach
func item_logic(item: Buyable, amount: int):
	match item.get_type():
		"health":
			if buy_health():
				Globals.total_currency -= item.spent(amount)
		"pig":
			if buy_pig():
				Globals.total_currency -= item.spent(amount)

func buy_health() -> bool:
	if Globals.hp < Globals.MAXHP:
		Globals.hp += 1
		_adjust_gear()
		return true
	return false
	
func buy_pig() -> bool:
	# Spawn pig
	var new_minion = pig_scene.instance()
	var nav = get_parent().get_node("Navigation")
	nav.add_child(new_minion)
	new_minion.global_transform = self.global_transform
	new_minion.join_formation()
	
	#Update total pigs
	Globals.total_pigs += 1
	
	return true

	
func sell_item(item: Sellable):
	if can_sell_item(item):
		var item_type = item.get_type()
		match item_type:
			"pig":
				sell_pig()
		var profit = item.get_profit()
		Globals.total_currency += profit

func sell_pig():
	formations.remove_last_pig()
	
	Globals.total_pigs -= 1
	
func can_sell_item(item: Sellable):
	match item.get_type():
		"pig":
			return Globals.total_pigs > 0
	return false

func damage() -> void:
	Globals.make_blood(blood_spot.global_transform.origin)
	Globals.hp -= 1
	_adjust_gear()
	if Globals.hp <= 0:
		Globals.hp = 0
		emit_signal("died")
		#print("YOU DED")
