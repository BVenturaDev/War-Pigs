extends Spatial

var currency

func give_currency(c):
	currency = c
	self.add_child(currency)
	
func remove_currency() -> CurrencyData:
	self.remove_child(currency)
	var currency_data = currency.retrieve_currency()
	currency.queue_free()
	currency = null
	
	return currency_data

func has_currency():
	if currency != null:
		return true
	else:
		return false
