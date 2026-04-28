# First-launch setup screen.
# Gender + skin choice → saves → goes to MainMenu.
extends Node

# ── Skin swatch definitions ──────────────────────────────────────────────────
const MALE_SWATCHES := [
	{ "id": "caucasianMale", "color": Color(1.00, 0.85, 0.75) },
	{ "id": "tanMale",       "color": Color(0.90, 0.70, 0.55) },
	{ "id": "ebonyMale",     "color": Color(0.22, 0.14, 0.09) },
]

const FEMALE_SWATCHES := [
	{ "id": "caucasianFemale", "color": Color(1.00, 0.85, 0.75) },
	{ "id": "tanFemale",       "color": Color(0.90, 0.70, 0.55) },
	{ "id": "ebonyFemale",     "color": Color(0.22, 0.14, 0.09) },
]

# ── Node references ──────────────────────────────────────────────────────────
@onready var character:   Character = $SubViewportContainer/SubViewport/Character
@onready var btn_male:    Button    = $UI/GenderPanel/BtnMale
@onready var btn_female:  Button    = $UI/GenderPanel/BtnFemale
@onready var skin_panel:  HBoxContainer = $UI/SkinPanel
@onready var btn_confirm: Button    = $UI/BtnConfirm

func _ready() -> void:
	# Apply any existing defaults for preview
	character.apply_gender(PlayerData.gender)
	character.apply_skin(PlayerData.skin_id)
	character.enable_preview_camera(true)

	# Wire gender buttons
	btn_male.pressed.connect(_on_gender_selected.bind("male"))
	btn_female.pressed.connect(_on_gender_selected.bind("female"))
	btn_confirm.pressed.connect(_on_confirm)

	# Build skin swatches dynamically
	#_build_skin_swatches()

func _build_skin_swatches(gender: String) -> void:
	var SWATCHES
	if(gender == 'male'):
		SWATCHES = MALE_SWATCHES
	elif(gender == 'female'):
		SWATCHES = FEMALE_SWATCHES
	for swatch in SWATCHES:
		var btn := ColorRect.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.color               = swatch["color"]
		btn.mouse_filter        = Control.MOUSE_FILTER_STOP

		# Wrap in a Button so it's clickable
		var wrapper := Button.new()
		wrapper.custom_minimum_size = Vector2(52, 52)
		wrapper.add_child(btn)
		wrapper.pressed.connect(_on_skin_selected.bind(swatch["id"]))
		skin_panel.add_child(wrapper)
		_on_skin_selected(SWATCHES[0]['id'])
		
		

func _on_gender_selected(gender: String) -> void:
	for child in skin_panel.get_children():
		child.queue_free()
	
	PlayerData.gender = gender
	character.apply_gender(gender)
	
	_build_skin_swatches(gender)

func _on_skin_selected(skin_id: String) -> void:
	PlayerData.skin_id = skin_id
	print(skin_id)
	character.apply_skin(skin_id)

func _on_confirm() -> void:
	PlayerData.is_first_launch = false
	SaveManager.save_data()
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
