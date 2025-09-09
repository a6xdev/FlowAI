@tool
extends Node
class_name FlowAIController

@export var areas:Array[FlowAIAreaNode] = []

#region GODOT FUNCTIONS
func _ready() -> void:
	add_to_group("FlowAIController")
#endregion

#region CALLS
func add_area() -> void:
	var new_area := FlowAIAreaNode.new()
	var new_area_resource := AreaNodeData.new()
	add_child(new_area)
	
	new_area_resource.areaID = areas.back().area_resource.areaID + 1 if not areas.is_empty() else 1
	new_area.name = "area_" + str(new_area_resource.areaID)
	new_area_resource.area_name = new_area.name
	new_area_resource.pathnode_controller = self.get_path()
	
	new_area.owner = get_tree().edited_scene_root
	areas.append(new_area)
	
	new_area.area_resource = new_area_resource
	
	EditorInterface.edit_node(new_area)

func add_pathnode(area:FlowAIAreaNode, prev_pathnode:FlowAIPathNode = null) -> void:
	var new_pathnode := FlowAIPathNode.new()
	var new_pathnode_resource := PathNodeData.new()
	area.add_child(new_pathnode)
	
	new_pathnode_resource.pathnodeID = get_node_or_null(area.area_resource.area_pathnodes.back()).pathnode_resource.pathnodeID + 1 if not area.area_resource.area_pathnodes.is_empty() else 1
	new_pathnode.name = "pathnode_" + str(new_pathnode_resource.pathnodeID)
	new_pathnode_resource.pathnode_name = new_pathnode.name
	new_pathnode_resource.area_owner = area.get_path()
	new_pathnode.owner = get_tree().edited_scene_root
	
	if prev_pathnode:
		new_pathnode.global_position = prev_pathnode.global_position
		new_pathnode_resource.prev_pathnode = prev_pathnode.get_path()
		prev_pathnode.pathnode_resource.pathnode_links.append(new_pathnode.get_path())
	
	new_pathnode.pathnode_resource = new_pathnode_resource
	area.area_resource.area_pathnodes.append(new_pathnode.get_path())
	
	EditorInterface.edit_node(new_pathnode)
#endregion

#region SIGNALS
#endregion
