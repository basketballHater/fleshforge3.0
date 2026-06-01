# Customization screen.
# Loads all FFItemData resources from subfolders, populates tab lists,
# shows item info, applies changes to live preview, saves on confirm.
extends Node

var ITEM_FOLDERS := {
	"helmet":  "res://resources/items/helmets/",
	"weapons": "res://resources/items/weapons/",
	"legs":    "res://resources/items/legs/",
	"back":    "res://resources/items/back/",
	"armour":    "res://resources/items/armour/",
	"top":    "res://resources/items/outfits/tops/%s/" % [PlayerData.gender],
	"bottom": "res://resources/items/outfits/bottoms/%s/" % [PlayerData.gender],
}

# Tracks the currently selected item per slot
var _selected: Dictionary = {
	"helmet":  null,
	"weapons": null,
	"legs":    null,
	"back":    null,
	"armour":    null,
	"top":    null,
	"bottom": null,
}

@onready var character:     Character    = $Viewport/Character

@onready var preview_camera:     Camera3D    = $Viewport/SubViewportContainer/SubViewport/Camera3D
var _orbit_active:   bool    = false
var _orbit_last_pos: Vector2 = Vector2.ZERO
var _orbit_yaw:      float   = 0.0
const ORBIT_SPEED:   float   = 0.4

@onready var tab_container: TabContainer = $UI/Interface/HBoxContainer/VBoxContainer2/NinePatchRect2/HBoxContainer/VBoxContainer/TabContainer
@onready var panel_container: PanelContainer = $UI/Interface/HBoxContainer/VBoxContainer2/PanelContainer

@onready var augments: Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/Augments
@onready var outfits: Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/Outfits

@onready var name_label:    Label        = $UI/Interface/ItemInfoPanel/ItemNameLabel
@onready var class_label:   Label        = $UI/Interface/ItemInfoPanel/ItemClassLabel
@onready var btn_save:      Button       = $UI/Interface/BtnSave
@onready var btn_back:      Button       = $UI/Interface/BtnBack

var equipment_slots = ["helmet", "weapons", "legs", "back", "armour"]
var outfit_slots    = ["top", "bottom"]
@onready var _outfit_panels:    Array = []
@onready var _equipment_panels: Array = []

@onready var content_area: PanelContainer = $UI/Interface/HBoxContainer/PanelContainer

func _ready() -> void:
	character.apply_from_player_data()
	#character.enable_preview_camera(true)
	#camera.current = true

	# Pre-select from saved data
	_selected["helmet"]  = _load_item(PlayerData.helmet_path)
	_selected["weapons"] = _load_item(PlayerData.weapons_path)
	_selected["legs"]    = _load_item(PlayerData.legs_path)
	_selected["back"]    = _load_item(PlayerData.back_path)
	_selected["armour"]    = _load_item(PlayerData.back_path)
	_selected["top"] = _load_item(PlayerData.top_path)
	_selected["bottom"] = _load_item(PlayerData.bottom_path)

	# Populate each tab — order must match TabContainer child order
	#var slots: Array[String] = ["helmet", "legs", "weapons", "back"]
	#for i in range(slots.size()):
		#var slot := slots[i]
		#var items := _load_items_for_slot(slot)
		#var tab_root: Control = tab_container.get_child(i)
		#if tab_root != null:
			#_populate_tab(tab_root, slot, items)
		#else:
			#push_warning("Customization: no tab found at index %d for slot '%s'" % [i, slot])
			
	#var augments: Array[String] = ["helmet", "legs", "weapons", "back", "armour"]
	#var outfits: Array[String] = ["outfit_top", "outfit_bottom"]

	var slots: Array[String] = ["helmet", "legs", "weapons", "back", "armour", "outfit_top", "outfit_bottom"]
	#FAHHHHHH
	#for i in range(slots.size()):
		#var slot := slots[i]
		#var items := _load_items_for_slot(slot)
		#var slot_root: Control = tab_container.get_child(i)
		#if slot_root != null:
			#_populate_tab(slot_root, slot, items)
	#for child in tab_container.get_children():
		#child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	augments.pressed.connect(display_gear.bind(equipment_slots))
	outfits.pressed.connect(display_gear.bind(outfit_slots))

	btn_save.pressed.connect(_on_save)
	btn_back.pressed.connect(_on_back)
	
	character.animation.animation_finished.connect(_on_animation_finished)
	character.animation.play("startCont")
# ── Load all .tres files from a folder ───────────────────────────────────────

func display_gear(slots: Array) -> void:
	clear_container(tab_container)
	
	for slot in slots:
		var list := GridContainer.new()
		list.columns = 3
		list.name = slot.to_upper()
		tab_container.add_child(list)
		
		var items := _load_items_for_slot(slot)
		_populate_tab_F(list, slot, items)

func clear_container(node: Node) -> void:
	for child in node.get_children():
		child.free()
	
func _input(event: InputEvent) -> void:
	if not preview_camera or not preview_camera.current:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_orbit_active   = event.pressed
			_orbit_last_pos = event.position
	elif event is InputEventMouseMotion and _orbit_active:
		var delta: float = event.position.x - _orbit_last_pos.x
		_orbit_yaw      += delta * ORBIT_SPEED
		# Rotate the GLB model, not the Character root
		# so camera and UI are unaffected
		character.rotation_degrees = Vector3(0, _orbit_yaw, 0)
		_orbit_last_pos  = event.position

func _load_items_for_slot(slot: String) -> Array[FFItemData]:
	var results: Array[FFItemData] = []
	var folder: String = ITEM_FOLDERS.get(slot, "")
	print("LESBOO",folder,"SLOT",slot)
	if folder == "":
		push_warning("Customization: no folder mapped for slot '%s'" % slot)
		return results

	var dir := DirAccess.open(folder)
	if dir == null:
		push_warning("Customization: folder not found: %s" % folder)
		return results

	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".tres"):
			var item: FFItemData = load(folder + fname)
			results.append(item)
		fname = dir.get_next()
	dir.list_dir_end()

	print("Customization: loaded %d items for slot '%s'" % [results.size(), slot])
	return results

# ── Populate a tab's VBoxContainer with buttons ───────────────────────────────

func _populate_tab(tab_root: Control, slot: String, items: Array[FFItemData]) -> void:
	var list: VBoxContainer = tab_root.get_node_or_null("ItemList")
	if list == null:
		push_warning("Customization: ItemList not found in tab for slot '%s'" % slot)
		return

	for item in items:
		print("GAYY",item)
		var btn := Button.new()
		btn.text = item.item_name
		btn.pressed.connect(_on_item_selected.bind(slot, item))
		list.add_child(btn)

func _populate_tab_F(tab_root: Control, slot: String, items: Array[FFItemData]) -> void:
	for item in items:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(200, 200)
		btn.text = item.item_name
		btn.pressed.connect(_on_item_selected.bind(slot, item))
		tab_root.add_child(btn)

# ── Item selected ─────────────────────────────────────────────────────────────

func _on_item_selected(slot: String, item: FFItemData) -> void:
	print("Customization: selected '%s' in slot '%s'" % [item.item_name, slot])

	if _selected[slot] == item:
		_selected[slot] = null
		_clear_slot(slot)
		_clear_info_panel()
		return

	_selected[slot] = item

	# Load meshes from GLB on demand before applying
	_load_meshes_into_item(item) #BAH

	_apply_to_character(slot, item)
	_update_info_panel(item)
	if(item is FFWeaponData):
		play_animation(item.weapon_class)

func play_animation(weapon_class: int):
	var animationName = ""

	match weapon_class:
		FFWeaponData.WeaponClass.SLASHER:
			animationName = "slasherStart"
		FFWeaponData.WeaponClass.HAMMER:
			animationName = "hammerStart"
		FFWeaponData.WeaponClass.BOXER:
			animationName = "boxerStart"
		FFWeaponData.WeaponClass.REAPER:
			animationName = "reaperStart"
		FFWeaponData.WeaponClass.SHOOTER:
			animationName = "shooterStart"
		FFWeaponData.WeaponClass.RAPID:
			animationName = "rapidStart"
	character.animation.play(animationName)
	#character.animation.play(animationName)
	

func _on_animation_finished(anim_name):
	if anim_name.ends_with("Start") or anim_name.ends_with("Cont"):
		var base = anim_name.replace("Start", "")
		character.animation.play("startCont")


func _load_meshes_into_item(item: FFItemData) -> void:
	# Only applies to items that have a meshes array (e.g. weapons, legs)
	
	if not "meshes" in item:
		return


	var glb_path : String = item.get_glb_path();	
	print(glb_path)
	if not ResourceLoader.exists(glb_path):
		push_warning("Customization: no GLB found at %s" % glb_path)
		return

	var glb_scene: PackedScene = load(glb_path)
	var instance := glb_scene.instantiate()

	# Collect all MeshInstance3D children, sorted by name (0, 1, 2...)
	var mesh_nodes := instance.find_children("*", "MeshInstance3D", true)
	mesh_nodes.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)

	# Assign into the item's meshes array in order
	for i in range(min(mesh_nodes.size(), item.meshes.size())):
		item.meshes[i] = mesh_nodes[i].mesh

	instance.queue_free()
	print("Customization: loaded %d meshes for item '%s'" % [mesh_nodes.size(), item.item_name])


func _apply_to_character(slot: String, item: FFItemData) -> void:
	match slot:
		"helmet":
			character.apply_helmet(item as FFHelmetData)
		"weapons":
			character.apply_weapon(item as FFWeaponData)
		"legs":
			character.apply_legs(item as FFLegData)
		"back":
			character.apply_back(item as FFBackData)
		"armour":
			character.apply_armour(item as FFArmourData)
		"top":
			character.apply_top(item as FFOutfitTopData)
		"bottom":
			character.apply_bottom(item as FFOutfitBottomData)

func _clear_slot(slot: String) -> void:
	match slot:
		"helmet":  character.apply_helmet(null)
		"weapons": character.apply_weapon(null)
		"legs":    character.apply_legs(null)
		"back":    character.apply_back(null)
		"armour":    character.apply_armour(null)
		"top":    character.apply_top(null)
		"bottom": character.apply_bottom(null)

# ── Info panel ────────────────────────────────────────────────────────────────

func _update_info_panel(item: FFItemData) -> void:
	name_label.text = item.item_name
	if item is FFWeaponData:
		class_label.text = "Class: " + (item as FFWeaponData).get_class_label()
	else:
		class_label.text = "Type: " + item.slot.capitalize()

func _clear_info_panel() -> void:
	name_label.text  = ""
	class_label.text = ""

# ── Save & Back ───────────────────────────────────────────────────────────────

func _on_save() -> void:
	PlayerData.helmet_path   = _path_of(_selected["helmet"])
	PlayerData.weapons_path = _path_of(_selected["weapons"])
	PlayerData.legs_path     = _path_of(_selected["legs"])
	PlayerData.back_path     = _path_of(_selected["back"])
	PlayerData.armour_path     = _path_of(_selected["armour"])
	PlayerData.top_path    = _path_of(_selected["top"])
	PlayerData.bottom_path = _path_of(_selected["bottom"])
	SaveManager.save_data()
	print("Customization: saved")
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

# ── Helpers ───────────────────────────────────────────────────────────────────

func _load_item(path: String) -> FFItemData:
	if path == "":
		return null
	return load(path) as FFItemData

func _path_of(item: FFItemData) -> String:
	if item == null:
		return ""
	return item.resource_path
