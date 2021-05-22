extends Spatial

var is_pig: bool = true

func _ready() -> void:
	if is_pig:
		# Sound 1
		pass
	else:
		# Sound 2
		pass

func _on_Clean_Up_timeout():
	queue_free()
