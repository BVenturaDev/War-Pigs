extends Sprite3D

export (String) var text

func _ready():
	$Viewport/VBoxContainer/Label.text = text
	texture = $Viewport.get_texture()
