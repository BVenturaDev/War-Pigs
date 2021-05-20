extends StaticBody

class_name Sellable


export (String) var item_type
# Amount of money returned
export (int) var profit_on_selling

func _ready():
	add_to_group("sellable")

func get_type() -> String:
	return item_type

func get_profit() -> int:
	return profit_on_selling
