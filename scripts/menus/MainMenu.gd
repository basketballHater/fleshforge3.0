extends Node

@onready var btn_play:      Button = $UI/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BtnPlay
@onready var btn_versus:      Button = $UI/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer5/Versus
@onready var btn_customize: Button = $UI/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/BtnCustomize
@onready var btn_quit:      Button = $UI/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/BtnQuit

func _ready() -> void:
	btn_play.pressed.connect(_on_play)
	btn_customize.pressed.connect(_on_customize)
	btn_versus.pressed.connect(_on_versus)
	btn_quit.pressed.connect(_on_quit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/fight/FightScene.tscn")

func _on_customizSSSSe() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Customization.tscn")
	
func _on_versus() -> void:
	GameState.active_player = 1
	GameState.customization_mode = "versus"
	get_tree().change_scene_to_file("res://scenes/menus/Customization.tscn")

func _on_customize():
	GameState.customization_mode = "single"
	get_tree().change_scene_to_file("res://scenes/menus/Customization.tscn")

func _on_quit() -> void:
	get_tree().quit()
