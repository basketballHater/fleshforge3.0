class_name FFWeaponData
extends FFItemData

enum WeaponClass { SLASHER, HAMMER, REAPER, BOXER, SHOOTER, RAPID }

# 3 mesh pieces in order: [weapon1, weapon2, weapon3]
# Each corresponds to one bone on the hand
# Leave an index null if that bone has no mesh for this weapon
@export var meshes: Array[Mesh] = [null, null, null]

@export var weapon_class:  WeaponClass = WeaponClass.SLASHER
@export var animation_set: String      = "slasher_default"
@export var cosmetic_variant_of: String = ""

func get_class_label() -> String:
	return WeaponClass.keys()[weapon_class].capitalize()

func get_glb_path() -> String:
	var wClass = WeaponClass.keys()[weapon_class]
	return "res://assets/%s/%s/%s.glb" % [slot, wClass, item_id]
