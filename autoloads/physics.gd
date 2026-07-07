extends Node

@export var gravity: float = 50
var friction: float = 0.3
var characterDiff: float = 0.0
var midP: float
var left: float


@export var debug_player_script: Script


#func spawn_debug_player2():
	## 1. Duplicate player1
	#var char2 := char1.duplicate(
		#Node.DUPLICATE_USE_INSTANTIATION
	#)
#
	## 2. Attach new script BEFORE adding to tree
	#char2.set_script(debug_player_script)
#
	## 3. Rename & reposition
	#char2.name = "char2"
	#char2.global_position = char1.global_position + Vector3(-3, 0, 0)
#
	## 4. Add to scene
	#add_child(char2)
