extends Spatial

onready var banner = $rig/Skeleton/BoneAttachment3/Flag_Staff
onready var sword = $rig/Skeleton/BoneAttachment4/Sword
onready var shield = $rig/Skeleton/BoneAttachment2/shield
onready var anim = $AnimationPlayer
onready var label = $rig/Skeleton/BoneAttachment3/Flag_Staff/Money_Label/Viewport/Label
onready var sword_area = $rig/Skeleton/BoneAttachment4/Sword/Sword_Area


func _ready():
	set_idle()

func _process(_delta) -> void:
	label.text = str(Globals.total_currency)


func set_idle() -> void:
	label.visible = false
	banner.visible = false
	sword.visible = true
	shield.visible = true
	anim.play("Idle")
	
func set_banner() -> void:
	label.visible = true
	banner.visible = true
	sword.visible = false
	shield.visible = false
	anim.play("Hold_Banner")
