extends Resource
class_name PathNodeData

@export var active:bool = true

@export var ID:int = 0
@export var areaID:int = 0
@export var prev_pathnode:int = 0
@export var links:Array[int] = []

@export var flowAI_controller:NodePath = ""
