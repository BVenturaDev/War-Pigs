extends Node

const MARCH_MINIMUM_PIGS_SECOND_LAYER = 5
const MARCH_MINIMUM_PIGS_THIRD_LAYER = 10

const WAR_MINIMUM_PIGS_SECOND_LAYER = 3
const WAR_MINIMUM_PIGS_THIRD_LAYER = 6

onready var _march: Node = $March
onready var _war: Node = $War
var _is_march_on = true

var _switch_track = false

var last_pig_count = 0
var last_combat_pig_count = 0


func _ready() -> void:
	Globals.connect("total_pigs_updated", self, "_update_march_layers")
	Globals.connect("combat_pigs_updated", self, "_handle_track_switch")
	

func _fade_in_layer(music_node: Node, layer_name: String):
	music_node.get_node(layer_name).get_node("AnimationPlayer").play("fade_in")


func _fade_out_layer(music_node: Node, layer_name: String):
	music_node.get_node(layer_name).get_node("AnimationPlayer").play("fade_out")


func _update_march_layers(total_pigs: int) -> void:
	if _is_march_on:
		_update_music_layers(_march, total_pigs, last_pig_count, MARCH_MINIMUM_PIGS_SECOND_LAYER, MARCH_MINIMUM_PIGS_THIRD_LAYER)
		last_pig_count = total_pigs


func _update_music_layers(music_node: Node, total_pigs: int, last_pig_count: int, first_threshold: int, second_threshold: int) -> void:
	if total_pigs == first_threshold:
		_fade_in_layer(music_node, "SecondLayer")
	elif total_pigs == second_threshold:
		_fade_in_layer(music_node, "ThirdLayer")
	else:
		if last_pig_count >= second_threshold and total_pigs < second_threshold:
			_fade_out_layer(music_node, "ThirdLayer")
		if last_pig_count >= first_threshold and total_pigs < first_threshold:
			_fade_out_layer(music_node, "SecondLayer")


func _handle_track_switch(total_combat_pigs: int) -> void:
	if _switch_track == false:
		if _is_march_on:
			if total_combat_pigs > 0:
				_switch_track = true
				$Timer.start()
		else:
			if total_combat_pigs == 0:
				_switch_track = true
				$Timer.start()
			_update_music_layers(_war, total_combat_pigs, last_combat_pig_count, WAR_MINIMUM_PIGS_SECOND_LAYER, WAR_MINIMUM_PIGS_THIRD_LAYER)
			
	
	last_combat_pig_count = total_combat_pigs


func _on_Timer_timeout() -> void:
	if _is_march_on:
		if Globals.total_combat_pigs > 0:
			_fade_out_layer(_march, "MainLayer")
			if Globals.total_pigs >= MARCH_MINIMUM_PIGS_SECOND_LAYER:
				_fade_out_layer(_march, "SecondLayer")
			if Globals.total_pigs >= MARCH_MINIMUM_PIGS_THIRD_LAYER:
				_fade_out_layer(_march, "ThirdLayer")
			_is_march_on = false
			_fade_in_layer(_war, "MainLayer")
	else:
		if Globals.total_combat_pigs == 0:
			_fade_out_layer(_war, "MainLayer")
			_is_march_on = true
			_fade_in_layer(_march, "MainLayer")
	_switch_track = false
