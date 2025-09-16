@tool
@icon("res://addons/FlowAI/assets/icons/pathnode_icon.svg")
extends Marker3D
class_name FlowAIPathNode

@export var active:bool = true

var ID:int = 0
var areaID:int = 0
var prev_pathnode:int = 0
var links:Array[int] = []

@export var flowAI_controller:FlowAIController = null

# Just a mesh to better observe the nodes in the scene
var linked_lines_mesh:MeshInstance3D = null
var pn_mesh:MeshInstance3D = null
var pn_material:StandardMaterial3D = null

# TODO: LineMesh to better observe the FlowAIPathNode connections
#var line_mesh:ImmediateMesh = null

#region GODOT FUNCTIONS
func _ready() -> void:
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

#region SIGNALS
func _on_node_tree_exiting():
	if Engine.is_editor_hint():
		var area:FlowAIAreaNode = flowAI_controller.all_areas[areaID - 1]
		var prev:FlowAIPathNode = flowAI_controller.all_pathnodes[prev_pathnode - 1]
		
		if flowAI_controller.all_pathnodes.has(self):
			flowAI_controller.all_pathnodes.erase(self)
			if Engine.is_editor_hint():
				print("FlowAIPathNode - " + str(name) + " removed")
		
		if prev.links.has(ID):
			prev.links.erase(ID)
		
		if area.area_pathnodes.has(ID):
			area.area_pathnodes.erase(ID)
#endregion
