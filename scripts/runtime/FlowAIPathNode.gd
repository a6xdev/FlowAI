@tool
@icon("res://addons/FlowAI/assets/icons/pathnode_icon.svg")
extends Marker3D
class_name FlowAIPathNode

@export var active:bool = true

var ID:int = 0
var areaID:int = 0
var prev_pathnode:int = 0
var links:Array[int] = []

# Astar
var astar_id:int = 0
var astar_weight_scale:float = 1.0

@export var flowAI_controller:FlowAIController = null

# Just a mesh to better observe the nodes in the scene
var linked_lines_mesh:MeshInstance3D = null
var pn_mesh:MeshInstance3D = null
var pn_material:StandardMaterial3D = null

# TODO: LineMesh to better observe the FlowAIPathNode connections
#var line_mesh:ImmediateMesh = null

#region GODOT FUNCTIONS
func _ready() -> void:
	if not Engine.is_editor_hint():
		pn_mesh.visible = true if flowAI_controller.active_pathnode_shape else false
	
	tree_exiting.connect(_on_node_tree_exiting)

func _enter_tree() -> void:
	var mesh := BoxMesh.new()
	pn_mesh = MeshInstance3D.new()
	pn_material = StandardMaterial3D.new()
	linked_lines_mesh = MeshInstance3D.new()
	#line_mesh = ImmediateMesh.new()
	
	mesh.size = Vector3(0.2, 0.2, 0.2)
	pn_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	pn_mesh.mesh = mesh
	pn_mesh.set_surface_override_material(0, pn_material)
	
	add_child(pn_mesh)
	
func _exit_tree() -> void:
	pn_mesh.queue_free()
	linked_lines_mesh.queue_free()
	pn_material = null
#endregion

#region EDITOR CALLS
## Plugin private function. Dont have any reason for you to use that.
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
		var area:FlowAIAreaNode = flowAI_controller.all_areas[areaID - 1]
		var prev:FlowAIPathNode = flowAI_controller.all_pathnodes[prev_pathnode - 1]
		
		if flowAI_controller.all_pathnodes.has(self):
			flowAI_controller.all_pathnodes.erase(self)
		
		if prev.links.has(ID):
			prev.links.erase(ID)
		
		if area.area_pathnodes.has(ID):
			area.area_pathnodes.erase(ID)
#endregion
