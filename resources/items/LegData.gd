# Extends ItemData with weapon-specific fields.
class_name LegData
extends ItemData

enum LegClass { JUMPER, RUNNER, THUMPER}


@export var leg_class: LegClass = 0
@export var element: ElementClass = 0
@export var animation_set: String = "Unknown"

func get_class_label() -> String:
	return LegClass.keys()[leg_class].capitalize()
