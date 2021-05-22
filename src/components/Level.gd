extends Spatial

export (bool) var DEBUG = false

var pig_scene = preload("res://scenes/components/Minion.tscn")
var shop: bool = false

func _ready():
	if name == "Shop":
		shop = true
	elif name == "Test_Level1":
		Globals.hp = Globals.MAXHP
	add_to_group("Levels")
	for x in Globals.total_pigs:
		var pig = pig_scene.instance()
			
		var nav = $Navigation
		
		nav.add_child(pig)
		pig.global_transform = $Player.global_transform
		pig.join_formation()
			
