extends Node

var main_volume: float = 0.2

func _ready():
	# TODO: save/load preferences
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(main_volume))
