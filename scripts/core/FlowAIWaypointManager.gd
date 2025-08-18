@tool
extends Node
class_name FlowAIPedestrianWaypointManager

var waypoints:Array[FlowAIPedestrianWaypoint]

var waypoints_node_root := Node3D.new()
var navigation_mesh_node := NavigationRegion3D.new()
var mesh_instance_node := MeshInstance3D.new()

#region GODOT FUNCTIONS
func _ready() -> void:
	add_to_group("FlowAIPedestrianWaypoint")
	
	waypoints_node_root.name = "Waypoints"
	navigation_mesh_node.name = "NavigationMesh"
	mesh_instance_node.name = "Mesh"
	
	navigation_mesh_node.navigation_mesh = NavigationMesh.new()
	
	add_child(waypoints_node_root)
	add_child(navigation_mesh_node)
	navigation_mesh_node.add_child(mesh_instance_node)
	
	waypoints_node_root.owner = get_tree().edited_scene_root
	navigation_mesh_node.owner = get_tree().edited_scene_root
	mesh_instance_node.owner = get_tree().edited_scene_root
#endregion GODOT FUNCTIONS

#region CALLS
func add_waypoint() -> void:
	var w_point = FlowAIPedestrianWaypoint.new()
	waypoints_node_root.add_child(w_point)
	
	w_point.name = "pedestrian_waypoint_" + str(waypoints.size())
	w_point.owner = get_tree().edited_scene_root
	
	EditorInterface.edit_node(w_point)
	waypoints.append(w_point)
	
	if waypoints.size() >= 2:
		w_point.previous_waypoint = waypoints.get(waypoints.size() - 2)
		w_point.previous_waypoint.next_waypoints.append(w_point)
		w_point.global_position = w_point.previous_waypoint.global_position
	else:
		w_point.global_position = Vector3.ZERO

func add_next_waypoint(w_selected:FlowAIPedestrianWaypoint) -> void:
	var w_point = FlowAIPedestrianWaypoint.new()
	waypoints_node_root.add_child(w_point)
	
	w_point.name = "pedestrian_waypoint_" + str(waypoints.size())
	w_point.owner = get_tree().edited_scene_root
	waypoints.append(w_point)
	
	EditorInterface.edit_node(w_point)
	
	w_point.previous_waypoint = w_selected
	w_selected.next_waypoints.append(w_point)
	w_point.global_position = w_selected.global_position

func remove_waypoint(w_selected:FlowAIPedestrianWaypoint) -> void:
	if w_selected.previous_waypoint and w_selected.previous_waypoint.next_waypoints.size() > 0:
		w_selected.previous_waypoint.next_waypoints.erase(w_selected)
	waypoints.erase(w_selected)
	w_selected.queue_free()
#endregion CALLS

#region SIGNALS
#endregion SIGNALS
