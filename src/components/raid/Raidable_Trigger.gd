extends StaticBody

"""
Script that is to be attached to the body of the raidable object.
Meant to communicate with the Raidable script
"""

var raidable: Raidable

func _ready():
	add_to_group("raidable")
	
func get_raidable():
	return raidable
	
func set_raidable(r: Raidable):
	raidable = r
