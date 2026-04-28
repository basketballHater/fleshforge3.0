extends Node3D

const CHARACTER_SCENE := preload("res://scenes/character/Character.tscn")

@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var enemy_spawn:  Marker3D = $EnemySpawn
@onready var btn_back:     Button   = $UI/BtnBack

func _ready() -> void:
	_spawn_player()
	_spawn_dummy_enemy()
	btn_back.pressed.connect(_on_back)

func _spawn_player() -> void:
	var player: Character = CHARACTER_SCENE.instantiate()
	player_spawn.add_child(player)
	player.apply_from_player_data()
	player.enable_preview_camera(false)  # fight uses scene camera

func _spawn_dummy_enemy() -> void:
	var enemy: Character = CHARACTER_SCENE.instantiate()
	enemy_spawn.add_child(enemy)
	# Apply male body + default skin as dummy
	enemy.apply_gender("male")
	enemy.apply_skin("caucasian")
	# Tint enemy red so it's visually distinct
	enemy.modulate = Color(1.0, 0.4, 0.4)
	enemy.enable_preview_camera(false)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
