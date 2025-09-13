@tool
extends Node
class_name FlowAIController

@export_file("*json") var DataPath = "res://addons/FlowAI/data.json"
@export var all_areas:Array[FlowAIAreaNode] = []
@export var all_pathnodes:Array[FlowAIPathNode] = []

var is_running:bool = false

#region GODOT FUNCTIONS
func _ready() -> void:
	add_to_group("FlowAIController")
	
	if not Engine.is_editor_hint():
		load_data()

#endregion

#region CALLS
func create_area(data:Dictionary = {}) -> void:
	var new_area := FlowAIAreaNode.new()
	
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
		print("Create FlowAIAreaNode")
		if Engine.is_editor_hint():
			EditorInterface.edit_node(new_area)
		
	new_area.flowAI_controller = self
	new_area.name = "area_ " + str(new_area.ID)
	
func create_pathnode(area_owner:FlowAIAreaNode, prev_node:FlowAIPathNode = null, data:Dictionary = {}) -> void:
	if area_owner == null:
		return
	
	var new_pathnode := FlowAIPathNode.new()
	
	area_owner.add_child(new_pathnode)
	all_pathnodes.append(new_pathnode)
	new_pathnode.owner = get_tree().edited_scene_root
	
	new_pathnode.flowAI_controller = self
	
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
		print("Create FlowAIPathNode")
	
		if prev_node:
			new_pathnode.prev_pathnode = prev_node.ID
			prev_node.links.append(new_pathnode.ID)
			new_pathnode.global_position = prev_node.global_position
		area_owner.area_pathnodes.append(new_pathnode.ID)
		
		EditorInterface.edit_node(new_pathnode)
	
	new_pathnode.name = "pathnode_" + str(new_pathnode.ID)

func connect_nodes(from:FlowAIPathNode, to:FlowAIPathNode) -> void:
	if not from.links.has(to.ID):
		from.links.append(to.ID)
		print(from.name + " connect with: " + to.name)
	
func create_astar() -> AStar3D:
	var new_astar := AStar3D.new()
	
	for point in all_pathnodes:
		var id:int = point.get_instance_id()
		new_astar.add_point(id, point.global_position)

	for point in all_pathnodes:
		var id_a = point.get_instance_id()
		
		for neighbor_id in point.links:
			var neighbor = all_pathnodes[neighbor_id - 1]
			var id_b = neighbor.get_instance_id()
			
			if not new_astar.are_points_connected(id_a, id_b, true):
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
		
			is_running = true
			print("FlowAIController: All Data has been loaded")

func get_data_json() -> Dictionary:
	if not FileAccess.file_exists(DataPath):
		return {}
	
	var file = FileAccess.open(DataPath, FileAccess.READ)
	if not file:
		return {}
	
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(text)
	if typeof(json) != TYPE_DICTIONARY:
		return {}
	
	return json
#endregion

#region REGIONS
#endregion
