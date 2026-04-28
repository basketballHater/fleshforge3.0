class_name FFLegData
extends FFItemData

# 4 mesh pieces in order: [lowerleg, foot, toe, extension2]
# Applies to BOTH legs simultaneously (mirrored)
# Leave an index null if that bone has no mesh for this attachment
@export var meshes: Array[Mesh] = [null, null, null, null]
