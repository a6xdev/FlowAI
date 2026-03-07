@tool
@icon("res://addons/FlowAI/assets/icons/controller_icon.svg")
extends Node
class_name FlowAIController

@export_group("Debug")
@export var show_pathnode_lines:bool = true ## Toggles the visibility of connection lines between pathnodes in the editor.
@export var show_pathnode_shape:bool = true: ## Toggles the visibility of the pathnode's physical mesh/gizmo.
	set(value):
		show_pathnode_shape = value
		_notify_all_pathnodes()
@export var show_pathnode_label:bool = true: ## Displays floating labels with ID and metadata for each pathnode.
	set(value):
		show_pathnode_label = value
		_notify_all_pathnodes()

var current_astar:AStar3D = null

var _m_all_agents:Array[FlowAIAgent3D] = []

#region GODOT FUNCTIONS
func _enter_tree() -> void:
	# This is necessary so that the FlowAIAgent can find this node.
	if not is_in_group("FlowAIController"):
		add_to_group("FlowAIController")
#endregion

#region [EDITOR] CALLS
func _editor_add_area() -> FlowAIAreaNode:
	var new_area := FlowAIAreaNode.new()
	var new_data := FlowAIAreaData.new()
	new_area.a_data = new_data
	new_area.a_flow_controller = self
	add_child(new_area)
	new_area.owner = get_tree().edited_scene_root
	
	var unique_id:int = _get_unique_area_id()
	var unique_name:String = "area_" + str(unique_id)
	new_area.a_data.a_id = unique_id
	new_area.name = "area_" + str(unique_id)
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
	
	var unique_id:String = _get_available_pathnode_id(area_owner)
	var unique_name:String = "pathnode_" + unique_id
	new_pathnode.p_data.p_id = unique_id
	new_pathnode.p_data.p_area_id = area_owner.a_data.a_id
	new_pathnode.name = unique_name
	new_pathnode._debug_pathnode_name_label.text = unique_name
	
	if prev_pathnode:
		new_pathnode.p_data.p_prev_pathnode = prev_pathnode.p_data.p_id
		new_pathnode.global_position = prev_pathnode.global_position
		prev_pathnode.p_data.p_links.append(unique_id)
	return new_pathnode

func _editor_connect_nodes(from:FlowAIPathNode, to:FlowAIPathNode) -> void:
	if not from.p_data.p_links.has(to.p_data.p_id):
		from.p_data.p_links.append(to.p_data.p_id)

func _notify_all_pathnodes(): ## Update the pathnode debug
	var list = _get_pathnodes_list()
	for pathnode_id in list:
		var pathnode = list[pathnode_id]
		pathnode._update_debug_options()

func _get_unique_area_id() -> int: # Get a cool ID to add a new area in the editor
	var _current_ids = _get_areas_list().keys()
	if _current_ids.is_empty():
		return 1
	
	_current_ids.sort()
	var _max_id = _current_ids.back()
	var _value = _max_id + 1
	return _check_and_return_null_id_in_controller_area(_value)

func _get_available_pathnode_id(area_owner: FlowAIAreaNode) -> String: # Get a cool and free ID to add new pathnode in the editor lol
	var pathnodes_list = _get_pathnodes_list()
	var prefix = str(area_owner.a_data.a_id) + "_"
	var counter = 0
	
	while true:
		var test_id = prefix + str(counter)
		if not pathnodes_list.has(test_id):
			return test_id
		var node_ref = pathnodes_list[test_id]
		if node_ref == null or not is_instance_valid(node_ref):
			return test_id
		
		counter += 1
	return ""

func _check_and_return_null_id_in_controller_area(check_id:int) -> int: # Check if the area ID is valid
	var areas_list = _get_areas_list()
	for id in areas_list:
		if areas_list[id] == null:
			return id
	
	return check_id
#endregion

#region [RUNTIME] CALLS
func _runtime_create_astar() -> AStar3D:
	var pathnodes_list = _get_pathnodes_list()
	var new_astar := AStar3D.new()
	
	# Add point based on pathnodes on 'controller_pathnodes'
	for pathnode_id in pathnodes_list:
		var point = pathnodes_list[pathnode_id]
		var astar_id = point.get_instance_id()
		point.p_data.p_astar_id = astar_id
		new_astar.add_point(astar_id, point.global_position)
	
	# Connect the points based on pathnode links
	for pathnode_id in pathnodes_list:
		var point = pathnodes_list[pathnode_id]
		var astar_id_01 = point.get_instance_id()
		
		for link_id in point.p_data.p_links:
			var p_link = pathnodes_list[link_id]
			var astar_id_02 = p_link.get_instance_id()
			
			if not new_astar.are_points_connected(astar_id_01, astar_id_02, true):
				new_astar.connect_points(astar_id_01, astar_id_02, true)
	current_astar = new_astar
	return new_astar

func _runtime_register_agent(agent:FlowAIAgent3D) -> void:
	if not _m_all_agents.has(agent):
		_m_all_agents.append(agent)

func _runtime_get_nearby_agents(origin:Vector3, radius:float) -> Array[FlowAIAgent3D]:
	var nearby:Array[FlowAIAgent3D] = []
	var radius_squared = radius
	for agent in _m_all_agents:
		if origin.distance_squared_to(agent.parent_character_body.global_position) <= radius_squared:
			nearby.append(agent)
	return nearby
#endregion

#region IMPORTANT CALLS
func _get_areas_list() -> Dictionary:
	var area_list:Dictionary = {}
	for child in get_children():
		if child is FlowAIAreaNode:
			area_list[child.a_data.a_id] = child
	return area_list

func _get_pathnodes_list() -> Dictionary:
	var pathnodes_list:Dictionary = {}
	var areas_list = _get_areas_list()
	for area_id in areas_list:
		var area:FlowAIAreaNode = areas_list[area_id]
		for pathnode in area.get_children():
			if pathnode is FlowAIPathNode:
				pathnodes_list[pathnode.p_data.p_id] = pathnode
	return pathnodes_list
#endregion
