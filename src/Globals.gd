extends Node

# Constants
const GRAV: float = -30.0
const ATTACKDIST: float = -110.0
const ANIM_VEL: float = 1.0

# DEBUG
const DEBUG = true

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var blood = preload("res://scenes/particles/Blood_Splash.tscn")
var options: Node = null

# Player hp
var max_hp = 5
var hp: int = 0

# Currency
var total_currency: int = 0
# Pigs 
var total_pigs: int = 10

# Levels
onready var levels: Array = [
	"res://scenes/levels/Munro_Test_Level_1.tscn",
	"res://scenes/levels/Shop.tscn",
	"res://scenes/levels/Munro_Test_Level_2.tscn",
	"res://scenes/levels/Shop.tscn",
	"res://scenes/levels/Munro_Test_Level_3.tscn",
	"res://scenes/levels/Shop.tscn",
	"res://scenes/levels/Munro_Test_Level_4.tscn",
	"res://scenes/levels/Shop.tscn",
	"res://scenes/levels/Munro_Test_Level_5.tscn",
]



func _ready() -> void:
	self.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	options = options_scene.instance()
	get_tree().get_root().call_deferred("add_child", options)
	options.visible = false
	hp = max_hp
	if DEBUG:
		total_currency = 20

func _process(_delta) -> void:
	if total_currency < 0:
		total_currency = 0
	
func _input(var event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			get_tree().paused = true
			options.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			get_tree().paused = false
			options.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func add_to_currency(value: int):
	total_currency += value
	
func decrease_currency(amount: int):
	total_currency -= int(abs(float(amount)))
	
func make_blood(var pos: Vector3) -> void:
	var blood_splash = blood.instance()
	get_tree().get_root().add_child(blood_splash)
	blood_splash.global_transform.origin = pos


########
## Level Transition Interface
#######

func next_level():
	var level = levels.pop_front()
	return level
