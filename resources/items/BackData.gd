# Extends ItemData with weapon-specific fields.
class_name BackData
extends ItemData

enum BackClass { ARACHNID, BRAWLER, TENTACLE, SHOOTER, WINGS }


@export var back_class: BackClass = 0
@export var element: ElementClass = 0
@export var animation_set: String = "Unknown"

func get_class_label() -> String:
	return BackClass.keys()[back_class].capitalize()
