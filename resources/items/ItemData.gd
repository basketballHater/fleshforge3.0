# Base resource for ALL equippable items.
# Extend this for slot-specific data (WeaponData, etc.)
class_name ItemData
extends Resource

enum ElementClass { NONE, SHOCK, BURN, TEAR, ACID}
@export var id:   String = "Unknown"          # unique key e.g. "helmet_iron"
@export var name: String = "Unknown"
@export var slot:      String = "helmet"
@export var mesh:      Mesh   = null         # assign placeholder/real mesh here
@export var thumbnail: Texture2D = null      # UI icon (optional for now)
