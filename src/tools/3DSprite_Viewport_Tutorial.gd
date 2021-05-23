extends Sprite3D

export (Resource) var first_action
export (Resource) var second_action

# Allow swapping
export (bool) var swap_actions = true

export (int) var font_size =0

onready var viewport = $Viewport
onready var description_label = $Viewport/VBoxContainer/Desription
onready var input_label = $Viewport/VBoxContainer/Input
onready var press_label = $Viewport/VBoxContainer/Press

enum states {FIRST, SECOND}
var state

var first_action_string: String
var second_action_string: String

func _ready():
	texture = $Viewport.get_texture()
	get_action_string(first_action)
	state = states.FIRST
	
	#description_label.get("custom_fonts/font").size  = font_size # Set Font
	#input_label.get("custom_fonts/font").size  = font_size # Set Font
	#press_label.get("custom_fonts/font").size  = font_size # Set Font
		
func get_action_string(scancode: TutorialLabel):
	var input = scancode.get_scancode_string()
	input_label.text = input
	description_label.text = "to " + str(scancode.action_description)
	
func change_text(scancode: TutorialLabel):
	var input = scancode.get_scancode_string()
	input_label.text = input
	description_label.text = "to " + str(scancode.action_description)

func _input(event):
	if first_action != null and is_instance_valid(first_action):
		if event.is_action_pressed(first_action.action_string) and swap_actions:
			change_text(second_action)
			state = states.SECOND
	if second_action != null and is_instance_valid(second_action):
		if event.is_action_pressed(second_action.action_string) and swap_actions:
			change_text(first_action)
			state = states.FIRST

func _process(delta):
	match state:
		states.FIRST:
			var current_string = first_action.string_value
			if current_string != first_action.get_scancode_string():
				change_text(first_action)
		states.SECOND:
			var current_string = second_action.string_value
			if current_string != second_action.get_scancode_string():
				change_text(second_action)
