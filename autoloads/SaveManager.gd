# Autoload: SaveManager
# Reads and writes player_data.json. Call load_data() on boot.
extends Node

const SAVE_PATH := "user://player_data.json"

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		PlayerData.is_first_launch = true
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Could not open save file.")
		return

	var json  := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK:
		push_error("SaveManager: JSON parse error.")
		return

	PlayerData.from_dict(json.get_data())

func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Could not write save file.")
		return

	file.store_string(JSON.stringify(PlayerData.to_dict(), "\t"))
	file.close()
