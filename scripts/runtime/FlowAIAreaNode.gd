@tool
@icon("res://addons/FlowAI/assets/icons/area_icon.svg")
extends Node3D
class_name FlowAIAreaNode

@export var a_data:FlowAIAreaData = null
@export var a_flow_controller:FlowAIController = null

@export_group("Debug")
@export var line_color:Color = Color(0, 1, 0)

var m_line_mesh:MeshInstance3D = null
var m_line_immediate:ImmediateMesh = null
var m_material:StandardMaterial3D = null

#region GODOT FUNCTIONS
func _enter_tree() -> void:
	if Engine.is_editor_hint() or a_flow_controller.show_pathnode_lines:
		m_line_mesh = MeshInstance3D.new()
		m_line_immediate = ImmediateMesh.new()
		m_material = StandardMaterial3D.new()
		
		m_material.no_depth_test = true
		m_material.vertex_color_use_as_albedo = true
		m_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
		#pn_line_mesh.top_level = true
		m_line_mesh.mesh = m_line_immediate
		add_child(m_line_mesh)

func _exit_tree() -> void:
	if m_line_mesh: m_line_mesh.queue_free()
	m_line_immediate = null
	m_material = null

func _process(delta: float) -> void:
	var is_in_editor:bool = Engine.is_editor_hint()
	
	if is_in_editor: _sanitize_all_links()
	
	if (not is_in_editor or not a_flow_controller.show_pathnode_lines) and not m_line_immediate:
		return
	
	if m_line_immediate: m_line_immediate.clear_surfaces()
	
	if a_flow_controller.show_pathnode_lines:
		var vertex_count = 0
		var pathnodes_list = _get_pathnodes_list()
		m_line_mesh.global_transform = Transform3D.IDENTITY
		m_line_immediate.surface_begin(Mesh.PRIMITIVE_LINES)
		
		for pathnode in get_children():
			if pathnode is FlowAIPathNode and not pathnode.p_data.p_links.is_empty():
				for link_id in pathnode.p_data.p_links:
					var next_pathnode = pathnodes_list[link_id]
					if next_pathnode:
						m_line_immediate.surface_set_color(line_color)
						m_line_immediate.surface_add_vertex(pathnode.global_position)
						
						m_line_immediate.surface_set_color(line_color)
						m_line_immediate.surface_add_vertex(next_pathnode.global_position)
						
						vertex_count += 2
		
		if vertex_count > 0:
			if m_line_mesh.get_surface_override_material_count() > 0:
				m_line_mesh.set_surface_override_material(0, m_material)
			m_line_immediate.surface_end()
		else:
			m_line_immediate.clear_surfaces()
#endregion

#region CALLS
func _sanitize_all_links() -> void:
	var area_pathnodes = _get_pathnodes_list()
	
	for id in area_pathnodes:
		var node:FlowAIPathNode = area_pathnodes[id]
		var data:FlowAIPathNodeData = node.p_data
		
		# Clean links that point to ID that dont exists
		var valid_links:Array = []
		for link_id in data.p_links:
			if area_pathnodes.has(link_id):
				valid_links.append(link_id)
		data.p_links = valid_links
		
		if data.p_prev_pathnode != "" and not area_pathnodes.has(data.p_prev_pathnode):
			data.p_prev_pathnode = ""

func _get_pathnodes_list() -> Dictionary:
	var pathnodes_list:Dictionary = {}
	for child in get_children():
		if child is FlowAIPathNode:
			pathnodes_list[child.p_data.p_id] = child
	return pathnodes_list
#endregion

#region SIGNALS
#endregion
