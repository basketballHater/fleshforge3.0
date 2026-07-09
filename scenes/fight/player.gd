extends CharacterBody3D
class_name female_rapid

# ─── Exported Config ────────────────────────────────────────────────────────
@export var playerNum: int
@export var speed:float
@export var jump_force := 30.0
var opponent: int

# ─── Movement State ─────────────────────────────────────────────────────────
var direction := 0.0
var facing: int
var target_rot_y: float
var onfloor := false
var crouching := false
var attacking := false
var blocking := false
var special := false
var attack: int
var momentum: float = 0.0
var speedFactor: float
var speedAdd: float
var specialCount := 0

# ─── Input Action Names ─────────────────────────────────────────────────────
var left: String
var right: String
var jump: String
var crouch: String
var circle: String
var triangle: String
var square: String
var X: String
var L1: String
var L2: String
var R1: String
var R2: String

# ─── Input State ────────────────────────────────────────────────────────────
var leftPressed := false
var rightPressed := false
var forwardPressed := false
var backwardPressed := false
var jumpPressed := false
var crouchPressed := false
var circlePressed := false
var trianglePressed := false
var squarePressed := false
var XPressed := false
var L1Pressed := false
var L2Pressed := false
var R1Pressed := false
var R2Pressed := false

const BUFFER_SIZE = 5  # remember last 30 frames (~0.5 seconds at 60fps)
var input_history: Array[int] = []
var  curr_input: int
# ─── Misc ────────────────────────────────────────────────────────────────────
var attack_cache: Dictionary = {}
var special_cache: Dictionary = {}
var combo_cache: Dictionary = {}
var movement_cache: Dictionary = {}
var current_attack: AttackData = null
@onready var animPlayer: AnimationPlayer
var impact_triggered: Array[bool] = []
var ifImpact: bool = false
var hitBody: bool = false
var hitMachine: bool = false
var parry: bool = false
var waitingCol: bool = false
var comboLate: bool = false 
var startedMoving: bool = false
var specialAttackSet: bool = false

var debug:String
var debug1:String

var A:Transform3D
var B:Transform3D

@onready var skeleton: Skeleton3D

@onready var headCol = $HurtboxBody/head
@onready var torsoCol = $HurtboxBody/torso
@onready var abdomenCol = $HurtboxBody/abdomen
@onready var upperArm_L_Col = $HurtboxBody/upperArm_L
@onready var upperArm_R_Col = $HurtboxBody/upperArm_R
@onready var lowerArm_L_Col = $HurtboxMachine/lowerArm_L
@onready var lowerArm_R_Col = $HurtboxMachine/lowerArm_R
@onready var upperLeg_L_Col = $HurtboxBody/upperLeg_L
@onready var upperLeg_R_Col = $HurtboxBody/upperLeg_R
@onready var lowerLeg_L_Col = $HurtboxMachine/lowerLeg_L
@onready var lowerLeg_R_Col = $HurtboxMachine/lowerLeg_R
@onready var Main = $Hitbox/Main

var hurtboxBody: Area3D
var hurtboxMachine: Area3D
var hitbox: Area3D

var current_anim: String = ""
var walkingAnimF:String = ""
var walkingAnimB:String = ""

# ════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ════════════════════════════════════════════════════════════════════════════
enum State {
	IDLE,
	WALK_FORWARD,
	WALK_BACKWARD,
	CROUCH_TRANS,          # crouchStart clip   : IDLE <-> CROUCH_IDLE
	CROUCH_TRANS_R,
	CROUCH_IDLE,
	BLOCK_TRANS,    
	BLOCK_TRANS_R,       # blockStart clip     : IDLE <-> BLOCK_IDLE
	BLOCK_IDLE,
	CROUCH_BLOCK_TRANS1,   # crouchBlock1 clip   : CROUCH_IDLE <-> CROUCH_BLOCK_IDLE (block axis)
	CROUCH_BLOCK_TRANS1_R, 
	CROUCH_BLOCK_TRANS2,   # crouchBlock2 clip   : BLOCK_IDLE  <-> CROUCH_BLOCK_IDLE (crouch axis)
	CROUCH_BLOCK_TRANS2_R, 
	CROUCH_BLOCK_IDLE,
	JUMP_RISE,
	JUMP_FALL,
}
 
# Describes each reversible transition: which clip plays it, and what state
# lies on each end (base = idle-ish start, target = idle-ish end after finishing forward).
const TRANSITIONS := {
	State.CROUCH_TRANS: {"clip": "crouch", "base": State.IDLE, "target": State.CROUCH_IDLE, "direction": 1},
	State.CROUCH_TRANS_R: {"clip": "crouch", "base": State.CROUCH_IDLE, "target": State.IDLE, "direction": -1},
	State.BLOCK_TRANS: {"clip": "block", "base": State.IDLE, "target": State.BLOCK_IDLE, "direction": 1},
	State.BLOCK_TRANS_R: {"clip": "block", "base": State.BLOCK_IDLE, "target": State.IDLE, "direction": -1},
	State.CROUCH_BLOCK_TRANS1: {"clip": "crouchBlock1", "base": State.CROUCH_IDLE, "target": State.CROUCH_BLOCK_IDLE, "direction": 1},
	State.CROUCH_BLOCK_TRANS1_R: {"clip": "crouchBlock1", "base": State.CROUCH_BLOCK_IDLE, "target": State.CROUCH_IDLE, "direction": -1},
	State.CROUCH_BLOCK_TRANS2: {"clip": "crouchBlock2", "base": State.BLOCK_IDLE, "target": State.CROUCH_BLOCK_IDLE, "direction": 1},
	State.CROUCH_BLOCK_TRANS2_R: {"clip": "crouchBlock2", "base": State.CROUCH_BLOCK_IDLE, "target": State.BLOCK_IDLE, "direction": -1},
}
 
var current_state: State = State.IDLE
var transition_direction := 1  # 1 = playing toward target, -1 = playing back toward base
 
# Placeholder input state — wire these to your real input system.



func _ready() -> void:
	setup()
	#print_tree_pretty()
	_setup_input_actions()
	#print(playerNum, " animPlayer: ", animPlayer)
	
	#print("global transform", headCol,global_transform)
	#print("transform", headCol,transform)
	
	

# in character script
func setup() -> void:
	if playerNum == 1:
		opponent = 2
	else:
		opponent = 1
	animPlayer = find_child("AnimationPlayer")
	skeleton = find_child("Skeleton3D")
	hurtboxBody = get_node("HurtboxBody")
	hurtboxMachine = get_node("HurtboxMachine")
	hitbox = get_node("Hitbox")
	hurtboxBody.collision_layer = playerNum
	hurtboxMachine.collision_layer = playerNum
	hitbox.collision_layer = playerNum
	hurtboxBody.collision_mask = opponent
	hurtboxMachine.collision_mask = opponent
	hitbox.collision_mask = opponent
	hurtboxBody.monitoring = false
	hurtboxMachine.monitoring = false
	hurtboxBody.monitorable = false
	hurtboxMachine.monitorable = false
	#hitbox.monitorable = true
	#print(playerNum,"SETUP CALLED")
	#print(name, " setup — animPlayer: ", animPlayer, " skeleton: ", skeleton)
	# all your other @onready assignments here
	
	hurtboxBody.area_entered.connect(_on_Bodyhit)
	hurtboxMachine.area_entered.connect(_on_MachineHit)
	
	animPlayer.animation_finished.connect(_on_animation_finished)
	_enter_state(State.IDLE)
	

func _physics_process(delta: float) -> void:
	speedFactor = 1
	var start = Time.get_ticks_usec()
	getInput()
	inputHistory()
	_update_facing(delta)
	_update_movement()
	
	handleAnimation()
	
	_apply_gravity(delta)
	handle_jump()
	#handle_Animation()
	

	velocity.x = direction * speed * speedFactor + speedAdd * facing + momentum
	#print('vhhggbbg',speed)

	handleCollision()
	move_and_slide()
	var end = Time.get_ticks_usec()
	#print("player ",playerNum," if GAYSEX ", (end - start) / 1000.0, " ms")

	
	# animation fps

func handleAnimation():

	if attacking or waitingCol or hitBody:
		return
 
	if not onfloor:
		_handle_jump()
	else:
		_handle_grounded_transitions()

func _on_Bodyhit(area: Area3D) -> void:
	hitBody = true;
	#print(playerNum,"hit detected with: ", area,global_position.x)

func _on_MachineHit(area: Area3D) -> void:
	hitMachine = true;
	#print(playerNum,"hit detected with: ", area,global_position.x)

func handleAttack() -> void:
	if attacking:
		
		var currImpactTime = animPlayer.get_current_animation_position()
		#var lookahead = 1.0 / 60.0  # one physics tick ahead
		var totalTime = animPlayer.get_current_animation_length()
		var timeRatio = currImpactTime / totalTime
		
		for i in current_attack.impactFrames.size():
			var frameRaio = float(current_attack.impactFrames[i])/ float(current_attack.totalFrames) 
			if not impact_triggered[i] and frameRaio < timeRatio:
				impact_triggered[i] = true
				headCol.transform = current_attack.hitbox_snapshots[i].headCol_transform
				torsoCol.transform = current_attack.hitbox_snapshots[i].torsoCol_transform
				abdomenCol.transform = current_attack.hitbox_snapshots[i].abdomenCol_transform
				upperArm_L_Col.transform = current_attack.hitbox_snapshots[i].upperArm_L_Col_transform
				upperArm_R_Col.transform = current_attack.hitbox_snapshots[i].upperArm_R_Col_transform
				lowerArm_L_Col.transform = current_attack.hitbox_snapshots[i].lowerArm_L_Col_transform
				lowerArm_R_Col.transform = current_attack.hitbox_snapshots[i].lowerArm_R_Col_transform
				upperLeg_L_Col.transform = current_attack.hitbox_snapshots[i].upperLeg_L_Col_transform
				upperLeg_R_Col.transform = current_attack.hitbox_snapshots[i].upperLeg_R_Col_transform
				lowerLeg_L_Col.transform = current_attack.hitbox_snapshots[i].lowerLeg_L_Col_transform
				lowerLeg_R_Col.transform = current_attack.hitbox_snapshots[i].lowerLeg_R_Col_transform
				Main.transform = current_attack.hitbox_snapshots[i].hitbox
				Main.shape.radius = current_attack.hitbox_snapshots[i].hitbox_radius
				Main.shape.height = current_attack.hitbox_snapshots[i].hitbox_height
				ifImpact = true
		for key in current_attack.nextCombo:
			var comboframeRatio = float(current_attack.chainFrame)/ float(current_attack.totalFrames)
			if !comboLate and comboframeRatio < timeRatio:
				for i in range(input_history.size() - 1, -1, -1):
					if input_history[i] == key:
						var curr_attack = current_attack.nextCombo[key]
						animPlayer.play(curr_attack.animation_name)
						current_attack = curr_attack
						impact_triggered = []
						impact_triggered.resize(curr_attack.impactFrames.size())
						impact_triggered.fill(false)
						return
					if input_history[i] == current_attack.input:
						comboLate= true
						break
		if timeRatio >= 1:
			attacking = false
			comboLate = false
		speedAdd = current_attack.speedAdd
		velocity.y = velocity.y + current_attack.hop
	else:
		speedAdd = 0
		#Special Move handler
		if input_history.size() > BUFFER_SIZE - 3:
			var first_key = input_history[BUFFER_SIZE - 3]
			var second_dict = special_cache.get(first_key)

			if second_dict:
				var attack = second_dict.get(curr_input)

				if attack:
					animPlayer.play(attack.animation_name)
					current_attack = attack
					attacking = true

					impact_triggered.resize(attack.impactFrames.size())
					impact_triggered.fill(false)

					return
		var curr_attack = attack_cache.get(curr_input)
		if curr_attack != null:
			if curr_attack.hop != 0:
				if velocity.y > 10 or velocity.y < 0:
					return

			animPlayer.play(curr_attack.animation_name)
			current_attack = curr_attack
			attacking = true

			impact_triggered.resize(curr_attack.impactFrames.size())
			impact_triggered.fill(false)

			return
			

	if input_history.size() == 0:
		return
	
	if L1Pressed:
		animPlayer.speed_scale = 1.0

func handleDefence():
	var anim_name = animPlayer.current_animation
	#print("GAYSEX", anim_name)
	if "_" in anim_name:
		return
	if anim_name == '':
		anim_name = 'idle'
	headCol.transform = movement_cache[anim_name].hitbox_snapshots[0].headCol_transform
	torsoCol.transform = movement_cache[anim_name].hitbox_snapshots[0].torsoCol_transform
	abdomenCol.transform = movement_cache[anim_name].hitbox_snapshots[0].abdomenCol_transform
	upperArm_L_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].upperArm_L_Col_transform
	upperArm_R_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].upperArm_R_Col_transform
	lowerArm_L_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].lowerArm_L_Col_transform
	lowerArm_R_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].lowerArm_R_Col_transform
	upperLeg_L_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].upperLeg_L_Col_transform
	upperLeg_R_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].upperLeg_R_Col_transform
	lowerLeg_L_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].lowerLeg_L_Col_transform
	lowerLeg_R_Col.transform = movement_cache[anim_name].hitbox_snapshots[0].lowerLeg_R_Col_transform

func get_bone_transform(bone_name: String) -> Transform3D:
	var bone_idx = skeleton.find_bone(bone_name)
	return skeleton.get_bone_global_pose(bone_idx)

func debugHbox():
	var anim: Animation = animPlayer.get_animation(current_attack.animation_name)
	var frameRatio = float(current_attack.attackStart[0])/ float(current_attack.totalFrames) 
	animPlayer.play(current_attack.animation_name)
	var totalTime = anim.length
	animPlayer.seek(frameRatio*totalTime, true)
	var transform_a = get_bone_transformX(current_attack)
	A = transform_a
	
	frameRatio = float(current_attack.attackEnd[0])/ float(current_attack.totalFrames) 
	animPlayer.play(current_attack.animation_name)
	animPlayer.seek(frameRatio*totalTime, true)
	var transform_b = get_bone_transformX(current_attack)
	B = transform_b

func get_bone_transformX(attack:AttackData):
	var transform: Transform3D
	match attack.attackLimb[0]:
		AttackData.limb.arm_L:
			transform = get_bone_transform('wepon3.L')
		AttackData.limb.arm_R:
			transform = get_bone_transform('wepon3.R')
		AttackData.limb.leg_L:
			transform = get_bone_transform('foot.L')
		AttackData.limb.leg_R:
			transform = get_bone_transform('foot.R')
		AttackData.limb.back_TL:
			transform = get_bone_transform('')
		AttackData.limb.back_TR:
			transform = get_bone_transform('')
		AttackData.limb.back_BL:
			transform = get_bone_transform('')
		AttackData.limb.back_BR:
			transform = get_bone_transform('')
		_:
			transform = get_bone_transform('')
			
	return transform * skeleton.global_transform

func build_box(bone_a: String, bone_b: String, col: CollisionShape3D, radius: float, length: float) -> void:
	if skeleton == null:
		return
	if col == null:
		return
	var transform_a: Transform3D = skeleton.global_transform * get_bone_transform(bone_a)
	var transform_b: Transform3D = skeleton.global_transform * get_bone_transform(bone_b)
	
	position_bone(transform_a, transform_b, col, radius, length)
	
	

func position_bone(transform_a:Transform3D, transform_b:Transform3D, col: CollisionShape3D, radius: float, length: float):
	var pos_a := Vector3(transform_a.origin.x, transform_a.origin.y, 0.0)
	var pos_b := Vector3(transform_b.origin.x, transform_b.origin.y, 0.0)
	
	var midpoint := (pos_a + pos_b) / 2.0
	var diff := pos_b - pos_a
	var distance := diff.length()
	
	if col.shape is CapsuleShape3D:
		col.shape = col.shape.duplicate()
		var capsule := col.shape as CapsuleShape3D
		capsule.radius = radius
		# height must be at least diameter
		capsule.height = maxf(distance*length, radius * 2.0)
	
	var up := diff.normalized()
	var forward := Vector3(0, 0, 1)
	var right := forward.cross(up).normalized()
	var basis := Basis(right, up, forward)
	
	col.global_transform = Transform3D(basis, midpoint)


func build_attacker_hurtboxes(impactTime:float, animation_name:String) -> void:
	#var impact_time = animPlayer.current_animation_position  # save current time
	 #seek to exact impact frame to sample bone positions
	animPlayer.play(animation_name)
	animPlayer.seek(impactTime, true)
	build_hurttboxes()
	#animPlayer.seek(currImpactTime, true)
	# restore animation position
	#animPlayer.seek(impact_time, true)

func build_hurttboxes():
	#print("fagg")
	build_box("neck","head", headCol, 0.6, 5)
	build_box("torse1","neck", torsoCol, 0.7, 1)
	build_box("torso3","torse1", abdomenCol, 0.5, 1)
	build_box("upperArm.L","weponFit.L", upperArm_L_Col, 0.2, 2)
	build_box("upperArm.R","weponFit.R", upperArm_R_Col, 0.2, 2)
	build_box("wepon2.L","wepon3.L", lowerArm_L_Col, 0.2, 2)
	build_box("wepon2.R","wepon3.R", lowerArm_R_Col, 0.2, 2)
	build_box("upperleg.L","lowerleg.L", upperLeg_L_Col, 0.6, 1.2)
	build_box("upperleg.R", "lowerleg.R", upperLeg_R_Col, 0.6, 1.2)
	build_box("lowerleg.L", "foot.L",lowerLeg_L_Col, 0.4, 1.2)
	build_box("lowerleg.R", "foot.R", lowerLeg_R_Col, 0.4, 1.2)

func inputHistory():
	var mask = get_held_mask()
	curr_input = mask
	if mask != 0 and mask != input_history.back():
		input_history.append(mask)
	if input_history.size() > BUFFER_SIZE:
		input_history.pop_front()
	

func get_held_mask() -> int:
	var mask = 0

	if jumpPressed:    mask |= InputDefs.UPmask
	if crouchPressed:  mask |= InputDefs.DOWNmask
	if forwardPressed:  mask |= InputDefs.FORWARDmask
	if backwardPressed: mask |= InputDefs.BACKmask
	if circlePressed:   mask |= InputDefs.CIRCLEmask
	if trianglePressed:   mask |= InputDefs.TRIANGLEmask
	if squarePressed:   mask |= InputDefs.SQUAREmask
	if XPressed:   mask |= InputDefs.Xmask
	if R1Pressed:   mask |= InputDefs.R1mask
	if R2Pressed:   mask |= InputDefs.R2mask
	if L1Pressed:   mask |= InputDefs.L1mask
	if L2Pressed:   mask |= InputDefs.L2mask
	if !onfloor:    mask |= InputDefs.JUMPmask
	# etc.
	return mask

# ════════════════════════════════════════════════════════════════════════════
# Setup
# ════════════════════════════════════════════════════════════════════════════

func _setup_input_actions() -> void:
	left     = "p%d_left"       % playerNum
	right    = "p%d_right"      % playerNum
	jump     = "p%d_up"         % playerNum
	crouch   = "p%d_down"       % playerNum
	circle   = "char%d_Circle"  % playerNum
	triangle = "char%d_Triangle"% playerNum
	square   = "char%d_Square"  % playerNum
	X        = "char%d_X"       % playerNum
	L1       = "char%d_L1"      % playerNum
	L2       = "char%d_L2"      % playerNum
	R1       = "char%d_R1"      % playerNum
	R2       = "char%d_R2"      % playerNum


# ════════════════════════════════════════════════════════════════════════════
# Input
# ════════════════════════════════════════════════════════════════════════════

func getInput() -> void:
	leftPressed     = Input.is_action_pressed(left)
	rightPressed    = Input.is_action_pressed(right)
	jumpPressed     = Input.is_action_pressed(jump)
	crouchPressed   = Input.is_action_pressed(crouch)
	circlePressed   = Input.is_action_pressed(circle)
	trianglePressed = Input.is_action_pressed(triangle)
	squarePressed   = Input.is_action_pressed(square)
	XPressed        = Input.is_action_pressed(X)
	R1Pressed       = Input.is_action_pressed(R1)
	R2Pressed       = Input.is_action_pressed(R2)
	L1Pressed       = Input.is_action_pressed(L1)
	L2Pressed       = Input.is_action_pressed(L2)

	_update_directional_intent()
	#_debug_print_buttons()


func _update_directional_intent() -> void:
	var is_left_side := Physics.left == playerNum

	if leftPressed:
		forwardPressed  = not is_left_side
		backwardPressed = is_left_side
	elif rightPressed:
		forwardPressed  = is_left_side
		backwardPressed = not is_left_side
	else:
		forwardPressed  = false
		backwardPressed = false


func _debug_print_buttons() -> void:
	if circlePressed:   print("circlePressed is ON")
	if trianglePressed: print("trianglePressed is ON")
	if squarePressed:   print("squarePressed is ON")
	if XPressed:        print("XPressed is ON")


# ════════════════════════════════════════════════════════════════════════════
# Physics helpers
# ════════════════════════════════════════════════════════════════════════════

func _update_facing(delta: float) -> void:
	var new_facing: int
	var new_z: float
	if Physics.left == playerNum:
		target_rot_y = deg_to_rad(90)
		new_z = -0.2
		new_facing = 1
	else:
		target_rot_y = deg_to_rad(270)
		new_z = 0.2
		new_facing = -1

	if new_facing != facing:
		facing = new_facing
		position.z = new_z  # only touch the transform on an actual side-swap

	#rotation.y = lerp_angle(rotation.y, target_rot_y, 8.0 * delta)
	rotation.y = target_rot_y


func _update_movement() -> void:
	direction = 0.0
	
	if crouchPressed or R1Pressed or attacking:
		return

	if leftPressed:
		direction -= 1.0
	elif rightPressed:
		direction += 1.0

	if not onfloor:
		speedFactor = 3


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		onfloor    = false
		velocity.y = velocity.y - Physics.gravity * delta
	else:
		var was_airborne = not onfloor
		onfloor    = true
		velocity.y = 0.0
		_decay_momentum()
		if was_airborne:
			_enter_state(State.IDLE)

func _decay_momentum() -> void:
	if momentum > 0:
		momentum = max(momentum - Physics.friction, 0.0)
	elif momentum < 0:
		momentum = min(momentum + Physics.friction, 0.0)


func handle_jump() -> void:
	if jumpPressed and onfloor and not crouching:
		velocity.y = jump_force

# ════════════════════════════════════════════════════════════════════════════
# Collision
# ════════════════════════════════════════════════════════════════════════════

func handleCollision() -> void:
	if Physics.characterDiff >= 1.5 or not onfloor:
		return

	if forwardPressed:
		velocity.x = 0
	elif Physics.left == playerNum:
		if velocity.x > 0:
			velocity.x = Physics.characterDiff - 1
	else:
		if velocity.x < 0:
			velocity.x = 1 - Physics.characterDiff


#func _handle_grounded_transitions() -> void:
	#match current_state:
		#State.IDLE:
			#if crouchPressed:
				#_start_transition(State.CROUCH_TRANS)
			#elif R1Pressed:
				#_start_transition(State.BLOCK_TRANS)
			#elif forwardPressed:
				#_enter_state(State.WALK_FORWARD)
			#elif backwardPressed:
				#_enter_state(State.WALK_BACKWARD)
 #
		#State.WALK_FORWARD:
			#if crouchPressed:
				#_start_transition(State.CROUCH_TRANS)
			#elif R1Pressed:
				#_start_transition(State.BLOCK_TRANS)
			#elif not forwardPressed:
				#_enter_state(State.IDLE)
 #
		#State.WALK_BACKWARD:
			#if crouchPressed:
				#_start_transition(State.CROUCH_TRANS)
			#elif R1Pressed:
				#_start_transition(State.BLOCK_TRANS)
			#elif not backwardPressed:
				#_enter_state(State.IDLE)
 #
		## --- crouch ---
		#State.CROUCH_TRANS:
#
			#if crouchPressed:
				#print('LESBIAN JARGON')
				#_start_transition(State.CROUCH_TRANS)
		#State.CROUCH_TRANS_R:
			#if not crouchPressed:
				#_start_transition(State.CROUCH_TRANS_R)
 #
		#State.CROUCH_IDLE:
			#if not crouchPressed:
				#crouching = false
				#_start_transition(State.CROUCH_TRANS_R)
			#elif R1Pressed:
				#_start_transition(State.CROUCH_BLOCK_TRANS1)
 #
		## --- block ---
		#State.BLOCK_TRANS:
			#if not R1Pressed:
				#blocking = false
				#_start_transition(State.BLOCK_TRANS)
			#elif R1Pressed:
				#_start_transition(State.BLOCK_TRANS)
		#
		#State.BLOCK_TRANS_R:
			#if not R1Pressed:
				#_start_transition(State.BLOCK_TRANS_R)
 #
		#State.BLOCK_IDLE:
			#if not R1Pressed:
				#blocking = false
				#_start_transition(State.BLOCK_TRANS_R)
			#elif crouchPressed:
				#_start_transition(State.CROUCH_BLOCK_TRANS2)
 #
		## --- crouch+block combined ---
		#State.CROUCH_BLOCK_TRANS1:
			#if not R1Pressed:
				#blocking = false
				#_start_transition(State.CROUCH_BLOCK_TRANS1)
			#elif R1Pressed:
				#_start_transition(State.CROUCH_BLOCK_TRANS1)
 #
		#State.CROUCH_BLOCK_TRANS2:
			#if not crouchPressed:
				#crouching = false
				#_start_transition(State.CROUCH_BLOCK_TRANS2)
			#elif crouchPressed:
				#_start_transition(State.CROUCH_BLOCK_TRANS2)
 #
		#State.CROUCH_BLOCK_IDLE:
			#if not R1Pressed:
				#blocking = false
				#_start_transition(State.CROUCH_BLOCK_TRANS1)   # -> crouchIdle
			#elif not crouchPressed:
				#crouching = false
				#_start_transition(State.CROUCH_BLOCK_TRANS2)   # -> blockIdle

func _handle_grounded_transitions() -> void:
	match current_state:
		State.IDLE:
			if crouchPressed:
				_start_transition(State.CROUCH_TRANS, 1)
			elif R1Pressed:
				_start_transition(State.BLOCK_TRANS, 1)
			elif forwardPressed:
				_enter_state(State.WALK_FORWARD)
			elif backwardPressed:
				_enter_state(State.WALK_BACKWARD)
 
		State.WALK_FORWARD:
			if crouchPressed:
				_start_transition(State.CROUCH_TRANS, 1)
			elif R1Pressed:
				_start_transition(State.BLOCK_TRANS, 1)
			elif not forwardPressed:
				_enter_state(State.IDLE)
 
		State.WALK_BACKWARD:
			if crouchPressed:
				_start_transition(State.CROUCH_TRANS, 1)
			elif R1Pressed:
				_start_transition(State.BLOCK_TRANS, 1)
			elif not backwardPressed:
				_enter_state(State.IDLE)
 
		# --- crouch ---
		State.CROUCH_TRANS:
			if transition_direction == 1 and not crouchPressed:
				crouching = false
				_start_transition(State.CROUCH_TRANS, 1)
			elif transition_direction == 1 and crouchPressed:
				_start_transition(State.CROUCH_TRANS, 1)
				
		State.CROUCH_TRANS_R:
			if not crouchPressed:
				_start_transition(State.CROUCH_TRANS_R, 1)
 
		State.CROUCH_IDLE:
			if not crouchPressed:
				crouching = false
				_start_transition(State.CROUCH_TRANS_R, 1)
			elif R1Pressed:
				_start_transition(State.CROUCH_BLOCK_TRANS1, 1)
		
		State.BLOCK_TRANS_R:
			if not R1Pressed:
				_start_transition(State.BLOCK_TRANS_R, 1)
 
		# --- block ---
		State.BLOCK_TRANS:
			if transition_direction == 1 and not R1Pressed:
				blocking = false
				_start_transition(State.BLOCK_TRANS, 1)
			elif transition_direction == 1 and R1Pressed:
				_start_transition(State.BLOCK_TRANS, 1)
 
		State.BLOCK_IDLE:
			if not R1Pressed:
				blocking = false
				_start_transition(State.BLOCK_TRANS_R, 1)
			elif crouchPressed:
				_start_transition(State.CROUCH_BLOCK_TRANS2, 1)
 
		# --- crouch+block combined ---
		State.CROUCH_BLOCK_TRANS1:
			if transition_direction == 1 and not R1Pressed:
				blocking = false
				_start_transition(State.CROUCH_BLOCK_TRANS1, 1)
			elif transition_direction == 1 and R1Pressed:
				_start_transition(State.CROUCH_BLOCK_TRANS1, 1)
 
		State.CROUCH_BLOCK_TRANS2:
			if transition_direction == 1 and not crouchPressed:
				crouching = false
				_start_transition(State.CROUCH_BLOCK_TRANS2, 1)
			elif transition_direction == 1 and crouchPressed:
				_start_transition(State.CROUCH_BLOCK_TRANS2, 1)
		
		State.CROUCH_BLOCK_TRANS1_R:
			if not R1Pressed:
				_start_transition(State.CROUCH_BLOCK_TRANS1_R, 1)
		
		State.CROUCH_BLOCK_TRANS2_R:
			if not crouchPressed:
				_start_transition(State.CROUCH_BLOCK_TRANS2_R, 1)
 
		State.CROUCH_BLOCK_IDLE:
			if not R1Pressed:
				blocking = false
				_start_transition(State.CROUCH_BLOCK_TRANS1_R, 1)   # -> crouchIdle
			elif not crouchPressed:
				crouching = false
				_start_transition(State.CROUCH_BLOCK_TRANS2_R, 1)   # -> blockIdle
 
 
# ---------------------------------------------------------------------------
# JUMP HANDLING (continuous, velocity-driven rather than discrete toggle)
# ---------------------------------------------------------------------------
 
func _handle_jump() -> void:
	if velocity.y > 0:
		if current_state != State.JUMP_RISE:
			current_state = State.JUMP_RISE
			animPlayer.speed_scale = 1.0
			animPlayer.play("jump")
	else:
		if current_state != State.JUMP_FALL:
			current_state = State.JUMP_FALL
			if animPlayer.current_animation == "jump":
				animPlayer.speed_scale = -1.0
			else:
				animPlayer.play("jump", -1, -1.0, true)  # from_end = true
 
 
# ---------------------------------------------------------------------------
# CORE TRANSITION MECHANICS
# ---------------------------------------------------------------------------
 
# Starts (or resumes) a reversible transition clip in the given direction.
# direction = 1  -> play forward toward "target"
# direction = -1 -> play backward toward "base", resuming from wherever
#                    the clip currently is (handles mid-transition interrupts)
#func _start_transition(state: State) -> void:
	#current_state = state
	#var clip: String = TRANSITIONS[state]["clip"]
	#var dir: int = TRANSITIONS[state]["direction"]
	#print("starting transition",state,direction,clip,animPlayer.current_animation)
 #
	#if animPlayer.current_animation == clip:
		## Already mid-clip: just flip playback direction from current position.
		#animPlayer.speed_scale = direction
	#else:
		## Not currently playing this clip: start fresh from the correct end.
		#if dir == 1:
			#animPlayer.speed_scale = 1.0
			#animPlayer.play(clip)
		#else:
			#animPlayer.speed_scale = -1.0
			#animPlayer.play(clip, -1, -1.0, true)  # from_end = true

func _start_transition(state: State, direction: int) -> void:
	current_state = state
	#transition_direction = direction
	var clip: String = TRANSITIONS[state]["clip"]
	var dir: int = TRANSITIONS[state]["direction"]
 
	if animPlayer.current_animation == clip:
		# Already mid-clip: just flip playback direction from current position.
		animPlayer.speed_scale = 1.0
	else:
		# Not currently playing this clip: start fresh from the correct end.
		if dir == 1:
			animPlayer.speed_scale = 1.0
			animPlayer.play(clip)
		else:
			animPlayer.speed_scale = -1.0
			animPlayer.play(clip, -1, -1.0, true)  # from_end = true
 
 
func _on_animation_finished(anim_name: String) -> void:
	#print('FINISHED YOU MOM: ',anim_name, transition_direction)
	if TRANSITIONS.has(current_state) and TRANSITIONS[current_state]["clip"] == anim_name:
		var info = TRANSITIONS[current_state]
		_enter_state(info["target"])
 
 
# Lands the state machine in a stable (non-transitional) state and plays
# its idle/loop clip. This is also where "reached idle -> flag = true" lives.
func _enter_state(state: State) -> void:
	current_state = state
	match state:
		State.IDLE:
			animPlayer.speed_scale = 1.0
			animPlayer.play("idle")
		State.WALK_FORWARD:
			animPlayer.speed_scale = 1.0
			animPlayer.play(walkingAnimF)
		State.WALK_BACKWARD:
			animPlayer.speed_scale = 1.0
			animPlayer.play(walkingAnimB)
		State.CROUCH_IDLE:
			crouching = true
			animPlayer.speed_scale = 1.0
			animPlayer.play("crouchIdle")
		State.BLOCK_IDLE:
			blocking = true
			animPlayer.speed_scale = 1.0
			animPlayer.play("blockIdle")
		State.CROUCH_BLOCK_IDLE:
			crouching = true
			blocking = true
			animPlayer.speed_scale = 1.0
			animPlayer.play("crouchBlockIdle")

# ════════════════════════════════════════════════════════════════════════════
# Attack state
# ════════════════════════════════════════════════════════════════════════════

# Maps animation state names to (speedAdd, speedFactor).
# speedFactor = -1 means "leave it as-is" (no override needed).
