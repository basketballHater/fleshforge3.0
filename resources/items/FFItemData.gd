class_name FFItemData
extends Resource

@export var item_id:   String = ""
@export var item_name: String = "Unknown"
@export var slot:      String = ""  # "helmet"|"weapon_l"|"weapon_r"|"legs"|"back"
@export var thumbnail: Texture2D = null

func get_glb_path() -> String:
	return "res://assets/%s/%s.glb" % [slot, item_id]
