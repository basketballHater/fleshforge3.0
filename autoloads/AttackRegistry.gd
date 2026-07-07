# Autoload: AttackRegistry
extends Node

const UNLOCK_SAVE_PATH := "user://unlocked_attacks.json"

var _attacks: Dictionary = {}          # attack_id -> AttackData
var _unlocked_ids: Array[String] = []

func _ready() -> void:
	_load_all_attacks()
	_load_unlocks()

# -------------------------------------------------------
# Loading attack resources
# -------------------------------------------------------

func _load_all_attacks() -> void:
	var dir := DirAccess.open("res://resources/attacks/data/")
	if dir == null:
		push_error("AttackRegistry: could not open res://resources/attacks/data/")
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres") or file.ends_with(".res"):
			var attack: AttackData = load("res://resources/attacks/data/" + file)
			if attack and attack.attack_id != "":
				_attacks[attack.attack_id] = attack
		file = dir.get_next()
	dir.list_dir_end()

# -------------------------------------------------------
# Querying
# -------------------------------------------------------

func get_attack(id: String) -> AttackData:
	return _attacks.get(id, null)

func get_all_attacks() -> Array:
	return _attacks.values()

func get_unlocked_attacks() -> Array:
	return _attacks.values().filter(func(a): return a.is_unlocked)

# -------------------------------------------------------
# Unlocking
# -------------------------------------------------------

func unlock_attack(id: String) -> void:
	if id in _unlocked_ids:
		return
	if not _attacks.has(id):
		push_error("AttackRegistry: unknown attack id '%s'" % id)
		return
	_unlocked_ids.append(id)
	_attacks[id].is_unlocked = true
	_save_unlocks()

func is_unlocked(id: String) -> bool:
	return id in _unlocked_ids

# -------------------------------------------------------
# Persistence
# -------------------------------------------------------

func _save_unlocks() -> void:
	var file := FileAccess.open(UNLOCK_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("AttackRegistry: could not write " + UNLOCK_SAVE_PATH)
		return
	file.store_string(JSON.stringify(_unlocked_ids, "\t"))
	file.close()

func _load_unlocks() -> void:
	if not FileAccess.file_exists(UNLOCK_SAVE_PATH):
		return   # no unlocks yet, fresh game
	var file := FileAccess.open(UNLOCK_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("AttackRegistry: could not read " + UNLOCK_SAVE_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Array:
		push_error("AttackRegistry: unlocked_attacks.json is corrupted")
		return
	_unlocked_ids = Array(parsed)
	# Sync is_unlocked flag on the loaded resources
	for id in _unlocked_ids:
		if _attacks.has(id):
			_attacks[id].is_unlocked = true
