@tool
extends Node
class_name FlowAIController

@export var areas:Array[FlowAIAreaNode] = []

#region GODOT FUNCTIONS
func _ready() -> void:
	add_to_group("FlowAIController")
	
	#get_tree().node_removed.connect(get_tree_node_removed)
#endregion

#region CALLS
func add_area() -> void:
	var new_area := FlowAIAreaNode.new()
	var new_area_resource := AreaNodeData.new()
	add_child(new_area)
	
	new_area_resource.areaID = areas.back().area_resource.areaID + 1 if not areas.is_empty() else 1
	new_area.name = "area_" + str(new_area_resource.areaID)
	new_area_resource.area_name = new_area.name
	new_area_resource.pathnode_controller = new_area.get_path_to(self)
	
	new_area.owner = get_tree().edited_scene_root
	areas.append(new_area)
	
	new_area.area_resource = new_area_resource
	
	EditorInterface.edit_node(new_area)

func add_pathnode(area:FlowAIAreaNode, prev_pathnode:FlowAIPathNode = null) -> void:
	var new_pathnode := FlowAIPathNode.new()
	var new_pathnode_resource := PathNodeData.new()
	area.add_child(new_pathnode)
		
	new_pathnode_resource.pathnodeID = area.get_node_or_null(area.area_resource.area_pathnodes.back()).pathnode_resource.pathnodeID + 1 if not area.area_resource.area_pathnodes.is_empty() else 1
	new_pathnode.name = "pathnode_" + str(new_pathnode_resource.pathnodeID) + "_area_" + str(area.area_resource.areaID)
	new_pathnode_resource.pathnode_name = new_pathnode.name
	new_pathnode_resource.area_owner = new_pathnode.get_path_to(area)
	new_pathnode_resource.pathnode_controller = new_pathnode.get_path_to(self)
	new_pathnode.owner = get_tree().edited_scene_root
	
	if prev_pathnode:
		new_pathnode.global_position = prev_pathnode.global_position
		new_pathnode_resource.prev_pathnode = new_pathnode.get_path_to(prev_pathnode)
		prev_pathnode.pathnode_resource.pathnode_links.append(prev_pathnode.get_path_to(new_pathnode))
	
	new_pathnode.pathnode_resource = new_pathnode_resource
	area.area_resource.area_pathnodes.append(area.get_path_to(new_pathnode))
	
	EditorInterface.edit_node(new_pathnode)

func connect_nodes(main:FlowAIPathNode, sec:FlowAIPathNode) -> void:
	var path = main.get_path_to(sec)
	if not main.pathnode_resource.pathnode_links.has(path):
		main.pathnode_resource.pathnode_links.append(path)
	
func create_astar() -> AStar3D:
	var new_astar := AStar3D.new()
	var all_pathnodes:Array[FlowAIPathNode] = []
	
	for area in areas:
		
		# Get all pathnodes in all areas
		for pathnode_path in area.area_resource.area_pathnodes:
			var pathnode = area.get_node_or_null(pathnode_path)
			all_pathnodes.append(pathnode)
		
	print("all_pathnodes: " + str(all_pathnodes))
	
	# Add point logic
	for node in all_pathnodes:
		var id_a:int = node.get_instance_id()
		new_astar.add_point(id_a, node.global_position)
	
	# Connect points logic
	for node in all_pathnodes:
		var id_a = node.get_instance_id()
		
		for neighbor_path in node.pathnode_resource.pathnode_links:
			var node_neighbor = node.get_node_or_null(neighbor_path)
			var id_b = node_neighbor.get_instance_id()
			
			if not new_astar.are_points_connected(id_a, id_b):
				print("\n")
				print("astar_connect_point::id_a: " + str(node.name))
				print("astar_connect_point::id_b: " + str(node_neighbor.name))
				print("\n")
				new_astar.connect_points(id_a, id_b, true)
		
	return new_astar
#endregion

#region SIGNALS
func get_tree_node_removed(node:Node) -> void:
	if node is FlowAIPathNode:
		var area:FlowAIAreaNode = get_node(node.pathnode_resource.area_owner)
		var prev_node:FlowAIPathNode = get_node(node.pathnode_resource.prev_pathnode)
		
		area.area_resource.area_pathnodes.erase(node.get_path())
		
		if prev_node:
			prev_node.pathnode_resource.pathnode_links.erase(node.get_path())
		
	elif node is FlowAIAreaNode:
		areas.erase(node)
#endregion
