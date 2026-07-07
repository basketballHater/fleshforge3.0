class_name FFBackData
extends FFItemData

enum BackClass { ARACHNID, BRAWLER, TURRET, WINGS, TENTACLES }
@export var back_class:  BackClass

# Single mesh for the head bone
@export var meshes: Array[Mesh] = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
