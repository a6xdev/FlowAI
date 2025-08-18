@tool
extends Node
class_name FlowAIPedestrianWaypointManager

@export var waypoints:Array[FlowAIPedestrianWaypoint]

var waypoints_node_root := Node3D.new()
var navigation_mesh_node := NavigationRegion3D.new()
var mesh_instance_node := MeshInstance3D.new()

var get_children_nodes:Array = []

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
	
func generate_mesh() -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var right_vectors := {}
	var dir:Vector3
	
	for waypoint in waypoints:
		for next_waypoint in waypoint.next_waypoints:
			if next_waypoint == null:
				continue
			
			var seg_dir = (next_waypoint.global_position - waypoint.global_position).normalized()
			var seg_right = seg_dir.cross(Vector3.UP).normalized()

			var a_left = waypoint.global_position - seg_right * (waypoint.mesh_width * 0.5)
			var a_right_pos = waypoint.global_position + seg_right * (waypoint.mesh_width * 0.5)

			var b_left = next_waypoint.global_position - seg_right * (next_waypoint.mesh_width * 0.5)
			var b_right_pos = next_waypoint.global_position + seg_right * (next_waypoint.mesh_width * 0.5)
			
			surface_tool.add_vertex(a_left)
			surface_tool.add_vertex(b_left)
			surface_tool.add_vertex(b_right_pos)

			surface_tool.add_vertex(a_left)
			surface_tool.add_vertex(b_right_pos)
			surface_tool.add_vertex(a_right_pos)
	
	surface_tool.generate_normals()
	var mesh_result = surface_tool.commit()
	mesh_instance_node.mesh = mesh_result
	navigation_mesh_node.bake_navigation_mesh()
			
#endregion CALLS

#region SIGNALS
#endregion SIGNALS
