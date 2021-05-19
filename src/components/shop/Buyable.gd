tool
extends StaticBody

class_name Buyable

"""
Contain the item that is to be bought.
"""
# Allow to edit the label view in inspector
export (NodePath) var buyable_item_path

# Any item to buy (data)
# Child
var buyable_item
# Cost to buy item
export (int) var cost = 0
# type of item
export (String) var item_type

func _ready():
	if buyable_item_path != "":
		buyable_item = get_node(buyable_item_path)
	add_to_group("buyable")

#########
## Buyable Interface
#########

"""
func get_item():
	var item = buyable_item
	remove_child(buyable_item)
	return buyable_item
"""

# Called after buying an item. NOT before
func spent(_amount: int) -> int:
	return cost
	
func get_type() -> String:
	return item_type

func destroy_item():
	call_deferred("queue_free")

# Called from buyer
func can_buy(amount: int) -> bool:
	return amount >= cost
