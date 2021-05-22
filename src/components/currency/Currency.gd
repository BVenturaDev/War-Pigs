extends Spatial

var currency
export (int) var value = 2

func _ready():
	currency = CurrencyData.new(value)

func retrieve_currency():
	return currency
	
func set_currency(c):
	currency = c
	
