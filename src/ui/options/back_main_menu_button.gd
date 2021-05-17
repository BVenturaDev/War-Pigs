extends Button

var _main_menu = load("res://scenes/ui/main_menu.tscn")


func _on_Back_pressed() -> void:
	get_tree().get_root().add_child(_main_menu.instance())
	get_parent().queue_free()
