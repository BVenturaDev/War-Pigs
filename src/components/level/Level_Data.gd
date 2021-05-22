extends Resource
class_name StartingData


# Data to store when starting level
var pigs_starting: int
var health_starting: int
var currency_starting: int

func _init(ps, hs, cs):
	pigs_starting = ps
	health_starting = hs
	currency_starting = cs
