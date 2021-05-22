extends Node

const MARCH_MINIMUM_PIGS_SECOND_LAYER = 5
const MARCH_MINIMUM_PIGS_THIRD_LAYER = 10

const WAR_MINIMUM_PIGS_SECOND_LAYER = 5
const WAR_MINIMUM_PIGS_THIRD_LAYER = 10

onready var _current_music = $March
var _is_march_on = true


func _ready() -> void:
	Globals.connect("total_pigs_updated", self, "_update_music_layers")
	Globals.connect("combat_pigs_updated", self, "_handle_track_switch")


func _update_music_layers(total_pigs: int):
	if _is_march_on:
		if total_pigs >= MARCH_MINIMUM_PIGS_SECOND_LAYER:
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
		elif total_pigs >= MARCH_MINIMUM_PIGS_THIRD_LAYER:
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
			for music_layer in _current_music.get_node("ThirdLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
		else:
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			for music_layer in _current_music.get_node("ThirdLayer").get_children():
				music_layer.set_volume_db(linear2db(0))

func _handle_track_switch(total_combat_pigs: int):
	if _is_march_on:
		if total_combat_pigs > 0:
			for music_layer in _current_music.get_node("MainLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			for music_layer in _current_music.get_node("ThirdLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			_current_music = $War
			_is_march_on = false
			for music_layer in _current_music.get_node("MainLayer").get_children():
				music_layer.set_volume_db(linear2db(1))
			
	else:
		if total_combat_pigs == 0:
			for music_layer in _current_music.get_node("MainLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			for music_layer in _current_music.get_node("SecondLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			for music_layer in _current_music.get_node("ThirdLayer").get_children():
				music_layer.set_volume_db(linear2db(0))
			_current_music = $March
			_is_march_on = true
			for music_layer in _current_music.get_node("MainLayer").get_children():
				music_layer.set_volume_db(linear2db(1))

	if total_combat_pigs >= WAR_MINIMUM_PIGS_SECOND_LAYER:
		for music_layer in _current_music.get_node("SecondLayer").get_children():
			music_layer.set_volume_db(linear2db(1))
	elif total_combat_pigs >= WAR_MINIMUM_PIGS_THIRD_LAYER:
		for music_layer in _current_music.get_node("SecondLayer").get_children():
			music_layer.set_volume_db(linear2db(0))
		for music_layer in _current_music.get_node("ThirdLayer").get_children():
			music_layer.set_volume_db(linear2db(0))
	else:
		for music_layer in _current_music.get_node("SecondLayer").get_children():
			music_layer.set_volume_db(linear2db(0))
		for music_layer in _current_music.get_node("ThirdLayer").get_children():
			music_layer.set_volume_db(linear2db(0))
