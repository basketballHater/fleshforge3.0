# Customization screen.
# Loads all FFItemData resources from subfolders, populates tab lists,
# shows item info, applies changes to live preview, saves on confirm.
extends Node

@onready var characterData = GameState.get_active_data()

@onready var ITEM_FOLDERS := {
	"helmet":  "",
	"weapons": "",
	"legs":    "",
	"back":    "",
	"armour":    "",
	"top":    "",
	"bottom": "",
}

# Tracks the currently selected item per slot
@onready var _selected: Dictionary = {
	"helmet":  null,
	"weapons": null,
	"legs":    null,
	"back":    null,
	"armour":    null,
	"top":    null,
	"bottom": null,
	"weaponClass": characterData.weapon_class,
	"legClass": characterData.leg_class,
	"backClass": characterData.back_class,
	"speed": characterData.speed
}

@onready var character:     Character   

@onready var preview_camera:     Camera3D    = $Viewport/SubViewportContainer/SubViewport/Camera3D
var _orbit_active:   bool    = false
var _orbit_last_pos: Vector2 = Vector2.ZERO
var _orbit_yaw:      float   = 0.0
const ORBIT_SPEED:   float   = 0.4

@onready var tab_container: TabContainer = $UI/Interface/HBoxContainer/VBoxContainer2/NinePatchRect2/HBoxContainer/VBoxContainer/TabContainer

@onready var augments: Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/Augments
@onready var outfits: Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/Outfits
@onready var moveset: Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/Moveset


@onready var name_label:    Label        = $UI/Interface/ItemInfoPanel/ItemNameLabel
@onready var class_label:   Label        = $UI/Interface/ItemInfoPanel/ItemClassLabel
@onready var btn_save:      Button       = $UI/Interface/BtnSave
@onready var btn_back:      Button       = $UI/Interface/BtnBack

var equipment_slots = ["helmet", "weapons", "legs", "back", "armour"]
var outfit_slots    = ["top", "bottom"]
var moveset_slots    = ["common", "special", "combo"]
@onready var _outfit_panels:    Array = []
@onready var _equipment_panels: Array = []

@onready var playerLabel: Label = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/Player
#@onready var content_area: PanelContainer = $UI/Interface/HBoxContainer/PanelContainer
@onready var genderBox:Control = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/gender
@onready var maleButton:Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/gender/HBoxContainer/Male
@onready var femaleButton:Button = $UI/Interface/HBoxContainer/NinePatchRect/VBoxContainer/gender/HBoxContainer/Female
@onready var next:Control = $UI/Interface/NEXT

@onready var movesetContainer:HBoxContainer = $UI/Interface/HBoxContainer/VBoxContainer2/NinePatchRect2/HBoxContainer/VBoxContainer/HBoxContainer
@onready var weaponButton:Button = $UI/Interface/HBoxContainer/VBoxContainer2/NinePatchRect2/HBoxContainer/VBoxContainer/HBoxContainer/Weapon
@onready var legButton:Button = $UI/Interface/HBoxContainer/VBoxContainer2/NinePatchRect2/HBoxContainer/VBoxContainer/HBoxContainer/Legs
@onready var backButton:Button = $UI/Interface/HBoxContainer/VBoxContainer2/NinePatchRect2/HBoxContainer/VBoxContainer/HBoxContainer/Back

@onready var attackClass:String = FFWeaponData.WeaponClass.keys()[characterData.weapon_class]

func getAddress():
	ITEM_FOLDERS = {
		"helmet":  "res://resources/items/helmets/",
		"weapons": "res://resources/items/weapons/",
		"legs":    "res://resources/items/legs/",
		"back":    "res://resources/items/back/",
		"armour":    "res://resources/items/armour/",
		"top":    "res://resources/items/outfits/tops/%s/" % [characterData.gender],
		"bottom": "res://resources/items/outfits/bottoms/%s/" % [characterData.gender],
		"common": "res://resources/attacks/attackData/common/%s/"% attackClass,
		"special": "res://resources/attacks/attackData/special/%s/"% attackClass,
		"combo": "res://resources/attacks/attackData/combo/%s/"% attackClass,
	}

func _ready() -> void:
	movesetContainer.visible = false
	augments.pressed.connect(display.bind(equipment_slots,3, false))
	outfits.pressed.connect(display.bind(outfit_slots,3,false))
	moveset.pressed.connect(display.bind(moveset_slots,1,true))
	
	weaponButton.pressed.connect(setWeapon)
	legButton.pressed.connect(setLeg)
	backButton.pressed.connect(setBack)

	btn_save.pressed.connect(_on_save)
	btn_back.pressed.connect(_on_back)
	
	character.animation.animation_finished.connect(_on_animation_finished)
	character.animation.play("startCont")
	getAddress()
# ── Load all .tres files from a folder ───────────────────────────────────────

func setWeapon():
	attackClass = FFWeaponData.WeaponClass.keys()[characterData.weapon_class]
	display(moveset_slots, 1,true)
func setBack():
	attackClass = FFBackData.BackClass.keys()[characterData.back_class]
	display(moveset_slots, 1,true)
func setLeg():
	attackClass = FFLegData.LegClass.keys()[characterData.leg_class]
	display(moveset_slots, 1,true)
	

func nextCharacter():
	_on_save()
	GameState.customization_mode = "versus"
	if GameState.active_player == 1:
		GameState.active_player = 2
		get_tree().change_scene_to_file("res://scenes/menus/Customization.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/fight/fight_scene.tscn")
	#character.apply_from_player_data()
	
	
func display(slots: Array, colNum: int, visibility:bool) -> void:
	clear_container(tab_container)
	movesetContainer.visible = visibility
	
	for slot in slots:
		var scroll := ScrollContainer.new()
		scroll.name = slot.to_upper()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		scroll.custom_minimum_size.y = tab_container.custom_minimum_size.y
		
		var list := GridContainer.new()
		list.columns = colNum
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		scroll.add_child(list)
		tab_container.add_child(scroll)
		
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
	getAddress()
	var results: Array[FFItemData] = []
	var folder: String = ITEM_FOLDERS.get(slot, "")
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
	print("Customization: Folder:  '%s'" % [ folder])

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
	var attacks: Array[FFItemData] = []
	var others: Array[FFItemData] = []

	# separate attacks from other items
	for item in items:
		if item is AttackData:
			attacks.append(item)
		else:
			others.append(item)

	# display non-attacks first as normal
	for item in others:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(200, 200)
		btn.text = item.item_name
		btn.pressed.connect(_on_item_selected.bind(slot, item))
		tab_root.add_child(btn)

	# group attacks by input_sequence
	var groups: Dictionary = {}
	for attack in attacks:
		# convert the sequence array to a string so it can be used as a dict key
		var key = str(attack.input)
		if not groups.has(key):
			groups[key] = []
		groups[key].append(attack)

	# display each group
	for key in groups:
		# header label showing the input sequence
		var sequence = groups[key][0].input  # grab sequence from first item
		var label := Label.new()
		label.text = sequence_to_string(sequence)
		tab_root.add_child(label)

		# attacks in this group
		for attack in groups[key]:
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(600, 200)
			btn.text = attack.item_name
			btn.pressed.connect(_on_item_selected.bind(slot, attack))
			tab_root.add_child(btn)


func sequence_to_string(input: int) -> String:
	var steps = []
	steps.append(InputDefs.mask_to_string(input))
	return " → ".join(steps)

# ── Item selected ─────────────────────────────────────────────────────────────

func _on_item_selected(slot: String, item: FFItemData) -> void:
	print("Customization: selected '%s' in slot '%s'" % [item.item_name, slot])
	
	if(item is AttackData):
		if item.slot == FFItemData.itemClass.SPECIAL:
			character.animation.play(item.animation_name)
			var key = item.input
			var preliminary = item.preliminary_input
			var address = item.get_res_path()
			GameState.get_active_data().set_special_attack(key, preliminary, address)
		elif item.slot == FFItemData.itemClass.COMBO:
			character.animation.play(item.animation_name)
			var key:String
			key = str(item.attackID)
			var address = item.get_res_path()
			GameState.get_active_data().set_combo(key, address)
		else:
			character.animation.play(item.animation_name)
			var key:int
			if slot == 'common':
				key = item.input
			else:
				key = item.attackID
			var address = item.get_res_path()
			GameState.get_active_data().set_attack(key, address)
		
	else:
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
			_selected["weaponClass"] = item.weapon_class as FFWeaponData.WeaponClass
		if(item is FFLegData):
			_selected["legClass"] = item.leg_class as FFLegData.LegClass
			_selected["speed"] = item.speed
		if(item is FFBackData):
			_selected["backClass"] = item.back_class as FFBackData.BackClass
		

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
	print("PAAAATHH at %s" % glb_path)
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
		class_label.text = "Type: " + FFItemData.itemClass.keys()[item.slot]

func _clear_info_panel() -> void:
	name_label.text  = ""
	class_label.text = ""

# ── Save & Back ───────────────────────────────────────────────────────────────

func _on_save() -> void:
	characterData.helmet_path   = _path_of(_selected["helmet"])
	characterData.weapons_path = _path_of(_selected["weapons"])
	characterData.legs_path     = _path_of(_selected["legs"])
	characterData.back_path     = _path_of(_selected["back"])
	characterData.armour_path     = _path_of(_selected["armour"])
	characterData.top_path    = _path_of(_selected["top"])
	characterData.bottom_path = _path_of(_selected["bottom"])
	characterData.weapon_class = _selected["weaponClass"] 
	characterData.leg_class = _selected["legClass"]
	characterData.back_class = _selected["backClass"]
	characterData.speed = _selected["speed"]
	
	SaveManager.save_data()
	print("Customization: saved")
	

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
