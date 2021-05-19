extends Node

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()


func get_random_int(minimum: int, maximum: int) -> int:
	return _rng.randi_range(minimum, maximum)
