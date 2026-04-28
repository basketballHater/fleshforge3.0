# Autoload: PlayerData
# Holds all runtime player state. Populated by SaveManager on boot.
extends Node

# --- First Launch ---
var is_first_launch: bool = true

# --- Body ---
var gender: String = "male"        # "male" | "female"
var skin_id: String = "caucasian"  # matches SwatchData.swatch_id

# --- Equipment (stores resource paths for serialization) ---
var weapon_path: String = ""   # right hand
var legs_path:     String = ""
var helmet_path:   String = ""
var back_path:     String = ""

func to_dict() -> Dictionary:
	return {
		"is_first_launch": false,
		"gender":       gender,
		"skin_id":      skin_id,
		"helmet_path":  helmet_path,
		"weapons_path": weapon_path,
		"legs_path":    legs_path,
		"back_path":    back_path,
	}

func from_dict(d: Dictionary) -> void:
	is_first_launch = d.get("is_first_launch", true)
	gender          = d.get("gender",        "male")
	skin_id         = d.get("skin_id",       "caucasianMale")
	helmet_path     = d.get("helmet_path",   "")
	weapon_path   = d.get("weapon_path", "")
	legs_path       = d.get("legs_path",     "")
	back_path       = d.get("back_path",     "")
