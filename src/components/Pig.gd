extends Spatial

onready var banner = $rig/Skeleton/BoneAttachment3/Flag_Staff
onready var sword = $rig/Skeleton/BoneAttachment4/Sword
onready var shield = $rig/Skeleton/BoneAttachment2/shield
onready var anim = $AnimationTree
onready var state_machine = anim["parameters/playback"]
onready var label = $rig/Skeleton/BoneAttachment3/Flag_Staff/Money_Label/Viewport/Label
onready var sword_area = $rig/Skeleton/BoneAttachment4/Sword/Sword_Area
onready var helmet = $rig/Skeleton/BoneAttachment/Helmet
onready var shoulder_pads = $rig/Skeleton/Shoulderpads
onready var breastplate = $rig/Skeleton/Breastplate
onready var tunic = $rig/Skeleton/Tunic

func _ready():
	set_idle()

func _process(_delta) -> void:
	if label.visible:
		label.text = str(Globals.total_currency)

func set_attack():
	if not state_machine.get_current_node() == "Attack":
		state_machine.travel("Attack")

func set_idle() -> void:
	if not state_machine.get_current_node() == "Idle":
		label.visible = false
		banner.visible = false
		sword.visible = true
		shield.visible = true
		state_machine.travel("Idle")
	
func set_run() -> void:
	if not state_machine.get_current_node() == "Run":
		state_machine.travel("Run")

func set_banner() -> void:
	if not state_machine.get_current_node() == "Hold_Banner":
		label.visible = true
		banner.visible = true
		sword.visible = false
		shield.visible = false
		state_machine.travel("Hold_Banner")
	
func set_banner_run() -> void:
	if not state_machine.get_current_node() == "Run_Banner":
		state_machine.travel("Run_Banner")
	
