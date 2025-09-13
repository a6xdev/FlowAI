@tool
extends EditorPlugin

var flowai_inspector_plugin

var connect_pathnodes_btn := Button.new()

func _enter_tree() -> void:
	flowai_inspector_plugin = preload("res://addons/FlowAI/scripts/editor/FlowAIEditor.gd").new()
	connect_pathnodes_btn.text = "Connect Pathnodes"
	
	add_inspector_plugin(flowai_inspector_plugin)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, connect_pathnodes_btn)

func _exit_tree() -> void:
	remove_inspector_plugin(flowai_inspector_plugin)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, connect_pathnodes_btn)
	
func _process(delta: float) -> void:
	var nodes_selected:Array = get_editor_interface().get_selection().get_selected_nodes()
	var pathnodes_selected:Array[FlowAIPathNode] = []
	
	for node in nodes_selected:
		if node is FlowAIPathNode:
			pathnodes_selected.append(node)
	
	if nodes_selected.is_empty():
		pathnodes_selected.clear()
	
	# Connect Pathnodes
	if not pathnodes_selected.is_empty() and pathnodes_selected.size() == 2:
		connect_pathnodes_btn.show()
		var from_node = pathnodes_selected[0]
		var to_node = pathnodes_selected[1]
		
		connect_pathnodes_btn.pressed.connect(func():
			var controller:FlowAIController = from_node.flowAI_controller
			controller.connect_nodes(from_node, to_node)
			)
	else:
		connect_pathnodes_btn.hide()
		#push_warning("Select only 2 FlowAIPathNodes to connect")
