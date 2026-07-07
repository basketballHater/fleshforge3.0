# autoloads/Boot.gd  ← add as a third autoload, ORDER: Boot last
extends Node

@onready var characterData = GameState.singleplayer_data

func _ready() -> void:
	SaveManager.load_all()
	if not characterData.is_first_launch:
		# Skip setup, go straight to menu
		call_deferred("_go_to_main_menu")

func _go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
	# If first launch, main_scene (CharacterSetup) loads naturally
