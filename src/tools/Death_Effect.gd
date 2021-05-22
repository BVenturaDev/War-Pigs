extends Spatial

var is_pig: bool = true

func _ready() -> void:
	if is_pig:
		$DeathPig.play()
		pass
	else:
		$DeathBoar.play()
		pass

func _on_Clean_Up_timeout():
	queue_free()
