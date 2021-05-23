extends Control

var player_dead = false

export (Resource) var input_action

onready var basic_info = $VBoxContainer/Label
onready var key_info = $CenterContainer/VBoxContainer/InputInfo

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	key_info.text = "Press " + input_action.get_scancode_string() + " to respawn"

func _input(event):
	if player_dead:
		if event.is_action_pressed(input_action.action_string):
			get_tree().paused = false
			var _r = get_tree().reload_current_scene()
