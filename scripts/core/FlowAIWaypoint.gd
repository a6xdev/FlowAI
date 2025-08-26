@tool
extends Marker3D
class_name FlowAIPedestrianWaypoint

@export var mesh_width:float = 3.0

@export var previous_waypoint:FlowAIPedestrianWaypoint = null
@export var next_waypoints:Array[FlowAIPedestrianWaypoint] = []

var current_color:Color
var base_color = Color(1, 0.647059, 0, 1)
var select_color: Color = Color(0, 0, 1)
var highlight_color: Color = Color(0, 0.5, 1)

var is_selected:bool = false
var is_highlighted:bool = false

# DEBUG
var w_mesh := MeshInstance3D.new()
var w_mesh_material := StandardMaterial3D.new()

#region GODOT FUNCTIONS
func _enter_tree() -> void:
	if not get_children().has(w_mesh):
		w_mesh_material.albedo_color = base_color
		
		w_mesh.mesh = BoxMesh.new()
		w_mesh.mesh.size = Vector3(0.5, 0.5, 0.5)
		w_mesh.set_surface_override_material(0, w_mesh_material)
		
		add_child(w_mesh)
	
	if Engine.is_editor_hint():
		EditorInterface.get_selection().selection_changed.connect(_on_node_select)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if is_selected: apply_color(select_color)
		elif is_highlighted: apply_color(highlight_color)
		else: apply_color(base_color)
#endregion

#region CALLS
func apply_color(color:Color) -> void:
	w_mesh_material.albedo_color = color
#endregion

#region SIGNALS
func _on_node_select() -> void:
	var nodes_selected = EditorInterface.get_selection().get_selected_nodes()
	is_selected = true if not nodes_selected.is_empty() and nodes_selected[0] == self else false
	
	for node in next_waypoints:
		node.is_highlighted = is_selected
		
	if nodes_selected.is_empty():
		for node in next_waypoints:
			node.is_highlighted = false
#endregion
