@tool
extends Marker3D
class_name FlowAIPathNode

@export var pathnode_resource:PathNodeData

var linked_lines_mesh:MeshInstance3D = null
var pn_mesh:MeshInstance3D = null
var pn_material:StandardMaterial3D = null
var line_mesh:ImmediateMesh = null

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

func show_links():
	if not pathnode_resource.pathnode_links.is_empty():
		line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for nodepath in pathnode_resource.pathnode_links:
			var node:FlowAIPathNode = get_node_or_null(nodepath)
			var end_pos = node.global_position
			
			line_mesh.surface_set_color(Color.BLUE)
			line_mesh.surface_add_vertex(global_position)
			
			line_mesh.surface_set_color(Color.BLUE)
			line_mesh.surface_add_vertex(end_pos)
		
		line_mesh.surface_end()
		linked_lines_mesh.mesh = line_mesh
