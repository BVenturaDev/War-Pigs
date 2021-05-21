extends Sprite3D

export (Resource) var first_action
export (Resource) var second_action

onready var viewport = $Viewport
onready var description_label = $Viewport/VBoxContainer/Desription
onready var input_label = $Viewport/VBoxContainer/Input
onready var press_label = $Viewport/VBoxContainer/Press

func _ready():
	texture = $Viewport.get_texture()
	get_action_string(first_action)
		
func get_action_string(scancode: TutorialLabel):
	var input = scancode.get_scancode_string()
	input_label.text = input
	description_label.text = "to " + str(scancode.action_description)
	
func change_text(scancode: TutorialLabel):
	var input = scancode.get_scancode_string()
	input_label.text = input
	description_label.text = "to " + str(scancode.action_description)

func _input(event):
	if event.is_action_pressed(first_action.action_string):
		change_text(second_action)
	elif event.is_action_pressed(second_action.action_string):
		change_text(first_action)
