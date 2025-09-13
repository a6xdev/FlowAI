@tool
extends Marker3D
class_name FlowAIPathNode

@export var active:bool = true

@export var ID:int = 0
@export var areaID:int = 0
@export var prev_pathnode:int = 0
@export var links:Array[int] = []

@export var flowAI_controller:FlowAIController = null

var linked_lines_mesh:MeshInstance3D = null
var pn_mesh:MeshInstance3D = null
var pn_material:StandardMaterial3D = null
var line_mesh:ImmediateMesh = null

func _ready() -> void:
	tree_exiting.connect(_on_node_tree_exiting)

func _enter_tree() -> void:
	var mesh := BoxMesh.new()
	pn_mesh = MeshInstance3D.new()
	pn_material = StandardMaterial3D.new()
	line_mesh = ImmediateMesh.new()
	linked_lines_mesh = MeshInstance3D.new()
	
	mesh.size = Vector3(0.2, 0.2, 0.2)
	pn_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	pn_mesh.mesh = mesh
	pn_mesh.set_surface_override_material(0, pn_material)
	
	add_child(pn_mesh)
	
func _exit_tree() -> void:
	pn_mesh.queue_free()
	linked_lines_mesh.queue_free()
	pn_material = null

func _on_node_tree_exiting():
	if Engine.is_editor_hint():
		var area:FlowAIAreaNode = flowAI_controller.all_areas[areaID - 1]
		var prev:FlowAIPathNode = flowAI_controller.all_pathnodes[prev_pathnode - 1]
		
		if flowAI_controller.all_pathnodes.has(self):
			flowAI_controller.all_pathnodes.erase(self)
			print("pathnode erased")
		
		if prev.links.has(ID):
			prev.links.erase(ID)
		
		if area.area_pathnodes.has(ID):
			area.area_pathnodes.erase(ID)
