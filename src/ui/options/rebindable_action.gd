extends Control

export(String) var action
var _editing = false

onready var _button = $Button

func _ready():
	_update_button_text(InputMap.get_action_list(action)[0])


func _input(input_event: InputEvent) -> void:
	if _editing and not input_event is InputEventMouseMotion:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, input_event)
		_update_button_text(input_event)
		_editing = false


func _update_button_text(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton:
			if input_event.button_index == BUTTON_LEFT:
				_button.text = "Mouse Left"
			elif input_event.button_index == BUTTON_RIGHT:
				_button.text = "Mouse Right"
			elif input_event.button_index == BUTTON_MIDDLE:
				_button.text = "Mouse Middle"
	else:
		_button.text = input_event.as_text()

func _on_Button_pressed() -> void:
	_editing = true
