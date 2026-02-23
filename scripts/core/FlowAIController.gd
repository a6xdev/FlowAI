@tool
@icon("res://addons/FlowAI/assets/icons/controller_icon.svg")
extends Node
class_name FlowAIController

## A node to facilitate the creation of new areas and pathnodes.

@export var controller_areas:Dictionary[int, FlowAIAreaNode] = {}
@export var controller_pathnodes:Dictionary[String, FlowAIPathNode] = {}

@export_group("Debug")
@export var show_pathnode_shape:bool = false
@export var show_pathnode_lines:bool = true
@export var show_pathnode_label:bool = false

var current_astar:AStar3D = null

var _m_is_scene_shutting_down:bool = false

#region GODOT FUNCTIONS
func _enter_tree() -> void:
	add_to_group("FlowAIController")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		_m_is_scene_shutting_down = true
#endregion

#region [EDITOR] CALLS
func _editor_add_area() -> FlowAIAreaNode:
	var new_area := FlowAIAreaNode.new()
	var new_data := FlowAIAreaData.new()
	new_area.a_data = new_data
	new_area.a_flow_controller = self
	add_child(new_area)
	new_area.owner = get_tree().edited_scene_root
	
	var unique_id:int = controller_areas.size() if not controller_pathnodes.is_empty() else 1
	var unique_name:String = "area_" + str(unique_id)
	new_area.a_data.a_id = unique_id
	new_area.name = "area_" + str(unique_id)
	controller_areas[unique_id] = new_area
	return new_area

func _editor_add_pathnode(area_owner:FlowAIAreaNode, prev_pathnode:FlowAIPathNode = null) -> FlowAIPathNode:
	if area_owner == null:
		return
	
	var new_pathnode := FlowAIPathNode.new()
	var new_data := FlowAIPathNodeData.new()
	new_pathnode.p_data = new_data
	new_pathnode.p_flow_controller = self
	area_owner.add_child(new_pathnode)
	new_pathnode.owner = get_tree().edited_scene_root
	
	var unique_id:String = _check_and_return_null_id_in_controller_pathnodes(area_owner)
	var unique_name:String = "pathnode_" + unique_id
	new_pathnode.p_data.p_id = unique_id
	new_pathnode.p_data.p_area_id = area_owner.a_data.a_id
	new_pathnode.name = unique_name
	new_pathnode._debug_pathnode_name_label.text = unique_name
	
	if prev_pathnode:
		new_pathnode.p_data.p_prev_pathnode = prev_pathnode.p_data.p_id
		prev_pathnode.p_data.p_links.append(unique_id)
		new_pathnode.global_position = prev_pathnode.global_position
	
	area_owner.a_pathnodes_list.append(unique_id)
	controller_pathnodes[unique_id] = new_pathnode
	return new_pathnode

func _editor_connect_nodes(from:FlowAIPathNode, to:FlowAIPathNode) -> void:
	if not from.p_links.has(to.p_id):
		from.p_links.append(to.p_id)

func _check_and_return_null_id_in_controller_pathnodes(area_owner:FlowAIAreaNode) -> String:
	var _to_check_value = str(area_owner.a_data.a_id) + "_" + str(area_owner.a_pathnodes_list.size())
	
	for id in controller_pathnodes:
		if controller_pathnodes[id] == null:
			return id
	
	return _to_check_value

func _is_scene_shutting_down() -> bool:
	return _m_is_scene_shutting_down
#endregion

#region [RUNTIME] CALLS
func _runtime_create_astar() -> AStar3D:
	var new_astar := AStar3D.new()
	
	# Add point based on pathnodes on 'controller_pathnodes'
	for pathnode_id in controller_pathnodes:
		var point = controller_pathnodes[pathnode_id]
		var astar_id = point.get_instance_id()
		point.p_data.p_astar_id = astar_id
		new_astar.add_point(astar_id, point.global_position)
	
	# Connect the points based on pathnode links
	for pathnode_id in controller_pathnodes:
		var point = controller_pathnodes[pathnode_id]
		var astar_id_01 = point.get_instance_id()
		
		for link_id in point.p_data.p_links:
			var p_link = controller_pathnodes[link_id]
			var astar_id_02 = p_link.get_instance_id()
			
			if not new_astar.are_points_connected(astar_id_01, astar_id_02, true):
				new_astar.connect_points(astar_id_01, astar_id_02, true)
	current_astar = new_astar
	return new_astar
#endregion
