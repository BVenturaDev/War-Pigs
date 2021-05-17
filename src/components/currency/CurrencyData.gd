extends Resource
class_name CurrencyData

var amount: int

func _init(amnt: int):
	amount = amnt

func get_amount() -> int:
	return amount
