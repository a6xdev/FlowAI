@tool
extends Node3D
class_name FlowAIAreaNode

@export var ID:int = 0
@export var area_pathnodes:Array[int] = []
@export var flowAI_controller:FlowAIController = null

#region GODOT FUNCTIONS
func _ready() -> void:
	tree_exiting.connect(_on_node_tree_exiting)
#endregion

#region CALLS
#endregion

#region SIGNALS
func _on_node_tree_exiting():
	if flowAI_controller.all_areas.has(self):
		flowAI_controller.all_areas.erase(self)
		print("area removed")
#endregion
