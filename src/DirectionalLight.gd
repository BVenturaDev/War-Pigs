extends DirectionalLight

func _process(delta):
	self.shadow_enabled = Globals.shadows
