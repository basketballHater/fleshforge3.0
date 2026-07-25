# res://resources/attacks/AttackData.gd
class_name AttackData
extends MovementData

enum attackClass { SLASHER, HAMMER, REAPER, BOXER, SHOOTER, RAPID, JUMPER, THUMPER, RUNNER,  ARACHNID, BRAWLER, TURRET, WINGS, TENTACLES }
enum Type{ PHISYCAL, PROJECTILE, TELEPORT }
enum limb{arm_L, arm_R, leg_L, leg_R, back_TL, back_TR, back_BL, back_BR, knee_L, knee_R, elbow_L, elbow_R}
# Identity
@export var attackID: int = 0
@export var description: String = ""
@export var icon: Texture2D = null

# Unlock state — persisted via PlayerData
@export var is_unlocked: bool = false

# Gameplay data
@export var attack_class: attackClass
@export var knockback: float = 20
@export var is_launcher: bool = false          # pops opponent into the ai

@export var speedAdd: int = 12
@export var hop: float = 0
@export var range: Array[float] = [0.5]

@export var input: int
@export var nextCombo: Dictionary
@export var chainFrame: int

@export var attackStart: Array[int]
@export var attackEnd: Array[int]
@export var attackLimb: Array[limb]
@export var attackType: Array[Type] = [AttackData.Type.PHISYCAL]

@export var is_special: bool = false
@export var preliminary_input: int = 0


# Visuals / audio
@export var hit_vfx: PackedScene = null
@export var hit_sfx: AudioStream = null
@export var attack_sfx: AudioStream = null     # whoosh/grunt on startup

var impactTime: Array[float]
var comboTime: float
var projectileNum: int

@export var projectile_data: ProjectileData


func get_res_path() -> String:
	return "res://resources/attacks/attackData/%s/%s/%s.tres" % [FFItemData.itemClass.keys()[slot],AttackData.attackClass.keys()[attack_class], item_id]
	
