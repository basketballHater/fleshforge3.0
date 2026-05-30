# FFOutfitBottomData.gd
class_name FFOutfitBottomData
extends FFItemData

@export var gender:   String = ""

func get_glb_path() -> String:
	return "res://assets/clothes/%s/bottoms/%s.glb" % [gender, item_id]
