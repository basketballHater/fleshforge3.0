extends Resource
class_name ProjectileData

@export var velocity: float
@export var lifetime: float
@export var attack_limb: AttackData.limb
@export var mesh: PackedScene
@export var radius: float
@export var height: float
@export var isHeavy: bool
@export var knockback: int
var localspawnLoc: Transform3D
