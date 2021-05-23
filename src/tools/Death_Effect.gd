extends Spatial

onready var particles1 = $Particles
onready var particles2 = $Particles2

var is_pig: bool = true

func _ready() -> void:
	#print("GAS")
	particles1.emitting = true
	particles2.emitting = true
	if is_pig:
		$DeathPig.play()
		pass
	else:
		$DeathBoar.play()
		pass

func _on_Clean_Up_timeout():
	queue_free()
