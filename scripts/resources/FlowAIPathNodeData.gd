extends Resource
class_name FlowAIPathNodeData

@export var p_id:String = ""
@export var p_astar_id:int = 0
@export var p_area_id:int = 0
@export var p_prev_pathnode:String = ""
@export var p_links:Array = []

func _init():
	if p_links == null:
		p_links = []
