class_name FFItemData
extends Resource

enum itemClass { WEAPON, HELMET, ARMOUR, BACK, LEGS, TOP, BOTTOM, COMMON, COMBO, SPECIAL }

@export var item_id:   String = ""
@export var item_name: String = "Unknown"
@export var slot: itemClass
@export var thumbnail: Texture2D = null

func get_glb_path() -> String:
	return "res://assets/%s/%s.glb" % [FFItemData.itemClass.keys()[slot], item_id]
