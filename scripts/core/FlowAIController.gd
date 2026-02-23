@tool
@icon("res://addons/FlowAI/assets/icons/controller_icon.svg")
extends Node
class_name FlowAIController

## A node to facilitate the creation of new areas and pathnodes.

@export_file("*json") var data
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

func connect_nodes(from:FlowAIPathNode, to:FlowAIPathNode) -> void:
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
#endregion

#func create_astar() -> AStar3D:
	## In this function, Asta3D is created and configured from the moment the project is run.
#
	## Whenever the developer changes the FlowAIPathNode's position, they need to reload the game
	## for the changes to take effect.
	#
	#var new_astar := AStar3D.new()
	#
	## Add pathnodes
	#for point in all_pathnodes:
		#var id:int = point.get_instance_id()
		#new_astar.add_point(id, point.global_position)
		#point.astar_id = id
#
	## Connect the pathnodes
	#for point in all_pathnodes:
		#var id_a = point.get_instance_id()
		#
		#for neighbor_id in point.links:
			#var neighbor = all_pathnodes[neighbor_id - 1]
			#var id_b = neighbor.get_instance_id()
			#
			#if not new_astar.are_points_connected(id_a, id_b, true):
				#if Engine.is_editor_hint():
					#print("FlowAIController::astar_connect_points: id_a: " + str(point.name) + " to id_b: " + str(neighbor.name))
				#new_astar.connect_points(id_a, id_b, true)
	#
	#current_astar = new_astar
	#return new_astar
#
#func refresh_internal_references() -> void:
	#all_areas.clear()
	#all_pathnodes.clear()
	#data_loaded = false
	#load_data()
#
#func save_data():
	#if all_pathnodes.is_empty() and all_areas.is_empty():
		## A safety lock to prevent saving a file while switching scenes or something similar, 
		## so as not to lose all the data.
		#return
	#
	#if not DataPath:
		#printerr("FlowAIController: Data Path is Empty, put a path of a json file")
		#return
	#
	#var data = {
		#"areas": [],
		#"pathnodes": []
	#}
	#
	## Reload all content again
	#all_areas.clear()
	#all_pathnodes.clear()
	#
	#for area in get_children():
		#if area is FlowAIAreaNode:
			#all_areas.append(area)
			#for pathnode in area.get_children():
				#if pathnode is FlowAIPathNode:
					#all_pathnodes.append(pathnode)
	#
	#print("\nFLOW_AI:SAVING_DATA")
	#print("FLOW_AI:TOTAL_AREAS: ", all_areas.size())
	#print("FLOW_AI:TOTAL_PATHNODES: ", all_pathnodes.size())
	#
	#for area in all_areas:
		#data["areas"].append({
			#"id": area.ID,
			#"area_pathnodes": area.area_pathnodes,
			#"position": [area.global_position.x, area.global_position.y, area.global_position.z]
		#})
		#
	#for pathnode in all_pathnodes:
		#data["pathnodes"].append({
			#"id": pathnode.ID,
			#"area_id": pathnode.areaID,
			#"prev_pathnode": pathnode.prev_pathnode,
			#"links": pathnode.links,
			#"position": [pathnode.global_position.x, pathnode.global_position.y, pathnode.global_position.z],
		#})
		#
	#var file = FileAccess.open(DataPath, FileAccess.WRITE)
	#if file:
		#file.store_string(JSON.stringify(data, "\t"))
		#file.close()
		#if Engine.is_editor_hint():
			#print("FLOW_AI:DATA_SAVED\n")
#
#func load_data():
	#var data = get_data_json()
	#if not data: return
	#
	#all_areas.clear()
	#all_pathnodes.clear()
	#for child in get_children():
		#child.queue_free()
	#if Engine.is_editor_hint(): await get_tree().create_timer(0.2).timeout
	#
	## Map what already exists to avoid duplication.
	#var physical_areas = {}
	#var physical_pathnodes = {}
	#for child in get_children():
		#if child is FlowAIAreaNode:
			#physical_areas[child.ID] = child
			#for p in child.get_children():
				#if p is FlowAIPathNode:
					#physical_pathnodes[p.ID] = p
	#
	## Load Areas
	#for area_data in data["areas"]:
		#create_area(area_data)
	#
	## Load Pathnodes
	#for pathnode_data in data["pathnodes"]:
			#var parent_area = null
			#for a in all_areas:
				#if a.ID == int(pathnode_data["area_id"]):
					#parent_area = a
					#break
			#if parent_area:
				#create_pathnode(parent_area, null, pathnode_data)
	#
	#data_loaded = true
#
#func get_data_json() -> Dictionary:
	#if not FileAccess.file_exists(DataPath):
		#printerr("FlowAIControler - File " + str(DataPath) + " does not exist")
		#return {}
	#
	#var file = FileAccess.open(DataPath, FileAccess.READ)
	#if not file:
		#printerr("FlowAIControler - Could not open file: " + str(DataPath))
		#return {}
	#
	#var text = file.get_as_text()
	#file.close()
	#
	#var json = JSON.parse_string(text)
	#if typeof(json) != TYPE_DICTIONARY:
		#return {}
	#
	#return json
#
#func get_nearest_pathnode_from_pos(pos:Vector3, area_id:int) -> FlowAIPathNode:
	#var area:FlowAIAreaNode = all_areas.get(area_id - 1)
	#var nearest_pathnode:FlowAIPathNode = null
	#var shortest_dist:float = INF
	#
	#if area:
		#for node_id in area.area_pathnodes:
			#var pathnode = all_pathnodes.get(node_id - 1)
			#var dist = pos.distance_to(pathnode.global_position)
			#if dist < shortest_dist:
				#shortest_dist = dist
				#nearest_pathnode = pathnode
	#
	#return nearest_pathnode
##endregion
#
##region SIGNALS
##endregion
