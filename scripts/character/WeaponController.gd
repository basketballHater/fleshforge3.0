# Attached to Character or a child node.
# Manages the active weapon's class and animation set.
# Expand this when combat is implemented.
class_name WeaponController
extends Node

var active_weapon: WeaponData = null

func equip_weapon(weapon: WeaponData) -> void:
	active_weapon = weapon
	if weapon == null:
		_set_animation_set("unarmed")
		return
	_set_animation_set(weapon.animation_set)
	print("WeaponController: equipped '%s' [%s]" % [weapon.item_name, weapon.get_class_label()])

func _set_animation_set(set_name: String) -> void:
	# Placeholder: hook into AnimationTree here when combat is ready.
	print("WeaponController: animation set → '%s'" % set_name)
