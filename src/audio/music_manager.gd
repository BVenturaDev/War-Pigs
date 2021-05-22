extends Node

const MARCH_MINIMUM_PIGS_SECOND_LAYER = 5
const MARCH_MINIMUM_PIGS_THIRD_LAYER = 10

const WAR_MINIMUM_PIGS_SECOND_LAYER = 5
const WAR_MINIMUM_PIGS_THIRD_LAYER = 10

onready var _current_music = $March
var _is_march_on = true


func _ready() -> void:
	Globals.connect("total_pigs_updated", self, "_update_march_layers")
	Globals.connect("combat_pigs_updated", self, "_handle_track_switch")


func _set_layer_volume(layer_name: String, volume: float) -> void:
	for music_layer in _current_music.get_node(layer_name).get_children():
		music_layer.set_volume_db(linear2db(1))


func _update_march_layers(total_pigs: int) -> void:
	if _is_march_on:
		_update_music_layers(total_pigs, MARCH_MINIMUM_PIGS_SECOND_LAYER, MARCH_MINIMUM_PIGS_THIRD_LAYER)


func _update_music_layers(total_pigs: int, first_threshold: int, second_threshold: int) -> void:
	if total_pigs >= first_threshold:
		_set_layer_volume("SecondLayer", 1.0)
	elif total_pigs >= second_threshold:
		_set_layer_volume("SecondLayer", 1.0)
		_set_layer_volume("ThirdLayer", 1.0)
	else:
		_set_layer_volume("SecondLayer", 0.0)
		_set_layer_volume("ThirdLayer", 0.0)


func _handle_track_switch(total_combat_pigs: int) -> void:
	if _is_march_on:
		if total_combat_pigs > 0:
			_set_layer_volume("MainLayer", 0.0)
			_set_layer_volume("SecondLayer", 0.0)
			_set_layer_volume("ThirdLayer", 0.0)
			_current_music = $War
			_is_march_on = false
			_set_layer_volume("MainLayer", 1.0)
	else:
		if total_combat_pigs == 0:
			_set_layer_volume("MainLayer", 0.0)
			_set_layer_volume("SecondLayer", 0.0)
			_set_layer_volume("ThirdLayer", 0.0)
			_current_music = $March
			_is_march_on = true
			_set_layer_volume("MainLayer", 1.0)

	_update_music_layers(total_combat_pigs, WAR_MINIMUM_PIGS_SECOND_LAYER, WAR_MINIMUM_PIGS_THIRD_LAYER)
