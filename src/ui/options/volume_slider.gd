extends HSlider

export(String) var bus_name = "Master"

var _bus_index = 0

func _ready() -> void:
	_bus_index = AudioServer.get_bus_index(bus_name)
	set_value(Options.get_volume(bus_name))


func _set_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus_index, linear2db(value))


func _on_VolumeSlider_value_changed(value: float) -> void:
	_set_volume(value)
	Options.set_volume(bus_name, value)

