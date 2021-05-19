extends Node

var _playing = false

func _ready():
	for child in get_children():
		child.connect( "finished", self, "_set_playing_false")


func play_random_sound():
	if _playing:
		return
	
	var audio_stream: AudioStreamPlayer3D = get_child(Random.get_random_int(0, get_child_count()-1))
	audio_stream.play()
	_playing = true


func _set_playing_false():
	_playing = false
