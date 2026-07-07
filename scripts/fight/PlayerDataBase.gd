class_name PlayerDataBase
extends Node

# --- First Launch ---


# --- Body ---
var gender: String = "male"        # "male" | "female"
var skin_id: String = "caucasian"  # matches SwatchData.swatch_id

# --- Equipment (stores resource paths for serialization) ---
var weapons_path: String = ""
var legs_path:     String = ""
var helmet_path:   String = ""
var back_path:     String = ""
var armour_path: String = ""
var top_path:    String = ""
var bottom_path: String = ""
var weapon_class: FFWeaponData.WeaponClass
var leg_class: FFLegData.LegClass
var back_class: FFBackData.BackClass
var speed: float = 0
var attack_map: Dictionary = {}
var special_map: Dictionary = {}
var combo_map: Dictionary = {}
var movement_map: Array[String] =  ['0000' ,'0001','0002', '0003', '0004', '0005', '0006', '0007' ]

func set_attack(input: int, attack_path: String) -> void:
	attack_map[input] = attack_path

func get_attack(input: int) -> String:
	return attack_map.get(input, "")

func remove_attack(input: int) -> void:
	attack_map.erase(input)

func set_combo(input: String, attack_path: String) -> void:
	combo_map[input] = attack_path

func get_combo(input: String) -> String:
	return combo_map.get(input, "")

func set_special_attack(input: int, preliminary: int, attack_path: String) -> void:
	if not special_map.has(preliminary):
		special_map[preliminary] = {}
	special_map[preliminary][input] = attack_path

func get_special_attack():
	return special_map

func remove_special_attack(input:int) -> void:
	special_map.erase(input)

func to_dict() -> Dictionary:
	return {
		"gender":       gender,
		"skin_id":      skin_id,
		"helmet_path":  helmet_path,
		"weapons_path": weapons_path,
		"legs_path":    legs_path,
		"back_path":    back_path,
		"armour_path": armour_path,
		"top_path":    top_path,
		"bottom_path": bottom_path,
		"leg_class": leg_class,
		"back_class": back_class,
		"weapon_class": weapon_class,
		"attack_map":   attack_map,
		"special_map": special_map,
		"combo_map": combo_map,
		"speed": speed,
	}

func from_dict(d: Dictionary) -> void:
	gender          = d.get("gender", "male")
	skin_id         = d.get("skin_id", "caucasianMale")
	helmet_path     = d.get("helmet_path", "")
	weapons_path    = d.get("weapons_path", "")
	legs_path       = d.get("legs_path",     "")
	back_path       = d.get("back_path",     "")
	armour_path     = d.get("armour_path",     "")
	top_path        = d.get("top_path",    "")
	bottom_path     = d.get("bottom_path", "")
	weapon_class    = d.get("weapon_class", FFWeaponData.WeaponClass.SLASHER) as FFWeaponData.WeaponClass
	leg_class       = d.get("leg_class", FFLegData.LegClass.WALKER)
	back_class      = d.get("back_class", FFBackData.BackClass.ARACHNID)
	attack_map      = _normalize_int_keys(d.get("attack_map", {}))
	special_map     = _normalize_nested_int_keys(d.get("special_map", {}))
	combo_map      = d.get("combo_map", {})
	speed           = d.get("speed", 10.0)

func _normalize_int_keys(raw: Dictionary) -> Dictionary:
	var fixed := {}
	for key in raw.keys():
		fixed[int(key)] = raw[key]
	return fixed

func _normalize_nested_int_keys(raw: Dictionary) -> Dictionary:
	var fixed := {}
	for outer_key in raw.keys():
		var inner_fixed := {}
		for inner_key in raw[outer_key].keys():
			inner_fixed[int(inner_key)] = raw[outer_key][inner_key]
		fixed[int(outer_key)] = inner_fixed
	return fixed
