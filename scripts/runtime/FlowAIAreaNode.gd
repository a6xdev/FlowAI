@tool
@icon("res://addons/FlowAI/assets/icons/area_icon.svg")
extends Node3D
class_name FlowAIAreaNode

@export var ID:int = 0 ## Unique ID
@export var area_pathnodes:Array[int] = [] ## All pathnodes in this area
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
		print("FlowAIAreaNode - " + str(name) + " removed")
#endregion
