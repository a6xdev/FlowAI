@tool
@icon("res://addons/FlowAI/assets/icons/controller_icon.svg")
extends Node
class_name FlowAIController

## A node to facilitate the creation of new areas and pathnodes.

@export var is_debug_mode:bool = false
@export_file("*json") var DataPath ## Path to the json file to save your changes and load them whenever you want.
@export_category("Controller")
@export var all_areas:Array[FlowAIAreaNode] = [] ## I don't recommend messing with this unless necessary. All areas are stored here for easy access using their unique IDs.
@export var all_pathnodes:Array[FlowAIPathNode] = [] ## I don't recommend changing anything here unless absolutely necessary. All pathnodes are stored here for easy access using their unique IDs.


#region GODOT FUNCTIONS
func _ready() -> void:
	add_to_group("FlowAIController")
	
	# Loads all data from the DataPath when the game runs.
	if not Engine.is_editor_hint():
		load_data()

func _exit_tree() -> void:
	# When the developer leaves the project, all nodes and their references are cleaned up
	# so as not to interfere with DataPath runtime loading.
	for child in get_children():
		all_areas.clear()
		all_pathnodes.clear()
		child.queue_free()
#endregion

#region CALLS
func create_area(data:Dictionary = {}) -> FlowAIAreaNode:
	# The data argument is only used when DataPath data is loaded.
	# This way, areas are created based on all the information the developer saved.
	
	var new_area := FlowAIAreaNode.new()
	new_area.flowAI_controller = self
	add_child(new_area)
	all_areas.append(new_area)
	new_area.owner = get_tree().edited_scene_root
	
	if data:
		var pos_data = data["position"]
		new_area.ID = data["id"]
		new_area.global_position = Vector3(float(pos_data[0]), float(pos_data[1]), float(pos_data[2]))
		for n in data["area_pathnodes"]:
			new_area.area_pathnodes.append(int(n))
	else:
		new_area.ID = all_areas.size() if not all_areas.is_empty() else 1
		if Engine.is_editor_hint():
			print("Create FlowAIAreaNode")
		
	new_area.name = "area_" + str(new_area.ID)
	return new_area
	
func create_pathnode(area_owner:FlowAIAreaNode, prev_node:FlowAIPathNode = null, data:Dictionary = {}) -> FlowAIPathNode:
	# The data argument is only used when DataPath data is loaded.
	# This way, pathnodes are created based on all the information the developer saved.
	
	if area_owner == null:
		return
	
	var new_pathnode := FlowAIPathNode.new()
	new_pathnode.flowAI_controller = self
	area_owner.add_child(new_pathnode)
	all_pathnodes.append(new_pathnode)
	new_pathnode.owner = get_tree().edited_scene_root
	
	if data:
		var pos_data = data["position"]
		new_pathnode.ID = data["id"]
		new_pathnode.areaID = data["area_id"]
		new_pathnode.prev_pathnode = data["prev_pathnode"]
		new_pathnode.global_position = Vector3(float(pos_data[0]), float(pos_data[1]), float(pos_data[2]))
		for n in data["links"]:
			new_pathnode.links.append(int(n))
	else:
		new_pathnode.ID = all_pathnodes.size() if not all_pathnodes.is_empty() else 1
		new_pathnode.areaID = area_owner.ID
		if Engine.is_editor_hint():
			print("Create FlowAIPathNode")
	
		if prev_node:
			new_pathnode.prev_pathnode = prev_node.ID
			prev_node.links.append(new_pathnode.ID)
			new_pathnode.global_position = prev_node.global_position
		area_owner.area_pathnodes.append(new_pathnode.ID)
		
	new_pathnode.name = "pathnode_" + str(new_pathnode.ID)
	return new_pathnode

func connect_nodes(from:FlowAIPathNode, to:FlowAIPathNode) -> void:
	if not from.links.has(to.ID):
		from.links.append(to.ID)
		print("FlowAIController - Nodes has been connected: " + from.name + " to: " + to.name)
	
func create_astar() -> AStar3D:
	# In this function, Asta3D is created and configured from the moment the project is run.

	# Whenever the developer changes the FlowAIPathNode's position, they need to reload the game
	# for the changes to take effect.
	
	var new_astar := AStar3D.new()
	
	# Add pathnodes
	for point in all_pathnodes:
		var id:int = point.get_instance_id()
		new_astar.add_point(id, point.global_position)

	# Connect the pathnodes
	for point in all_pathnodes:
		var id_a = point.get_instance_id()
		
		for neighbor_id in point.links:
			var neighbor = all_pathnodes[neighbor_id - 1]
			var id_b = neighbor.get_instance_id()
			
			if not new_astar.are_points_connected(id_a, id_b, true):
				if Engine.is_editor_hint():
					print("FlowAIController::astar_connect_points: id_a: " + str(point.name) + " to id_b: " + str(neighbor.name))
				new_astar.connect_points(id_a, id_b, true)

	return new_astar

func save_data():
	if not DataPath:
		printerr("FlowAIController: Data Path is Empty, put a path of a json file")
		return
	
	var data = {
		"areas": [],
		"pathnodes": []
	}
	
	for area in all_areas:
		data["areas"].append({
			"id": area.ID,
			"area_pathnodes": area.area_pathnodes,
			"position": [area.global_position.x, area.global_position.y, area.global_position.z]
		})
		
	for pathnode in all_pathnodes:
		data["pathnodes"].append({
			"id": pathnode.ID,
			"area_id": pathnode.areaID,
			"prev_pathnode": pathnode.prev_pathnode,
			"links": pathnode.links,
			"position": [pathnode.global_position.x, pathnode.global_position.y, pathnode.global_position.z]
		})
		
	var file = FileAccess.open(DataPath, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		if Engine.is_editor_hint():
			print("FlowAIController: All Data has been saved")

func load_data():
	for child in get_children():
		all_areas.clear()
		all_pathnodes.clear()
		child.queue_free()
	
	var data = get_data_json()
	
	if data:
		# Load Areas
		for area in data["areas"]:
			create_area(area)
		
		# Load Pathnodes
		for pathnode in data["pathnodes"]:
			var area: FlowAIAreaNode = null
			
			for a in all_areas:
				if a.ID == int(pathnode["area_id"]):
					area = a
					break
			
			if area:
				create_pathnode(area, null, pathnode)
		
			print("FlowAIController: All Data has been loaded")

func get_data_json() -> Dictionary:
	if not FileAccess.file_exists(DataPath):
		printerr("FlowAIControler - File " + str(DataPath) + " does not exist")
		return {}
	
	var file = FileAccess.open(DataPath, FileAccess.READ)
	if not file:
		printerr("FlowAIControler - Could not open file: " + str(DataPath))
		return {}
	
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(text)
	if typeof(json) != TYPE_DICTIONARY:
		return {}
	
	return json
#endregion

#region SIGNALS
#endregion
