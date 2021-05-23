extends Node

const TRANSITION_TO_WAR_TIMER = 1.0
const TRANSITION_TO_MARCH_TIMER = 4.0

const LAYER_UPDATE_TIMER = 1.0

const MARCH_MINIMUM_PIGS_SECOND_LAYER = 10
const MARCH_MINIMUM_PIGS_THIRD_LAYER = 15

const WAR_MINIMUM_PIGS_SECOND_LAYER = 6
const WAR_MINIMUM_PIGS_THIRD_LAYER = 9



onready var _march: Node = $March
onready var _war: Node = $War
onready var _timer: Timer = $Timer

var _is_march_on: bool = true

var last_pig_count: int = 0
var last_combat_pig_count: int = 0


func _ready() -> void:
	var _r = Globals.connect("total_pigs_updated", self, "_update_march_layers")
	var _r2d2 = Globals.connect("combat_pigs_updated", self, "_handle_track_switch")
	

func _update_march_layers(total_pigs: int) -> void:
	if _is_march_on:
		_update_music_layers(_march, total_pigs, last_pig_count, MARCH_MINIMUM_PIGS_SECOND_LAYER, MARCH_MINIMUM_PIGS_THIRD_LAYER)
		last_pig_count = total_pigs


func _update_music_layers(_music_node: Node, total_pigs: int, last_pig_count: int, first_threshold: int, second_threshold: int) -> void:
	if total_pigs == first_threshold or total_pigs == second_threshold:
		_timer.start(LAYER_UPDATE_TIMER)
		print("Second layer to be faded in")
	else:
		if last_pig_count >= first_threshold and total_pigs < first_threshold or last_pig_count >= second_threshold and total_pigs < second_threshold:
			_timer.start(LAYER_UPDATE_TIMER)
			print("Third layer to be faded in")


func _handle_track_switch(total_combat_pigs: int) -> void:
	if _is_march_on:
		if total_combat_pigs > 0:
				_timer.start(TRANSITION_TO_WAR_TIMER)
	else:
		if total_combat_pigs == 0:
				_timer.start(TRANSITION_TO_MARCH_TIMER)
		else:
			_update_music_layers(_war, total_combat_pigs, last_combat_pig_count, WAR_MINIMUM_PIGS_SECOND_LAYER, WAR_MINIMUM_PIGS_THIRD_LAYER)
	
	last_combat_pig_count = total_combat_pigs


func _fade_in_layer(music_node: Node, layer_name: String):
	music_node.get_node(layer_name).get_node("AnimationPlayer").play("fade_in")


func _fade_out_layer(music_node: Node, layer_name: String):
	music_node.get_node(layer_name).get_node("AnimationPlayer").play("fade_out")


func _fade_out_if_not_muted(music_node: Node, layer_name: String) -> void:
	if not _is_layer_muted(music_node, layer_name):
		_fade_out_layer(music_node, layer_name)


func _is_layer_muted(music_node: Node, layer_name: String) -> bool:
	return music_node.get_node(layer_name).get_node("Tracks").get_child(0).get_volume_db() <= -80


func _fade_in_layers_if_thresholds_reached(music_node: Node, current_value: int, first_threshold: int, second_threshold: int) -> void:
	_fade_in_layer(music_node, "MainLayer")
	if current_value >= first_threshold:
		_fade_in_layer(music_node, "SecondLayer")
	if current_value >= second_threshold:
		_fade_in_layer(music_node, "ThirdLayer")


func _fade_out_all_layers_if_playing(music_node: Node) -> void:
	_fade_out_layer(music_node, "MainLayer")
	_fade_out_if_not_muted(music_node, "SecondLayer")
	_fade_out_if_not_muted(music_node, "ThirdLayer")


func _on_Timer_timeout() -> void:
	if _is_march_on:
		if Globals.total_combat_pigs > 0:
			print("Switching to War")
			_fade_out_all_layers_if_playing(_march)
			_is_march_on = false
			
			_fade_in_layers_if_thresholds_reached(_war, Globals.total_combat_pigs, WAR_MINIMUM_PIGS_SECOND_LAYER, WAR_MINIMUM_PIGS_THIRD_LAYER)
		else:
			if Globals.total_pigs >= MARCH_MINIMUM_PIGS_SECOND_LAYER:
				if _is_layer_muted(_march, "SecondLayer"):
					_fade_in_layer(_march, "SecondLayer")
			else:
				_fade_out_if_not_muted(_march, "SecondLayer")
			if Globals.total_pigs >= MARCH_MINIMUM_PIGS_THIRD_LAYER:
				if _is_layer_muted(_march, "ThirdLayer"):
					_fade_in_layer(_march, "ThirdLayer")
			else:
				_fade_out_if_not_muted(_march, "ThirdLayer")
	else:
		if Globals.total_combat_pigs == 0:
			print("Switching to March")
			_fade_out_all_layers_if_playing(_war)
			_is_march_on = true
			
			_fade_in_layers_if_thresholds_reached(_march, Globals.total_pigs, MARCH_MINIMUM_PIGS_SECOND_LAYER, MARCH_MINIMUM_PIGS_THIRD_LAYER)
		else:
			if Globals.total_combat_pigs >= WAR_MINIMUM_PIGS_SECOND_LAYER:
				if _is_layer_muted(_war, "SecondLayer"):
					_fade_in_layer(_war, "SecondLayer")
			else:
				_fade_out_if_not_muted(_war, "SecondLayer")
			if Globals.total_combat_pigs >= WAR_MINIMUM_PIGS_THIRD_LAYER:
				if _is_layer_muted(_war, "ThirdLayer"):
					_fade_in_layer(_war, "ThirdLayer")
			else:
				_fade_out_if_not_muted(_war, "ThirdLayer")
				
