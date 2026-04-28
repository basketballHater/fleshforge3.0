extends Node

@onready var btn_play:      Button = $UI/BtnPlay
@onready var btn_customize: Button = $UI/BtnCustomize
@onready var btn_quit:      Button = $UI/BtnQuit

func _ready() -> void:
	btn_play.pressed.connect(_on_play)
	btn_customize.pressed.connect(_on_customize)
	btn_quit.pressed.connect(_on_quit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/fight/FightScene.tscn")

func _on_customize() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Customization.tscn")

func _on_quit() -> void:
	get_tree().quit()
