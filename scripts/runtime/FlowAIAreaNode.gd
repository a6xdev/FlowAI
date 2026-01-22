@tool
@icon("res://addons/FlowAI/assets/icons/area_icon.svg")
extends Node3D
class_name FlowAIAreaNode

@export var flow_controller:FlowAIController = null

@export_group("Debug")
@export var line_color:Color = Color(0, 1, 0)

var ID:int = 0 ## Unique ID
var area_pathnodes:Array[int] = [] ## All pathnodes in this area

var m_line_mesh:MeshInstance3D = null
var m_line_immediate:ImmediateMesh = null
var m_material:StandardMaterial3D = null

#region GODOT FUNCTIONS
func _ready() -> void:
	if Engine.is_editor_hint() or flow_controller.show_pathnode_lines_in_game: 
		m_line_mesh = MeshInstance3D.new()
		m_line_immediate = ImmediateMesh.new()
		m_material = StandardMaterial3D.new()
		
		m_material.no_depth_test = true
		m_material.vertex_color_use_as_albedo = true
		m_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
		#pn_line_mesh.top_level = true
		m_line_mesh.mesh = m_line_immediate
		add_child(m_line_mesh)
	
	tree_exiting.connect(_on_node_tree_exiting)

func _exit_tree() -> void:
	if m_line_mesh: m_line_mesh.queue_free()
	m_line_immediate = null
	m_material = null

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and not flow_controller.show_pathnode_lines_in_game and not m_line_immediate:
		return

	var vertex_count = 0
	m_line_immediate.clear_surfaces()
	m_line_mesh.global_transform = Transform3D.IDENTITY
	m_line_immediate.surface_begin(Mesh.PRIMITIVE_LINES)

	for pathnode_id in area_pathnodes:
		var pathnode: FlowAIPathNode = flow_controller.all_pathnodes.get(pathnode_id - 1)
		
		if pathnode and not pathnode.links.is_empty():
			for link_id in pathnode.links:
				var index = link_id - 1
				if index >= 0 and index < flow_controller.all_pathnodes.size():
					var next_pathnode = flow_controller.all_pathnodes[index]
					
					if next_pathnode:
						m_line_immediate.surface_set_color(line_color)
						m_line_immediate.surface_add_vertex(pathnode.global_position)
						
						m_line_immediate.surface_set_color(line_color)
						m_line_immediate.surface_add_vertex(next_pathnode.global_position)
						
						vertex_count += 2
	
	if vertex_count > 0:
		if m_line_mesh.get_surface_override_material(0) == null:
			m_line_mesh.set_surface_override_material(0, m_material)
		m_line_immediate.surface_end()
	else:
		m_line_immediate.clear_surfaces()
#endregion

#region CALLS
#endregion

#region SIGNALS
func _on_node_tree_exiting():
	if flow_controller.all_areas.has(self):
		flow_controller.all_areas.erase(self)
#endregion
