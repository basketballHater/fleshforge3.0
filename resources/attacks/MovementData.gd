# res://resources/attacks/AttackData.gd
class_name MovementData
extends FFItemData

class HitboxSnapshot:
	var headCol_transform: Transform3D
	var torsoCol_transform: Transform3D
	var abdomenCol_transform: Transform3D
	var upperArm_L_Col_transform: Transform3D
	var upperArm_R_Col_transform: Transform3D
	var lowerArm_L_Col_transform: Transform3D
	var lowerArm_R_Col_transform: Transform3D
	var upperLeg_L_Col_transform: Transform3D
	var upperLeg_R_Col_transform: Transform3D
	var lowerLeg_L_Col_transform: Transform3D
	var lowerLeg_R_Col_transform: Transform3D
	var hitbox: Transform3D
	var hitbox_radius: float
	var hitbox_height: float



@export var animation_name: String = ""
@export var impactFrames: Array[int]

@export var totalFrames: int = 25
var hitbox_snapshots: Array = []


func get_res_path() -> String:
	return "res://resources/attacks/attackData/%s.tres" % [ item_id]
	
