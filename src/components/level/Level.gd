extends Spatial

var pig_scene = preload("res://scenes/components/Minion.tscn")
var shop: bool = false

export (bool) var spawn_pigs = true
export (bool) var save_starting = true

onready var death_screen = $DeathScreen

# Data stored when starting
var starting_data: StartingData



func _ready():
	if name == "Shop":
		shop = true
	elif name == "Test_Level1":
		Globals.hp = Globals.MAXHP
		Globals.total_pigs = 10
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
	player.connect("died", self, "show_death_screen")
	death_screen.visible = false

	
func save_starting_data():
	var data = StartingData.new(Globals.total_pigs, Globals.hp, Globals.total_currency)
	starting_data = data
	

func show_death_screen():
	# Store values
	death_screen.visible = true
	death_screen.player_dead = true
	if starting_data != null:
		Globals.total_pigs = starting_data.pigs_starting
		Globals.hp = starting_data.health_starting
		Globals.total_currency = starting_data.currency_starting
	remove_player()
	get_tree().paused = true

func reset_level():
	var _r = get_tree().reload_current_scene()
	
func remove_player():
	var player = $Player
	player.visible = false


