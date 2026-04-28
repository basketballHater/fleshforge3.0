# Extends ItemData with weapon-specific fields.
class_name WeaponData
extends ItemData

enum WeaponClass { SLASHER, HAMMER, REAPER, SHOOTER, RAPID }


@export var weapon_class: WeaponClass = 0
@export var element: ElementClass = 0
@export var animation_set: String = "Unknown"

func get_class_label() -> String:
	return WeaponClass.keys()[weapon_class].capitalize()
