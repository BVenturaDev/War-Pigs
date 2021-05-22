extends Node

const MINIMUM_PIGS_SECOND_LAYER = 5
const MINIMUM_PIGS_THIRD_LAYER = 10

onready var _current_music = $March
var is_march_on = true


func _ready() -> void:
	Globals.connect("total_pigs_updated", self, "_update_music_layers")
	Globals.connect("combat_pigs_updated", self, "_handle_track_switch")


func _update_music_layers(total_pigs: int):
	if is_march_on:
		if total_pigs >= MINIMUM_PIGS_SECOND_LAYER:
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
		elif total_pigs >= MINIMUM_PIGS_THIRD_LAYER:
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
			for music_layer in _current_music.get_node("ThirdLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
		else:
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			for music_layer in _current_music.get_node("ThirdLayer").get_children():
				music_layer.set_volume_db(linear2db(0))


func _handle_track_switch():
	pass
