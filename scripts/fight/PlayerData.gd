# Holds all runtime player state. Populated by SaveManager on boot.
class_name PlayerData
extends PlayerDataBase

var is_first_launch: bool = true

func from_dict(d: Dictionary) -> void:
	super.from_dict(d)
	is_first_launch = d.get("is_first_launch", true)

func to_dict() -> Dictionary:
	var data  = super.to_dict()
	data["is_first_launch"] = false
	return data
	
