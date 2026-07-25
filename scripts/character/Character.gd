class_name Character
extends Node3D

# ── Bone names ────────────────────────────────────────────────────────────────
# Replace with your exact bone names from the GLB
const BONE_HEAD      := "head"
const BONES_WEAPON_R := ["wepon1.R", "wepon2.R", "wepon3.R"]
const BONES_WEAPON_L := ["wepon1.L", "wepon2.L", "wepon3.L"]
const BONES_LEGS_R   := ["lowerleg.R", "foot.R", "toe.R", "extention2.R"]
const BONES_LEGS_L   := ["lowerleg.L", "foot.L", "toe.L", "extention2.L"]
const BONES_BACK   := ["back", "back_Up1.R", "back_Up2.R", "back_Up3.R", "back_Up4.R", 
"back_Up5.R","back_Up1.L", "back_Up2.L", "back_Up3.L", "back_Up4.L", 
"back_Up5.L", "back_Down1.R", "back_Down2.R", "back_Down3.R", "back_Down4.R", 
"back_Down5.R",  "back_Down1.L", "back_Down2.L", "back_Down3.L", "back_Down4.L", 
"back_Down5.L"]
const BONES_ARMOUR_R := ["upperArm.R"]
const BONES_ARMOUR_L := ["upperArm.L"]

# ── Skin texture map ──────────────────────────────────────────────────────────
const SKIN_TEXTURE_MAP := {
	"caucasianMale":   "res://assets/textures/male_caucasian.png",
	"tanMale":         "res://assets/textures/male_tan.png",
	"ebonyMale":       "res://assets/textures/male_ebony.png",
	"caucasianFemale": "res://assets/textures/female_caucasian.png",
	"tanFemale":       "res://assets/textures/female_tan.png",
	"ebonyFemale":     "res://assets/textures/female_ebony.png",
}

# ── Body mesh references ──────────────────────────────────────────────────────
#var body_male:   Node3D  # male body mesh (named "body" in GLB)
#var body_female: Node3D  # female body mesh (named "skin" in GLB)
#var cuffMale_R: Node3D
#var cuffMale_L: Node3D
#var cuffFemale_R: Node3D
#var cuffFemale_L: Node3D
#var top1:        Node3D  # female top pieces
#var top2:        Node3D
#var top3:        Node3D


var _current_outfit_node: Node = null

# ── Character model + skeleton ────────────────────────────────────────────────
var character: Node3D    # the instantiated GLB root
var _skeleton: Skeleton3D
var animation: AnimationPlayer

# ── Equipment slot mesh instances (built at runtime) ─────────────────────────
var _slot_helmet: Array[MeshInstance3D] = []
var _slot_weapon_r: Array[MeshInstance3D] = []
var _slot_weapon_l: Array[MeshInstance3D] = []
var _slot_legs_r:   Array[MeshInstance3D] = []
var _slot_legs_l:   Array[MeshInstance3D] = []
var _slot_back:   Array[MeshInstance3D] = []
var _slot_armour_r: Array[MeshInstance3D] = []
var _slot_armour_l: Array[MeshInstance3D] = []
# ── Outfit slots (dynamically loaded and rebound) ────────────────────────────
var _top_node:    MeshInstance3D = null
var _bottom_node: MeshInstance3D = null

# Pending async loads — track separately so both can load simultaneously
var _pending_top_path:    String = ""
var _pending_bottom_path: String = ""

# ── Orbit drag state ──────────────────────────────────────────────────────────
var _orbit_active:   bool    = false
var _orbit_last_pos: Vector2 = Vector2.ZERO
var _orbit_yaw:      float   = 0.0
const ORBIT_SPEED:   float   = 0.4

var characterData = GameState.get_active_data()

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	print("Character: _ready called")

	# Load and instantiate the GLB
	#var scene := load("res://assets/models/bothEdit.glb")
	#if scene == null:
		#push_error("Character: failed to load both.glb")
		#return
#
	#character = scene.instantiate()
	#add_child(character)
	character = $bothEdit

	# Cache body mesh nodes
	#body_male   = character.get_node("Armature/Skeleton3D/body")
	#body_female = character.get_node("Armature/Skeleton3D/skin")
	#top1        = character.get_node("Armature/Skeleton3D/top1")
	#body_male   = character.get_node("Armature/Skeleton3D/male")
	#body_female = character.get_node("Armature/Skeleton3D/female")
	#cuffMale_R   = character.get_node("Armature/Skeleton3D/cuffMale_R")
	#cuffMale_L = character.get_node("Armature/Skeleton3D/cuffMale_L")
	#cuffFemale_R   = character.get_node("Armature/Skeleton3D/cuffFemale_R")
	#cuffFemale_L = character.get_node("Armature/Skeleton3D/cuffFemale_L")
	animation = character.get_node("AnimationPlayer")
	#top2        = character.get_node("Armature/Skeleton3D/top2")
	#top3        = character.get_node("Armature/Skeleton3D/top3")

	# Cache skeleton reference
	_skeleton = character.get_node("Armature/Skeleton3D")
	if _skeleton == null:
		push_error("Character: Skeleton3D not found at Armature/Skeleton3D")
		return
	#for i in range(_skeleton.get_bone_count()):
		#print(_skeleton.get_bone_name(i))

	# Build all equipment slots dynamically on the skeleton
	_build_equipment_slots()

	print("Character: setup complete")

# ── Gender ────────────────────────────────────────────────────────────────────

#func _make_male(value: bool) -> void:
	#body_male.visible = value
	#cuffMale_R.visible = value
	#cuffMale_L.visible = value

func _on_gender_selected(gender: String) -> void:
	characterData.gender = gender
	apply_gender(gender)


#func _make_female(value: bool) -> void:
	#body_female.visible = value
	#cuffFemale_R.visible = value
	#cuffFemale_L.visible = value
	#top1.visible        = value
	#top2.visible        = value
	#top3.visible        = value

func apply_gender(gender: String) -> void:
	print("Character: apply_gender → ", gender)
	#_make_male(gender == "male")
	#_make_female(gender == "female")

# ── Skin ──────────────────────────────────────────────────────────────────────

func apply_skin(skin_id: String) -> void:
	print("Character: apply_skin → ", skin_id)
	var path : String = SKIN_TEXTURE_MAP.get(skin_id, "")
	if path == "":
		push_warning("Character: unknown skin_id '%s'" % skin_id)
		return
	var tex: Texture2D = load(path)
	if tex == null:
		push_error("Character: failed to load texture at '%s'" % path)
		return
	#_apply_texture_to_body(body_male,   tex)
	#_apply_texture_to_body(body_female, tex)

# ── Outfit ────────────────────────────────────────────────────────────────────

func apply_top(item: FFOutfitTopData) -> void:
	if item == null:
		_free_outfit_node(_top_node)
		_top_node = null
		return
	var path :String= item.get_glb_path()
	_load_outfit_async(path, true)

func apply_bottom(item: FFOutfitBottomData) -> void:
	if item == null:
		_free_outfit_node(_bottom_node)
		_bottom_node = null
		return
	var path :String= item.get_glb_path()
	_load_outfit_async(path, false)

func _load_outfit_async(glb_path: String, is_top: bool) -> void:
	if glb_path == "":
		push_warning("Character: outfit GLB path is empty")
		return

	ResourceLoader.load_threaded_request(glb_path)

	if is_top:
		_pending_top_path = glb_path
	else:
		_pending_bottom_path = glb_path

	set_process(true)

func _process(_delta: float) -> void:
	_poll_outfit_load(_pending_top_path,    true)
	_poll_outfit_load(_pending_bottom_path, false)

	# Stop processing when nothing is pending
	if _pending_top_path == "" and _pending_bottom_path == "":
		set_process(false)

func _poll_outfit_load(path: String, is_top: bool) -> void:
	if path == "":
		return

	var status := ResourceLoader.load_threaded_get_status(path)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed: PackedScene = ResourceLoader.load_threaded_get(path)
		_apply_packed_outfit(packed, is_top)
		if is_top:
			_pending_top_path = ""
		else:
			_pending_bottom_path = ""

	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Character: async outfit load failed → '%s'" % path)
		if is_top:
			_pending_top_path = ""
		else:
			_pending_bottom_path = ""

func _apply_packed_outfit(packed: PackedScene, is_top: bool) -> void:
	var temp_root := packed.instantiate()

	var outfit_mesh := _find_mesh_instance(temp_root)
	if outfit_mesh == null:
		push_error("Character: no MeshInstance3D found in outfit GLB")
		temp_root.queue_free()
		return

	var new_instance := MeshInstance3D.new()
	new_instance.mesh     = outfit_mesh.mesh
	print("NEW INSTANCE MESH", new_instance.mesh)
	new_instance.skin     = _remap_skin(outfit_mesh.skin)
	print("NEW INSTANCE SKIN", new_instance.skin)
	new_instance.skeleton = _skeleton.get_path()
	print("NEW INSTANCE SKELETON", new_instance.skeleton)

	_skeleton.add_child(new_instance)
	temp_root.queue_free()

	# Free the old outfit piece and replace it
	if is_top:
		_free_outfit_node(_top_node)
		_top_node = new_instance
		print("Character: outfit top applied")
	else:
		_free_outfit_node(_bottom_node)
		_bottom_node = new_instance
		print("Character: outfit bottom applied")

func _free_outfit_node(node: MeshInstance3D) -> void:
	if node != null and is_instance_valid(node):
		node.queue_free()

# ── Equipment ─────────────────────────────────────────────────────────────────

#func apply_helmet(item: FFHelmetData) -> void:
	#if _slot_helmet == null:
		#return
	##_slot_helmet[0].mesh    = item.meshes[0] if item else null
	##_slot_helmet.visible = item != null
	#_apply_multi_mesh(_slot_helmet, item.meshes if item else [])

func apply_helmet(item: FFHelmetData) -> void:
	_apply_multi_mesh(_slot_helmet, item.meshes if item else [])

func apply_weapon(item: FFWeaponData) -> void:
	_apply_multi_mesh(_slot_weapon_r, item.meshes if item else [])
	_apply_multi_mesh(_slot_weapon_l, item.meshes if item else [])

func apply_legs(item: FFLegData) -> void:
	_apply_multi_mesh(_slot_legs_r, item.meshes if item else [])
	_apply_multi_mesh(_slot_legs_l, item.meshes if item else [])

func apply_back(item: FFBackData) -> void:
	print("applyingback")
	_apply_multi_mesh(_slot_back, item.meshes if item else [])

func apply_armour(item: FFArmourData) -> void:
	print("applyingarmour")
	_apply_multi_mesh(_slot_armour_r, item.meshes if item else [])
	_apply_multi_mesh(_slot_armour_l, item.meshes if item else [])

func apply_from_player_data() -> void:
	var charData = GameState.get_active_data()
	apply_gender(charData.gender)
	apply_skin(charData.skin_id)
	_load_and_apply_helmet(charData.helmet_path)
	_load_and_apply_weapon(charData.weapons_path)
	_load_and_apply_legs(charData.legs_path)
	_load_and_apply_back(charData.back_path)
	_load_and_apply_armour(charData.armour_path)
	_load_and_apply_top(charData.top_path)
	_load_and_apply_bottom(charData.bottom_path)

#func enable_preview_camera(enabled: bool) -> void:
	#if preview_camera:
		#preview_camera.current = enabled

# ── Orbit drag ────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	#if not preview_camera or not preview_camera.current:
		#return
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

# ── Build equipment slots at runtime ─────────────────────────────────────────

func _build_equipment_slots() -> void:
	# Helmet — single bone
	#_slot_helmet = _create_bone_slot(BONE_HEAD)
	for i in 2:
		_slot_helmet.append(_create_bone_slot(BONE_HEAD, "helmet_piece_%d" % i))
		
	# Weapons — 3 bones per hand
	for bone in BONES_WEAPON_R:
		_slot_weapon_r.append(_create_bone_slot(bone))
	for bone in BONES_WEAPON_L:
		_slot_weapon_l.append(_create_bone_slot(bone))

	# Legs — 4 bones per leg
	for bone in BONES_LEGS_R:
		_slot_legs_r.append(_create_bone_slot(bone))
	for bone in BONES_LEGS_L:
		_slot_legs_l.append(_create_bone_slot(bone))
	for bone in BONES_BACK:
		_slot_back.append(_create_bone_slot(bone))
	for bone in BONES_ARMOUR_L:
		_slot_armour_l.append(_create_bone_slot(bone))
	for bone in BONES_ARMOUR_R:
		_slot_armour_r.append(_create_bone_slot(bone))

	print("Character: equipment slots built")

func _create_bone_slot(bone_name: String, slot_id: String = "") -> MeshInstance3D:
	var bone_idx := _skeleton.find_bone(bone_name)
	if bone_idx == -1:
		push_error("Character: bone '%s' not found." % bone_name)
		return null

	var unique_id := slot_id if slot_id != "" else bone_name

	var attachment := BoneAttachment3D.new()
	attachment.name      = "Slot_" + unique_id
	attachment.bone_name = bone_name        # both point to the same bone
	_skeleton.add_child(attachment)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name    = "Mesh_" + unique_id
	mesh_instance.visible = false
	attachment.add_child(mesh_instance)
	
	return mesh_instance

# ── Internals ─────────────────────────────────────────────────────────────────

func _apply_multi_mesh(slots: Array[MeshInstance3D], meshes: Array) -> void:
	for i in slots.size():
		if slots[i] == null:
			continue
		var mesh: Mesh = meshes[i] if i < meshes.size() else null
		slots[i].mesh    = mesh
		slots[i].visible = mesh != null

func _apply_texture_to_body(body: MeshInstance3D, tex: Texture2D) -> void:
	var mat := body.get_surface_override_material(0)
	if mat == null:
		mat = body.mesh.surface_get_material(0)
	if mat == null:
		push_warning("Character: no material found on '%s'" % body.name)
		return
	var local_mat: StandardMaterial3D = mat.duplicate()
	local_mat.albedo_texture          = tex
	body.set_surface_override_material(0, local_mat)

func _load_and_apply_helmet(path: String) -> void:
	if path == "":
		apply_helmet(null)
		return
	var item := load(path) as FFHelmetData
	_load_meshes_into_item(item)  # <- add
	apply_helmet(item)

func _load_and_apply_weapon(path: String) -> void:
	if path == "":
		apply_weapon(null)
		return
	var item := load(path) as FFWeaponData
	_load_meshes_into_item(item)  # <- add
	apply_weapon(item)

func _load_and_apply_legs(path: String) -> void:
	if path == "":
		apply_legs(null)
		return
	var item := load(path) as FFLegData
	_load_meshes_into_item(item)  # <- add
	apply_legs(item)

func _load_and_apply_back(path: String) -> void:
	if path == "":
		apply_back(null)
		return
	var item := load(path) as FFBackData
	_load_meshes_into_item(item)  # <- add
	apply_back(item)

func _load_and_apply_armour(path: String) -> void:
	if path == "":
		apply_armour(null)
		return
	var item := load(path) as FFArmourData
	_load_meshes_into_item(item)  # <- add
	apply_armour(item)

func _load_and_apply_top(path: String) -> void:
	if path == "": apply_top(null); return
	apply_top(load(path) as FFOutfitTopData)

func _load_and_apply_bottom(path: String) -> void:
	if path == "": apply_bottom(null); return
	apply_bottom(load(path) as FFOutfitBottomData)

func _load_meshes_into_item(item: FFItemData) -> void:
	if item == null or not "meshes" in item:
		return
	var glb_path := item.get_glb_path()
	if not ResourceLoader.exists(glb_path):
		push_warning("Character: no GLB found at %s" % glb_path)
		return
	var instance := (load(glb_path) as PackedScene).instantiate()
	var mesh_nodes := instance.find_children("*", "MeshInstance3D", true)
	mesh_nodes.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	for i in range(min(mesh_nodes.size(), item.meshes.size())):
		item.meshes[i] = mesh_nodes[i].mesh
	instance.queue_free()

# Loads an outfit GLB, extracts its mesh, rebinds it to our skeleton,
# replaces the current outfit mesh instance

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node

	for child in node.get_children():
		var result := _find_mesh_instance(child)
		if result:
			return result

	return null


func _remap_skin(original_skin: Skin) -> Skin:
	if original_skin == null:
		return null
	var new_skin := Skin.new()
	for i in original_skin.get_bind_count():
		var bone_name := original_skin.get_bind_name(i)
		var bone_idx  := _skeleton.find_bone(bone_name)
		if bone_idx == -1:
			push_warning("Character: outfit bone '%s' not found in skeleton" % bone_name)
			continue
		new_skin.add_bind(bone_idx, original_skin.get_bind_pose(i))
	return new_skin
