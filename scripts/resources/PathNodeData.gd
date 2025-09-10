extends Resource
class_name PathNodeData

@export var pathnodeID:int = 0
@export var pathnode_name:String = "Pathnode"
@export var pathnode_links:Array[NodePath] = []

@export var pathnode_controller:NodePath = ""
@export var prev_pathnode:NodePath = ""
@export var area_owner:NodePath = ""
