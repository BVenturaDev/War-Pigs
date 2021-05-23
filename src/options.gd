extends Node

# You can adjust the starting values here while debugging so the music/sounds don't annoy you every time
# the _ready() will set those volumes so you don't have to go through the options. 
# Can be useful to load preferences from a file too (not necessary for the jam)
var _buses_volumes = {"Master": 0.5, "Music": 0.75, "Sounds": 1}

func get_volume(bus_name: String) -> float:
	return _buses_volumes[bus_name]


func set_volume(bus_name: String, volume_value: float) -> void:
	_buses_volumes[bus_name] = volume_value


func _ready() -> void:
	self.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	for bus_name in _buses_volumes.keys():
		_set_bus_volume(bus_name)


func _set_bus_volume(bus_name: String) -> void:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear2db(get_volume(bus_name)))
