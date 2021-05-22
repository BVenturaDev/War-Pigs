extends Spatial

export (bool) var DEBUG = false

var pig_scene = preload("res://scenes/components/Minion.tscn")
var shop: bool = false

export (bool) var spawn_pigs = true
export (bool) var save_starting = true

# Data stored when starting
var starting_data: StartingData

func _ready():
	if name == "Shop":
		shop = true
	elif name == "Test_Level1":
		Globals.hp = Globals.MAXHP
	add_to_group("Levels")
	
	if spawn_pigs:
		for x in Globals.total_pigs:
			var pig = pig_scene.instance()
				
			var nav = $Navigation
			
			nav.add_child(pig)
			pig.global_transform = $Player.global_transform
			pig.join_formation()
	
	if save_starting:
		save_starting_data()
		
	# Connect to player
	var player = get_node("Player")
	player.connect("died", self, "reset_level")
	
func save_starting_data():
	var data = StartingData.new(Globals.total_pigs, Globals.hp, Globals.total_currency)
	starting_data = data

func reset_level():
	if starting_data != null:
		Globals.total_pigs = starting_data.pigs_starting
		Globals.hp = starting_data.health_starting
		Globals.total_currency = starting_data.currency_starting
		
	get_tree().reload_current_scene()
