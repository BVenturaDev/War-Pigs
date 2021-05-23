extends Resource
class_name InputMapString

"""
Stores information about an action 
to display in the tutorial
"""

export (String) var action_string	
	

func get_scancode_string() -> String:
	var event = InputMap.get_action_list(action_string)
	if event.size() <= 0:
		return ""

	var event_input = event[0]
	if event_input is InputEventKey:
		return OS.get_scancode_string(event_input.scancode)
	elif event_input is InputEventMouseButton:
		var button_string = mouse_button_string(event_input)
		return button_string
	else:
		printerr("Unknown InputEvent")
		return ""

func mouse_button_string(e: InputEventMouseButton):
	match e.button_index:
		BUTTON_LEFT:
			return "Left Mouse Button"
		BUTTON_MASK_RIGHT:
			return "Right Mouse Button"
		BUTTON_MIDDLE:
			return "Middle Mouse Button"
