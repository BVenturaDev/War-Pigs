extends Button

export(PackedScene) var scene: PackedScene

func _on_Button_pressed() -> void:
	get_tree().get_root().add_child(scene.instance())
	get_parent().get_parent().queue_free()
