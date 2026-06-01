# Autoload: PlayerData
# Holds all runtime player state. Populated by SaveManager on boot.
extends Node

# --- First Launch ---
var is_first_launch: bool = true

# --- Body ---
var gender: String = "male"        # "male" | "female"
var skin_id: String = "caucasian"  # matches SwatchData.swatch_id

# --- Equipment (stores resource paths for serialization) ---
var weapons_path: String = ""   # right hand
var legs_path:     String = ""
var helmet_path:   String = ""
var back_path:     String = ""
var armour_path: String = ""
var top_path:    String = ""
var bottom_path: String = ""

func to_dict() -> Dictionary:
	return {
		"is_first_launch": false,
		"gender":       gender,
		"skin_id":      skin_id,
		"helmet_path":  helmet_path,
		"weapons_path": weapons_path,
		"legs_path":    legs_path,
		"back_path":    back_path,
		"armour_path": armour_path,
		"top_path":    top_path,
		"bottom_path": bottom_path,
	}

func from_dict(d: Dictionary) -> void:
	is_first_launch = d.get("is_first_launch", true)
	gender          = d.get("gender",        "male")
	skin_id         = d.get("skin_id",       "caucasianMale")
	helmet_path     = d.get("helmet_path",   "")
	weapons_path   = d.get("weapons_path", "")
	legs_path       = d.get("legs_path",     "")
	back_path       = d.get("back_path",     "")
	armour_path       = d.get("armour_path",     "")
	top_path    = d.get("top_path",    "")
	bottom_path = d.get("bottom_path", "")
