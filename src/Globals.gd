extends Node

# Constants
const GRAV: float = -30.0
const ATTACKDIST: float = -110.0

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var options: Node = null

# Currency
var total_currency: int

func _ready() -> void:
	self.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	options = options_scene.instance()
	get_tree().get_root().call_deferred("add_child", options)
	options.visible = false
	
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
