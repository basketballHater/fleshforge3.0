# Extends ItemData with weapon-specific fields.
class_name FFArmourData
extends FFItemData


#@export var element_resistance: ElementClass = 0
@export var meshes: Array[Mesh] = [null]
@export var absorption: int = 0
@export var animation_set: String = "Unknown"
