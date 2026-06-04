extends NavigationAgent3D
class_name FlowAIAgent3D

const avoidance_update_rate:int = 2

var m_areas:Array[FlowAIAreaNode] = []
var a_pathnodes:Array[FlowAIPathNode] = []

var parent_character_body:CharacterBody3D = null
var flowai_controller:FlowAIController = null

var current_astar:AStar3D = null
var current_area:FlowAIAreaNode = null

var _a_is_path_complete:bool = false
var _a_current_pathnode:FlowAIPathNode = null
var _a_current_pathnode_astar_id = null
var _a_current_path:Array = []
var _a_path_index:int = 0

var _internal_avoidance_velocity := Vector3.ZERO
var _previous_target:FlowAIPathNode = null

@export var desired_area_id:int = 1 ## ID of the desired area

#region GODOT FUNCTIONS
func _ready() -> void:
	parent_character_body = get_parent() as CharacterBody3D
	if not parent_character_body:
		printerr("FlowAIAgent3D - Parent is not a CharacterBody3D.")
		get_tree().quit()
		return
	
	parent_character_body.visibility_changed.connect(_on_body_visibility_changed)
	
	var controllers_in_scene = get_tree().get_nodes_in_group("FlowAIController")
	if controllers_in_scene.size() >= 1:
		flowai_controller = controllers_in_scene[0] as FlowAIController
	
	# Check if exists FlowAIController in the current scene and create the Astar.
	if not flowai_controller:
		printerr("FlowAIAgent3D - There are no FLowAIController in the current scene")
	
	var controller_areas = flowai_controller._get_areas_list()
	flowai_controller._runtime_register_agent(self)
	current_astar = flowai_controller._runtime_create_astar()
	
	# Get nearby areas
	if controller_areas.is_empty():
		printerr("FlowAIAgent3D - There are no areas in FlowAIController")
		get_tree().quit()
	
	# Get Area
	current_area = controller_areas[desired_area_id]
	var current_area_pathnodes = current_area._get_pathnodes_list()
	
	for pathnode_id in current_area_pathnodes:
		var pathnode = current_area_pathnodes[pathnode_id]
		a_pathnodes.append(pathnode)

func _physics_process(delta: float) -> void:
	if not _a_current_path.is_empty():
		var dist = parent_character_body.global_position.distance_to(_a_current_path[_a_path_index])
		if (dist - 0.1) < path_desired_distance:
			set_next_path_index()
#endregion

#region CALLS
func get_random_path() -> void: ## Agent choice a random path from scene.
	if a_pathnodes.is_empty():
		print("FlowAIAgent3D::get_random_path() -  pathnodes are empty")
		return
	
	var goal_node:FlowAIPathNode = a_pathnodes[randi() % a_pathnodes.size()]
	var start_node:FlowAIPathNode = null
	var min_dist:float = INF
	
	_a_path_index = 0
	_a_is_path_complete = false
	
	for node in a_pathnodes:
		#if node == previous_target: # Check if the node is in old_targets
			#continue
			
		var dist = parent_character_body.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			start_node = node
	
	_a_current_path = astar_find_path(start_node, goal_node)

func set_goal_pathnode(goal:FlowAIPathNode) -> void: ## Define a FlowAIPathNode for the Agent as a goal and it will make its own path to get there.
	var min_dist:float = INF
	var start_node:FlowAIPathNode = null
	
	_a_path_index = 0
	_a_is_path_complete = false
	
	for node in a_pathnodes:
		var dist = parent_character_body.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			start_node = node
	
	_a_current_path = astar_find_path(start_node, goal)

func astar_find_path(start:FlowAIPathNode, goal:FlowAIPathNode) -> PackedVector3Array: ## Private Funtion
	var start_id = start.get_instance_id()
	var goal_id = goal.get_instance_id()
	
	# If exist a current pathnode, reset.
	if _a_current_pathnode:
		_a_current_pathnode._unregister_agent(self)
		_a_current_pathnode = null
	
	if current_astar.has_point(start_id) and current_astar.has_point(goal_id):
		var path = current_astar.get_point_path(start_id, goal_id)
		
		goal._register_agent(self)
		_previous_target = goal
		_a_current_pathnode = goal
		_a_current_pathnode_astar_id = goal_id
		return path
	else:
		push_error("One of the points does not exist graph")
		return []

func set_next_path_index() -> void: ## Set the next _a_path_index so the Agent can follow your path correctly
	_a_path_index += 1
	if _a_path_index < _a_current_path.size():
		# Not much to do here.
		pass
	else:
		_a_is_path_complete = true
		_a_current_path.clear()
		_a_path_index = 0
#endregion

#region PREDICATES
func get_next_pathnode_position() -> Vector3:
	if _a_is_path_complete:
		return parent_character_body.global_position
	else:
		return _a_current_path[_a_path_index] if not _a_current_path.is_empty() else parent_character_body.global_position

func get_current_pathnode() -> FlowAIPathNode:
	return _a_current_pathnode

func get_current_path() -> Array:
	return _a_current_path
	
func is_path_complete() -> bool:
	return _a_is_path_complete

func get_current_controller() -> FlowAIController:
	return flowai_controller
#endregion

#region SIGNALS
func _on_body_visibility_changed() -> void:
	# Reset Agent when body is disabled
	if not parent_character_body.visible:
		_a_current_path.clear()
		_a_current_pathnode = null
		_a_path_index = 0
		_a_is_path_complete = false
#endregion
