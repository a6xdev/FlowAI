@tool
@icon("res://addons/FlowAI/assets/icons/pathnode_icon.svg")
extends Marker3D
class_name FlowAIPathNode

@export var active:bool = true
@export var weight_scale_base:float = 1.0
@export var flow_controller:FlowAIController = null # Dont care if it.

var ID:int = 0
var areaID:int = 0
var prev_pathnode:int = 0
var links:Array[int] = []
var astar_id:int = 0

var m_agents:Array[FlowAIAgent3D] = []
var weight_multiplier = 1.5
var current_weight_scale:float = 0.0

# Just a mesh to better observe the nodes in the scene
var pn_mesh:MeshInstance3D = null
var pn_material:StandardMaterial3D = null

#region GODOT FUNCTIONS
func _ready() -> void:
	if not Engine.is_editor_hint():
		pn_mesh.visible = true if flow_controller.active_pathnode_shape else false
	
	tree_exiting.connect(_on_node_tree_exiting)

func _enter_tree() -> void:
	var mesh := BoxMesh.new()
	pn_mesh = MeshInstance3D.new()
	pn_material = StandardMaterial3D.new()
	
	mesh.size = Vector3(0.2, 0.2, 0.2)
	pn_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	pn_mesh.mesh = mesh
	pn_mesh.set_surface_override_material(0, pn_material)
	
	add_child(pn_mesh)
	
func _exit_tree() -> void:
	pn_mesh.queue_free()
	pn_material = null
#endregion

#region PLUGIN CALLS
## ALERT: Plugin private function. Dont have any reason for you to use that.
func register_agent(agent:FlowAIAgent3D) -> void:
	m_agents.append(agent)
	reload_weight_scale()

## ALERT: Plugin private function. Dont have any reason for you to use that.
func unregister_agent(agent:FlowAIAgent3D) -> void:
	m_agents.erase(agent)
	reload_weight_scale()

## ALERT: Plugin private function. Dont have any reason for you to use that.
func reload_weight_scale() -> void:
	current_weight_scale = weight_scale_base + (m_agents.size() * weight_multiplier)
	flow_controller.current_astar.set_point_weight_scale(astar_id, current_weight_scale)
	
	if current_weight_scale == weight_scale_base:
		pn_material.albedo_color = Color(0, 1, 1)
	elif current_weight_scale < 5.0:
		pn_material.albedo_color = Color(0, 1, 0)
	else:
		pn_material.albedo_color = Color(1, 0, 0)

## ALERT: Plugin private function. Dont have any reason for you to use that.
func snap_to_ground() -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 2, global_position + Vector3.DOWN * 10)
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.get("collider")
		if collider is StaticBody3D: # I dont wanna the snap using characters as ground.
			global_position = result.position
		
#endregion

#region SIGNALS
func _on_node_tree_exiting():
	if Engine.is_editor_hint():
		var area:FlowAIAreaNode = flow_controller.all_areas[areaID - 1]
		var prev:FlowAIPathNode = flow_controller.all_pathnodes[prev_pathnode - 1]
		
		if flow_controller.all_pathnodes.has(self):
			flow_controller.all_pathnodes.erase(self)
		
		if prev.links.has(ID):
			prev.links.erase(ID)
		
		if area.area_pathnodes.has(ID):
			area.area_pathnodes.erase(ID)
#endregion
