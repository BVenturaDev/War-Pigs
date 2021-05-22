extends Spatial

onready var sword = $rig/Skeleton/BoneAttachment7/Sword
onready var shield = $rig/Skeleton/BoneAttachment6/Shield
onready var anim = $AnimationTree
onready var state_machine = anim["parameters/playback"]

func _ready():
	set_idle()

func set_attack():
	if not state_machine.get_current_node() == "Attack":
		sword.visible = true
		shield.visible = true
		state_machine.travel("Attack")

func set_idle() -> void:
	if not state_machine.get_current_node() == "Idle":
		sword.visible = true
		shield.visible = true
		state_machine.travel("Idle")
	
func set_run() -> void:
	if not state_machine.get_current_node() == "Run":
		sword.visible = true
		shield.visible = true
		state_machine.travel("Run")
		
func set_crawl() -> void:
	if not state_machine.get_current_node() == "Crawl":
		sword.visible = false
		shield.visible = false
		state_machine.travel("Crawl")
	
func set_crawl_idle() -> void:
	if not state_machine.get_current_node() == "Crawl_Idle":
		sword.visible = false
		shield.visible = false
		state_machine.travel("Crawl_Idle")
