@tool
@icon("res://addons/FlowAI/assets/icons/pathnode_icon.svg")
extends Marker3D
class_name FlowAIPathNode

@export var active:bool = true
@export var weight_scale_base:float = 1.0
@export var flow_controller:FlowAIController = null # Dont care if it.

@export var p_id:String = ""
@export var p_astar_id:int = 0
@export var p_area_id:int = 0
@export var p_prev_pathnode:String = ""
@export var p_links:Array[String] = []

var m_agents:Array[FlowAIAgent3D] = []
var weight_multiplier = 1.5
var current_weight_scale:float = 0.0

# DEBUG - some nodes to a better observe in the scene
# Just a mesh to better observe the nodes in the scene
var _debug_pathnode_visualize_mesh:MeshInstance3D = null
var _debug_mesh_material:StandardMaterial3D = null
var _debug_pathnode_name_label:Label3D = null

#region GODOT FUNCTIONS
func _ready() -> void:
	_debug_pathnode_visualize_mesh.visible = true if flow_controller.show_pathnode_shape else false
	_debug_pathnode_name_label.visible = true if flow_controller.show_pathnode_label else false
	
	tree_exiting.connect(_on_node_tree_exiting)

func _enter_tree() -> void:
	var mesh := BoxMesh.new()
	_debug_pathnode_visualize_mesh = MeshInstance3D.new()
	_debug_mesh_material = StandardMaterial3D.new()
	_debug_pathnode_name_label = Label3D.new()
	
	_debug_pathnode_visualize_mesh.mesh = mesh
	mesh.size = Vector3(0.2, 0.2, 0.2)
	_debug_mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_pathnode_visualize_mesh.set_surface_override_material(0, _debug_mesh_material)
	
	# The text of the label I set on create_pathnode in FlowAIController.
	_debug_pathnode_name_label.position = Vector3(0, 0.5, 0)
	_debug_pathnode_name_label.font_size = 16
	_debug_pathnode_name_label.outline_size = 6
	_debug_pathnode_name_label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	add_child(_debug_pathnode_visualize_mesh)
	add_child(_debug_pathnode_name_label)
#endregion

#region PLUGIN CALLS
## ALERT: Plugin private function. Dont have any reason for you to use that.
func _register_agent(agent:FlowAIAgent3D) -> void:
	m_agents.append(agent)
	_reload_weight_scale()

## ALERT: Plugin private function. Dont have any reason for you to use that.
func _unregister_agent(agent:FlowAIAgent3D) -> void:
	m_agents.erase(agent)
	_reload_weight_scale()

## ALERT: Plugin private function. Dont have any reason for you to use that.
func _reload_weight_scale() -> void:
	current_weight_scale = weight_scale_base + (m_agents.size() * weight_multiplier)
	flow_controller.current_astar.set_point_weight_scale(p_astar_id, current_weight_scale)
	
	if current_weight_scale == weight_scale_base:
		_debug_mesh_material.albedo_color = Color(1, 1, 1)
	elif current_weight_scale < 5.0:
		_debug_mesh_material.albedo_color = Color(0, 1, 0)
	else:
		_debug_mesh_material.albedo_color = Color(1, 0, 0)

## ALERT: Plugin private function. Dont have any reason for you to use that.
func _snap_to_ground() -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 2, global_position + Vector3.DOWN * 10)
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.get("collider")
		if collider is StaticBody3D: # I dont wanna the snap using characters as ground.
			global_position = result.position
#endregion

#region CALLS
func get_pathnode_id() -> String:
	return p_id

func get_pathnode_area_id() -> int:
	return p_area_id
#endregion

#region SIGNALS
func _on_node_tree_exiting():
	if self.is_queued_for_deletion():
		_debug_pathnode_visualize_mesh.queue_free()
		_debug_mesh_material = null
	
		if flow_controller.controller_pathnodes.size() > 0:
			flow_controller.controller_pathnodes[p_id] = null
			
			print("test_001")
			var area:FlowAIAreaNode = flow_controller.controller_areas[p_area_id]
			if area and area.a_pathnodes_list.has(p_id):
				area.a_pathnodes_list.erase(p_id)
			
			print("test_002")
			if p_prev_pathnode != "":
				var prev:FlowAIPathNode = flow_controller.controller_pathnodes[p_prev_pathnode]
				if prev and prev.p_links.has(p_id):
					prev.p_links.erase(p_id)
			print("test_003")
			
#endregion
