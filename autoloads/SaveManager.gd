# Autoload: SaveManager
# Reads and writes player_data.json. Call load_data() on boot.
extends Node

var SAVE_PATH :String
@onready var characterData = GameState.get_active_data()

func _ready() -> void:
	set_path()


func set_path()-> void:
	if GameState.customization_mode =="versus":
		SAVE_PATH = "user://player_data_" + str(GameState.active_player) + ".json"
	else:
		SAVE_PATH = "user://player_data.json"
		

func load_all() -> void:
	_load_for(GameState.singleplayer_data, "user://player_data.json")
	_load_for(GameState.player1_data, "user://player_data_1.json")
	_load_for(GameState.player2_data, "user://player_data_2.json")

func _load_for(data: PlayerDataBase, path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Could not open " + path)
		return
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("SaveManager: JSON parse error for " + path)
		return
	data.from_dict(json.get_data())

func save_data() -> void:
	set_path()
	var data := GameState.get_active_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Could not write save file.")
		return
	file.store_string(JSON.stringify(data.to_dict(), "\t"))
	file.close()
