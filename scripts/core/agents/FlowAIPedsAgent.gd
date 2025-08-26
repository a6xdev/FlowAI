extends NavigationAgent3D
class_name FlowAINavigationPedsAgent3D

@export var agent:NPC = null

var astar := AStar3D.new()

var waypoint_manager:FlowAIPedestrianWaypointManager = null
var target_waypoint:FlowAIPedestrianWaypoint = null
var start_waypoint:FlowAIPedestrianWaypoint = null

var waypoints_array:Array[FlowAIPedestrianWaypoint] = []
var current_path:Array = []
var path_index:int = 0

signal is_peds_navigation_finished

#region GODOT FUNCTIONS
func _ready() -> void:
	waypoint_manager = find_waypoint_manager()
	
	if not waypoint_manager or not agent:
		push_error("FlowAINavigationPedsAgent: Waypoint Manager and Agent is empty")
		get_tree().quit()
	
	if waypoint_manager:
		waypoints_array = waypoint_manager.waypoints
		
		for point in waypoints_array:
			var id = point.get_instance_id()
			astar.add_point(id, point.global_position)
			
		for point in waypoints_array:
			var id_a = point.get_instance_id()
			
			for neighbor in point.next_waypoints:
				var id_b = neighbor.get_instance_id()
				if not astar.are_points_connected(id_a, id_b):
					astar.connect_points(id_a, id_b, true)
#endregion

#region CALLS
func generate_path() -> void:
	var tries:int = 0
	var min_dinstance = INF
	target_waypoint = waypoints_array[randi() % waypoints_array.size()]
	
	for point in waypoints_array:
		var distance = agent.global_position.distance_to(point.global_position)
		if distance < min_dinstance:
			min_dinstance = distance
			start_waypoint = point
		
	current_path = find_path(start_waypoint, target_waypoint)
	get_next_waypoint_from_path()

func find_path(start:FlowAIPedestrianWaypoint, goal:FlowAIPedestrianWaypoint) -> PackedVector3Array:
	var start_id = start.get_instance_id()
	var goal_id = goal.get_instance_id()
	
	if astar.has_point(start_id) and astar.has_point(goal_id):
		return astar.get_point_path(start_id, goal_id)
	else:
		push_error("FlowAIPedsAgent: One of the points does not exist graph")
		return []

func get_next_waypoint_from_path() -> void:
	path_index += 1
	if path_index < current_path.size():
		set_agent_target(current_path[path_index])
		return
	else:
		current_path.clear()
		path_index = 0
		is_peds_navigation_finished.emit()
		generate_path()
		return

func set_agent_target(target:Vector3) -> void:
	var new_target = Vector3(target.x, target.y + 0.5, target.z)
	set_target_position(new_target)

func find_waypoint_manager() -> FlowAIPedestrianWaypointManager:
	var managers = get_tree().get_nodes_in_group("FlowAIPedestrianWaypoint")
	if managers.size() > 0:
		return managers[0] as FlowAIPedestrianWaypointManager
	return null
#endregion
