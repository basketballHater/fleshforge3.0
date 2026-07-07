extends Node

#const CHARACTERSPAWN = 'res://scenes/character/Character.tscn'
@onready var char1: CharacterBody3D = $player1
@onready var char2: CharacterBody3D
@onready var back: Button = $UI/back
@onready var label: Label = $UI/Label
@onready var label1: Label = $UI/char1Lab
@onready var label2: Label = $UI/char2Lab


@onready var model1: Node3D = $player1/Character
@onready var model2: Node3D

@onready var A: MeshInstance3D = $A
@onready var B: MeshInstance3D = $B




func _ready() -> void:
	spawn_characters()
	back.pressed.connect(on_back)
	

func _process(delta):
	if not char1 or not char2:
		return
	physicsManager()
	#var start = Time.get_ticks_usec()



	attackManager(char1, char2)
	attackManager(char2, char1)
	#var end = Time.get_ticks_usec()
	
	A.transform = char1.A
	B.transform = char1.B

	#if char2.waitingCol or char1.waitingCol:
		#print("build_hitboxes HIT took ", (end - start) / 1000.0, " ms")
	#else:
		#print("build_hitboxes NOT HIT took ", (end - start) / 1000.0, " ms")
	label.text = "input1:"+str(char1.input_history[0])+" "+"inputArray:"+str(char1.input_history)+" "+"input2:"+str(char2.input_history[0])
	if char1.current_attack:
		label1.text = "char1 hitbox morinoring: "+str(char1.hurtboxBody.monitoring)+"\n "+"char1 hitbox monitorable: "+str(char1.hurtboxBody.monitorable)+"\n "+"char1 hurtbox morinoring: "+str(char1.hurtboxMachine.monitoring)+"\n "+"char1 hurtbox monitorable: "+str(char1.hurtboxMachine.monitorable)+"\n "+"char1 ifImpact: "+str(char1.ifImpact)+"\n "+"char1 waitingCol: "+str(char1.waitingCol)+"\n "+"char1 hit: "+str(char1.hitBody)+"\n "+"char1 comboLate: "+str(char1.comboLate)+"\n "+"char1 crouching: "+str(char1.crouching)+"\n "+"char1 Attacking: "+str(char1.attacking)+"\n "+"char1 blocking: "+str(char1.blocking)+"\n "+"char1 STATE: "+str(char1.current_state as female_rapid.State)+"\n" + "char1 transition_direction: "+str(char1.transition_direction)
	label2.text = "char2 hitbox morinoring: "+str(char2.hurtboxBody.monitoring)+"\n "+"char2 hitbox monitorable: "+str(char2.hurtboxBody.monitorable)+"\n "+"char2 hurtbox morinoring: "+str(char2.hurtboxMachine.monitoring)+"\n "+"char2 hurtbox monitorable: "+str(char2.hurtboxMachine.monitorable)+"\n "+"char2 ifImpact: "+str(char2.ifImpact)+"\n "+"char2 waitingCol: "+str(char2.waitingCol)+"\n "+"char2 hit: "+str(char2.hitBody)
	
func physicsManager():
	Physics.characterDiff = char1.global_position.x - char2.global_position.x
	if(Physics.characterDiff > 0):
		Physics.left = 2
	else:
		Physics.left = 1
	Physics.characterDiff = abs(Physics.characterDiff)
	Physics.midP = (char1.global_position.x + char2.global_position.x) / 2.0
	#print("LEFFFFTTT: ",Physics.left)
	#print("Char 1",char1.input_history)
	
	#print("Char 2",char2.input_history)

func attackManager(attacker:CharacterBody3D, defender:CharacterBody3D) ->void:
	# in fight scene physics process
	var startA = Time.get_ticks_usec()
	attacker.handleAttack()
	var endA = Time.get_ticks_usec()
	#print("player ",attacker.playerNum," handleAttack", (endA - startA) / 1000.0, " ms")
	
	if defender.waitingCol and (defender.hitBody or defender.hitMachine):
		var start = Time.get_ticks_usec()
		if attacker.current_attack.is_launcher:
			defender.animPlayer.stop()
			defender.animPlayer.play("bigHitStun")
			defender.animPlayer.queue("bigHitRecover")
		else:
			defender.animPlayer.stop()
			defender.animPlayer.play("smallHitStun")
			defender.animPlayer.queue("smallHitRecover")
		if Physics.left == 1:
			defender.momentum = attacker.current_attack.knockback
		else:
			defender.momentum = attacker.current_attack.knockback * -1
		
		attacker.hitbox.monitorable = false
		defender.hurtboxBody.monitoring = false
		defender.hurtboxMachine.monitoring = false
		#defender.hurtbox.monitoring = false
		
		defender.hitBody = false
		defender.hitMachine = false
		var end = Time.get_ticks_usec()

		print("player ",attacker.playerNum," waiting Col", (end - start) / 1000.0, " ms")
		return

	if attacker.ifImpact:
		var start = Time.get_ticks_usec()

		defender.handleDefence()

		defender.hurtboxBody.monitoring = true
		defender.hurtboxMachine.monitoring = true
		attacker.hitbox.monitorable = true
		
		attacker.ifImpact = false
		
		
		defender.waitingCol = true
		var end = Time.get_ticks_usec()

		print("player ",attacker.playerNum," if Impact ", (end - start) / 1000.0, " ms")
		return
	else:
		defender.waitingCol = false
		defender.hurtboxBody.monitoring = false
		defender.hurtboxMachine.monitoring = false
		attacker.hitbox.monitorable = false

	var endT= Time.get_ticks_usec()
	#print("player ",attacker.playerNum," AttackAll", (endT - startA) / 1000.0, " ms")


func on_back()-> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")


func spawn_characters() -> void:
	GameState.active_player = 1
	model1.apply_from_player_data()
	model1.set_process_input(false)
	

	# reinstantiate char2 from same scene as char1
	#var char1_scene = load(char1.scene_file_path)
	#char2 = char1_scene.instantiate()
	#char2.playerNum = 2
	#add_child(char2)
	#await get_tree().process_frame  # let _ready and @onready run
	
	var player_scene = load("res://scenes/fight/player.tscn")
	char2 = player_scene.instantiate() as CharacterBody3D
	char2.playerNum = 2
	add_child(char2)
	await get_tree().process_frame

	GameState.active_player = 2
	model2 = char2.get_node("Character")
	
	
	model2.apply_from_player_data()
	model2.set_process_input(false)
	


	_build_attack_cache(char1)
	_build_attack_cache(char2)
	char1.global_position = Vector3(-3.0, 1.0, 0.0)
	char2.global_position = Vector3(3.0, 1.0, 0.0)

func _build_attack_cache(char:CharacterBody3D) -> void:	
	GameState.active_player = char.playerNum
	var data = GameState.get_active_data()  # already set correctly before apply_from_player_data()

	char.speed = data.speed
	print('kjnhbvg',data.speed)
	if data.leg_class == 0:
		char.walkingAnimF = 'walkingF'
		char.walkingAnimB = 'walkingB'
	elif data.leg_class == 1:
		char.walkingAnimF = 'rollingF'
		char.walkingAnimB = 'rollingB'

	mapDataToCache(data.attack_map, char.attack_cache, char)
	mapDataToCache(data.combo_map, char.combo_cache, char)
	print("BITCH",data.special_map)
	char.special_cache = {0:{}, 2:{}, 4:{}, 8:{}}
	print("BITCH",char.special_cache[0])
	if(data.special_map.has(0)):
		mapDataToCache(data.special_map[0], char.special_cache[0], char)
	if(data.special_map.has(2)):
		mapDataToCache(data.special_map[2], char.special_cache[2], char)
	if(data.special_map.has(4)):
		mapDataToCache(data.special_map[4], char.special_cache[4], char)
	if(data.special_map.has(8)):
		mapDataToCache(data.special_map[8], char.special_cache[8], char)
	
	print('ATTACKCACHE',char.attack_cache)
	print('COMBOCACHE',char.combo_cache)
	print('SPECIALCACHE',char.special_cache)
	char.movement_cache.clear()
	for anim_name in char.animPlayer.get_animation_list():
		if "_" in anim_name:
			continue
		var anim: Animation = char.animPlayer.get_animation(anim_name)
		#anim.loop_mode = Animation.LOOP_LINEAR
		var totalTime = anim.length
		var snapshot = MovementData.new()
		hurtboxSet(char, snapshot, totalTime/2, totalTime, 0)
		char.movement_cache[anim_name] = snapshot
		

func mapDataToCache(data:Dictionary, cache:Dictionary, char:CharacterBody3D):
	cache.clear()
	for key in data:
		var path = data[key]
		if path != "":
			var attack = load(path)
			if attack == null:
				push_error("Failed to load resource at path: " + path)
				return
			else:
				print(path)
			if attack is AttackData:
				var anim: Animation = char.animPlayer.get_animation(attack.animation_name)
				if anim:
					for i in range(attack.impactFrames.size()):
						var frameRatio = float(attack.impactFrames[i])/ float(attack.totalFrames) 
						var totalTime = anim.length
						hurtboxSet(char, attack, frameRatio, totalTime, i)
						if attack.slot != FFItemData.itemClass.SPECIAL:
							hitboxSet(char, attack, frameRatio, totalTime, i)
				cache[key] = attack
				
				print("cached: ", key, " → ", attack.item_name)
			else:
				push_error("Not an AttackData: " + path)

func hurtboxSet(char:CharacterBody3D,attack: MovementData, frameRatio: float, totalTime:float, i:int):
	attack.hitbox_snapshots.append(AttackData.HitboxSnapshot.new())
	
	
	char.build_attacker_hurtboxes(frameRatio*totalTime, attack.animation_name)
	attack.hitbox_snapshots[i].headCol_transform = char.headCol.transform
	attack.hitbox_snapshots[i].torsoCol_transform = char.torsoCol.transform
	attack.hitbox_snapshots[i].abdomenCol_transform = char.abdomenCol.transform
	attack.hitbox_snapshots[i].upperArm_L_Col_transform = char.upperArm_L_Col.transform
	attack.hitbox_snapshots[i].upperArm_R_Col_transform = char.upperArm_R_Col.transform
	attack.hitbox_snapshots[i].lowerArm_L_Col_transform = char.lowerArm_L_Col.transform
	attack.hitbox_snapshots[i].lowerArm_R_Col_transform = char.lowerArm_R_Col.transform
	attack.hitbox_snapshots[i].upperLeg_L_Col_transform = char.upperLeg_L_Col.transform
	attack.hitbox_snapshots[i].upperLeg_R_Col_transform = char.upperLeg_R_Col.transform
	attack.hitbox_snapshots[i].lowerLeg_L_Col_transform = char.lowerLeg_L_Col.transform
	attack.hitbox_snapshots[i].lowerLeg_R_Col_transform = char.lowerLeg_R_Col.transform

func hitboxSet(char:CharacterBody3D,attack: AttackData, frameRatio: float, totalTime:float, i:int):
	print("FAGGOT NAME",attack.animation_name)
	frameRatio = float(attack.attackStart[i])/ float(attack.totalFrames) 
	char.animPlayer.play(attack.animation_name)
	char.animPlayer.seek(frameRatio*totalTime, true)
	var transform_a = get_bone_transform(attack, char, i)
	
	frameRatio = float(attack.attackEnd[i])/ float(attack.totalFrames) 
	char.animPlayer.play(attack.animation_name)
	char.animPlayer.seek(frameRatio*totalTime, true)
	var transform_b = get_bone_transform(attack, char, i)
	char.position_bone(transform_a, transform_b, char.Main, attack.range[i], 1.0)
	attack.hitbox_snapshots[i].hitbox = char.Main.transform
	attack.hitbox_snapshots[i].hitbox_radius = char.Main.shape.radius
	attack.hitbox_snapshots[i].hitbox_height = char.Main.shape.height

func get_bone_transform(attack:AttackData, char:CharacterBody3D, limbNum:int):
	var transform: Transform3D
	match attack.attackLimb[limbNum]:
		AttackData.limb.arm_L:
			transform = char.get_bone_transform('wepon3.L')
		AttackData.limb.arm_R:
			transform = char.get_bone_transform('wepon3.R')
		AttackData.limb.leg_L:
			transform = char.get_bone_transform('foot.L')
		AttackData.limb.leg_R:
			transform = char.get_bone_transform('foot.R')
		AttackData.limb.back_TL:
			transform = char.get_bone_transform('back_Up_IK1.L')
		AttackData.limb.back_TR:
			transform = char.get_bone_transform('back_Up_IK1.R')
		AttackData.limb.back_BL:
			transform = char.get_bone_transform('back_Down_IK1.L')
		AttackData.limb.back_BR:
			transform = char.get_bone_transform('back_Down_IK1.R')
		AttackData.limb.knee_L:
			transform = char.get_bone_transform('lowerleg.R')
		AttackData.limb.knee_R:
			transform = char.get_bone_transform('lowerleg.R')
		AttackData.limb.elbow_L:
			transform = char.get_bone_transform('wepon1.L')
		AttackData.limb.elbow_R:
			transform = char.get_bone_transform('wepon1.R')
		_:
			transform = char.get_bone_transform('')
			
	return char.skeleton.global_transform * transform

func _zero_z(t: Transform3D) -> Transform3D:
	t.origin.z = 0.0
	return t

		
