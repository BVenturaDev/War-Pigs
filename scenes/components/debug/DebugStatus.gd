extends Node


onready var indicator = $Indicator

func _ready():
	var unique_mat = indicator.get_surface_material(0).duplicate()
	indicator.set_surface_material(0, unique_mat)

func change_color(c):
	if indicator.get_surface_material(0).albedo_color != c:
		indicator.get_surface_material(0).albedo_color = c
