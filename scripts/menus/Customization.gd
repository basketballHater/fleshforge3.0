# Customization screen.
# Loads all FFItemData resources from subfolders, populates tab lists,
# shows item info, applies changes to live preview, saves on confirm.
extends "res://scripts/menus/BaseCustomization.gd"
 

# Tracks the currently selected item per slot


func _ready() -> void:
	character = $Viewport/Character
	character.apply_from_player_data()
	
	super._ready()

	_selected["helmet"]  = _load_item(characterData.helmet_path)
	_selected["weapons"] = _load_item(characterData.weapons_path)
	_selected["legs"]    = _load_item(characterData.legs_path)
	_selected["back"]    = _load_item(characterData.back_path)
	_selected["armour"]    = _load_item(characterData.back_path)
	_selected["top"] = _load_item(characterData.top_path)
	_selected["bottom"] = _load_item(characterData.bottom_path)
	
	if GameState.customization_mode == "single":
		playerLabel.visible = false
		genderBox.visible = false
		next.visible = false
	
	elif GameState.customization_mode == "versus":	
		playerLabel.text = "Player "+str(GameState.active_player)+" "+GameState.customization_mode

		next.pressed.connect(nextCharacter)
		maleButton.pressed.connect(character._on_gender_selected.bind("male"))
		femaleButton.pressed.connect(character._on_gender_selected.bind("female"))
		if GameState.active_player == 2:
			next.text = "Start Fight"
