@tool
extends Marker3D
class_name FlowAIPedestrianWaypoint

@export var mesh_width:float = 3.0

@export var previous_waypoint:FlowAIPedestrianWaypoint = null
@export var next_waypoints:Array[FlowAIPedestrianWaypoint] = []

# DEBUG
var w_mesh := MeshInstance3D.new()
var w_mesh_material := StandardMaterial3D.new()

func _enter_tree() -> void:
	if not get_children().has(w_mesh):
		w_mesh_material.albedo_color = Color(1, 0.647059, 0, 1)
		
		w_mesh.mesh = BoxMesh.new()
		w_mesh.mesh.size = Vector3(0.5, 0.5, 0.5)
		w_mesh.set_surface_override_material(0, w_mesh_material)
		
		add_child(w_mesh)
