# res://resources/attacks/AttackData.gd
class_name SpecialAttackData
extends MovementData

enum attackClass { SLASHER, HAMMER, REAPER, BOXER, SHOOTER, RAPID, JUMPER, THUMPER, RUNNER,  ARACHNID, BRAWLER, TURRET, WINGS, TENTACLES }
enum limb{arm_L, arm_R, leg_L, leg_R, back_TL, back_TR, back_BL, back_BR, knee_L, knee_R, elbow_L, elbow_R}
# Identity
@export var icon: Texture2D = null

# Unlock state — persisted via PlayerData
@export var is_unlocked: bool = false

# Gameplay data
@export var attack_class: attackClass
@export var hitstun_frames: int = 14
@export var blockstun_frames: int = 8
@export var knockback: float = 20
@export var is_launcher: bool = false          # pops opponent into the air
@export var animation_fps: float = 30.0

@export var speedAdd: int = 12
@export var range: Array[float] = [0.5]

@export var input: int
@export var nextCombo: Dictionary
@export var chainFrame: int

@export var startupFrames: int = 14
@export var attackStart: Array[int]
@export var attackEnd: Array[int]
@export var attackLimb: Array[limb]
@export var recoveryFrames: int = 14


# Visuals / audio
@export var hit_vfx: PackedScene = null
@export var hit_sfx: AudioStream = null
@export var attack_sfx: AudioStream = null     # whoosh/grunt on startup

# Stance / context restrictions
@export var required_stance: String = "any"    # "standing", "crouching", "airborne", "any"
@export var required_meter: float = 0.0        # for EX/super attacks


func get_res_path() -> String:
	return "res://resources/attacks/attackData/%s/%s/%s.tres" % [FFItemData.itemClass.keys()[slot],AttackData.attackClass.keys()[attack_class], item_id]
	
