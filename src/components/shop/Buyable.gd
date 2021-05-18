tool
extends StaticBody

"""
Contain the item that is to be bought.
"""
# Be able to change collision shape in editor
export (Vector3) var collision_scale = Vector3(1,1,1)
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
	$CollisionShape.scale = collision_scale
	add_to_group("buyable")
	
func _process(delta):
	if Engine.editor_hint:
		$CollisionShape.scale = collision_scale

func buy_item(amount: int):
	if amount >= cost:
		if buyable_item != null:
			var item = buyable_item
			remove_child(buyable_item)
			buyable_item = null
			return item
	return null

# Called after buying an item. NOT before
func change(amount: int) -> int:
	return amount - cost
	
func get_type() -> String:
	return item_type
