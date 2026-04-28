# autoloads/Boot.gd  ← add as a third autoload, ORDER: Boot last
extends Node

func _ready() -> void:
	SaveManager.load_data()
	if not PlayerData.is_first_launch:
		# Skip setup, go straight to menu
		call_deferred("_go_to_main_menu")

func _go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
	# If first launch, main_scene (CharacterSetup) loads naturally
