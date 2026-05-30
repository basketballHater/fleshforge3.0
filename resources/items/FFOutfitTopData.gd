# FFOutfitTopData.gd
class_name FFOutfitTopData
extends FFItemData

@export var gender:   String = ""

func get_glb_path() -> String:
	return "res://assets/clothes/%s/tops/%s.glb" % [gender, item_id]
