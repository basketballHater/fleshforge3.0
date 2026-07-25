# Projectile.gd — extends Area3D
extends Area3D
class_name Projectile

var velocity: float
var lifetime: float
var currLifetime: float
var owner_player: int
var data: ProjectileData
var localspawnLoc: Transform3D

func setup(pdata: ProjectileData, owner: int) -> void:
	localspawnLoc = pdata.localspawnLoc
	velocity = pdata.velocity
	data = pdata
	lifetime = pdata.lifetime
	owner_player = owner

	var shape := $CollisionShape3D
	shape.shape = CapsuleShape3D.new()
	shape.shape.radius = pdata.radius
	shape.shape.height = pdata.height

	collision_layer = 0
	collision_mask = 0
	#set_collision_layer_value(2 + owner_player, true)
	#set_collision_mask_value(5 - owner_player, true)
	#set_collision_layer_value(owner_player, true)
	set_collision_mask_value(3 - owner_player, true)
	print("Proj charac ",owner_player,"coll layer ",collision_layer,"coll mask ",collision_mask)

	area_entered.connect(_on_hit)
	halt()

func launch(charTransform: Transform3D):
	monitoring = true
	monitorable = true
	transform = charTransform * localspawnLoc 
	transform.origin.z = 0
	currLifetime = lifetime
	rotation.y = deg_to_rad(180)
	set_physics_process(true)
	visible = true
	
func _physics_process(delta: float) -> void:
	if Physics.left == owner_player:
		global_position.x += velocity * delta
	else:
		global_position.x -= velocity * delta
	currLifetime -= delta
	if currLifetime <= 0:
		halt()

func halt():
	monitoring = false
	monitorable = false
	position.x = -50.0
	set_physics_process(false)
	visible = false

func _on_hit(area: Area3D) -> void:
	var char:CharacterBody3D = area.get_parent()
	print("GOT WEBBBED")
	char.waitingCol = true
	char.hitBody = true
	#if data.hit_vfx_scene:
		#var vfx := data.hit_vfx_scene.instantiate()
		#get_tree().current_scene.add_child(vfx)
		#vfx.global_position = global_position
	halt()
