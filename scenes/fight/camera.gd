#extends Camera3D
#
#@export var move_speed := 10.0
#@export var sprint_speed := 30.0
#@export var mouse_sensitivity := 0.002
#
#var pitch := 0.0
#
#func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
#func _unhandled_input(event):
	#if event is InputEventMouseMotion:
		#rotate_y(-event.relative.x * mouse_sensitivity)
#
		#pitch -= event.relative.y * mouse_sensitivity
		#pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
#
		#rotation.x = pitch
#
	#if event.is_action_pressed("ui_cancel"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#
#func _process(delta):
	#var input_dir := Vector3.ZERO
	#
	#if Input.is_key_pressed(KEY_O):
		#size = size+1
		#
	#if Input.is_key_pressed(KEY_P):
		#size = size-1
#
	#if Input.is_key_pressed(KEY_UP):
		#input_dir -= transform.basis.z
#
	#if Input.is_key_pressed(KEY_DOWN):
		#input_dir += transform.basis.z
#
	#if Input.is_key_pressed(KEY_LEFT):
		#input_dir -= transform.basis.x
#
	#if Input.is_key_pressed(KEY_RIGHT):
		#input_dir += transform.basis.x
#
	#if Input.is_key_pressed(KEY_SPACE):
		#input_dir += transform.basis.y
#
	#if Input.is_key_pressed(KEY_CTRL):
		#input_dir -= transform.basis.y
#
	#var speed = move_speed
#
	#if Input.is_key_pressed(KEY_SHIFT):
		#speed = sprint_speed
#
	#if input_dir != Vector3.ZERO:
		#global_position += input_dir.normalized() * speed * delta
	#
	

extends Camera3D
@export var follow_speed: float = 5.0
func _ready():
	pass

func _process(delta):
	if Physics.characterDiff > 5.0:
		if(Physics.characterDiff < 7.5):
			size = (Physics.characterDiff*0.8*4)
	else:size = 16

	var desired_pos := global_position
	desired_pos.x = Physics.midP
	global_position = global_position.lerp(desired_pos, follow_speed * delta)
