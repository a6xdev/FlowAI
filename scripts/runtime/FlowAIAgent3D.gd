extends NavigationAgent3D
class_name FlowAIAgent3D

var a_areas:Array[FlowAIAreaNode] = []
var a_pathnodes:Array[FlowAIPathNode] = []

var a_is_path_complete:bool = false
var a_current_pathnode:FlowAIPathNode = null
var a_current_path:Array = []
var a_path_index:int = 0

var a_astar := AStar3D.new()
var a_body:CharacterBody3D = null
var a_flowai_controller:FlowAIController = null
var a_area:FlowAIAreaNode = null

@export var areas_radius:float = 10.0 ## NPCs will not have access to all areas of the map, only those within this radius.

#region GODOT FUNCTIONS
func _ready() -> void:
	a_body = get_parent() as CharacterBody3D
	if not a_body:
		printerr("FlowAIAgent3D - Parent is not a CharacterBody3D.")
		get_tree().quit()
	
	# Get FlowAIController in get_root()
	# --- Scene
	# -- FlowAIController
	# -- Actor : <- Needs to be under FlowAIController
	
	var controllers_in_scene = get_tree().get_nodes_in_group("FlowAIController")
	if controllers_in_scene.size() >= 1:
		a_flowai_controller = controllers_in_scene[0] as FlowAIController
		
	a_astar = a_flowai_controller.create_astar()
	
	# Get nearby areas
	if a_flowai_controller.all_areas.is_empty():
		printerr("FlowAIAgent3D - There are no areas in FlowAIController")
		get_tree().quit()
	
	var nearest_area:FlowAIAreaNode = null
	var shortest_dist:float = INF
	for area in a_flowai_controller.all_areas:
		var dist = a_body.global_position.distance_to(area.global_position)
		if dist < areas_radius:
			a_areas.append(area)
		if dist < shortest_dist:
			shortest_dist = dist
			nearest_area = area
	
	a_area = nearest_area
	for area in a_areas:
		for pathnode_id in area.area_pathnodes:
			var pathnode = a_flowai_controller.all_pathnodes[pathnode_id - 1]
			a_pathnodes.append(pathnode)

func _process(delta: float) -> void:
	if not a_current_path.is_empty():
		var dist = a_body.global_position.distance_to(a_current_path[a_path_index])
		if dist < path_desired_distance + 0.2:
			set_next_path_index()
#endregion

#region CALLS
func get_random_path() -> void: ## Agent choice a random path from scene.
	var goal_node:FlowAIPathNode = a_pathnodes[randi() % a_pathnodes.size()]
	var start_node:FlowAIPathNode = null
	var min_dist:float = INF
	
	a_is_path_complete = false
	
	for node in a_pathnodes:
		var dist = a_body.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			start_node = node
	
	a_current_path = astar_find_path(start_node, goal_node)

func set_goal_pathnode(goal:FlowAIPathNode) -> void: ## Define a FlowAIPathNode for the Agent as a goal and it will make its own path to get there.
	var min_dist:float = INF
	var start_node:FlowAIPathNode = null
	
	a_is_path_complete = false
	
	for node in a_pathnodes:
		var dist = a_body.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			start_node = node
	
	a_current_path = astar_find_path(start_node, goal)

func astar_find_path(start:FlowAIPathNode, goal:FlowAIPathNode) -> PackedVector3Array: ## Private Funtion
	var start_id = start.get_instance_id()
	var goal_id = goal.get_instance_id()
	if a_astar.has_point(start_id) and a_astar.has_point(goal_id):
		var path = a_astar.get_point_path(start_id, goal_id)
		return path
	else:
		push_error("One of the points does not exist graph")
		return []

func set_next_path_index() -> void: ## Set the next a_path_index so the Agent can follow your path correctly
	a_path_index += 1
	if a_path_index < a_current_path.size():
		# Not much to do here.
		pass
	else:
		a_is_path_complete = true
		a_current_path.clear()
		a_path_index = 0
#endregion

#region PREDICATES
func get_next_pathnode_position() -> Vector3:
	if a_is_path_complete:
		return a_body.global_position
	else:
		return a_current_path[a_path_index] if not a_current_path.is_empty() else a_body.global_position

func get_current_pathnode() -> FlowAIPathNode:
	return a_current_pathnode

func get_current_path() -> Array:
	return a_current_path
	
func is_path_complete() -> bool:
	return a_is_path_complete

func get_current_controller() -> FlowAIController:
	return a_flowai_controller
#endregion

#region SIGNALS
#endregion
