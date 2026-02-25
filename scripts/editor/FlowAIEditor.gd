extends EditorInspectorPlugin

func _can_handle(object) -> bool:
	return object is FlowAIController or object is FlowAIAreaNode or object is FlowAIPathNode

func _parse_begin(object):
	if object is FlowAIController:
		_parser_controller(object)
	elif object is FlowAIAreaNode:
		_parser_area(object)
	elif object is FlowAIPathNode:
		_parser_pathnode(object)

#region CALLS
func _parser_controller(controller:FlowAIController) -> void:
	var add_area_btn := Button.new()
	add_area_btn.text = "Add Area"

	# Add new area
	add_area_btn.pressed.connect(func():
		var new_area = controller._editor_add_area()
		if Engine.is_editor_hint():
			EditorInterface.edit_node(new_area)
	)
	
	add_custom_control(add_area_btn)

func _parser_area(area:FlowAIAreaNode) -> void:
		var _btn_add_new_pathnode := Button.new()
		var _btr_snap_all_pahtnodes_to_ground := Button.new()
		
		_btn_add_new_pathnode.text = "Add PathNode"
		_btr_snap_all_pahtnodes_to_ground.text = "Snap All Pathnodes to Ground"
		
		_btn_add_new_pathnode.pressed.connect(func():
			var new_pathnode = area.a_flow_controller._editor_add_pathnode(area)
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_pathnode)
			)
		
		_btr_snap_all_pahtnodes_to_ground.pressed.connect(func():
			for node in area.get_children():
				if node is FlowAIPathNode:
					node._snap_to_ground()
			)
		
		add_custom_control(_btn_add_new_pathnode)
		add_custom_control(_btr_snap_all_pahtnodes_to_ground)

func _parser_pathnode(pathnode:FlowAIPathNode) -> void:
		var pathnode_id = pathnode.p_data.p_id
		var pathnode_links = pathnode.p_data.p_links
		var controller:FlowAIController = pathnode.p_flow_controller
		var areas_list = controller._get_areas_list()
		var pathnodes_list = controller._get_pathnodes_list()
		var area_id = pathnode.p_data.p_area_id
		var area:FlowAIAreaNode = areas_list[area_id]
		var prev:FlowAIPathNode = pathnodes_list[pathnode.p_data.p_prev_pathnode] if pathnode.p_data.p_prev_pathnode != "" else null
		
		# Inspector UI
		var _btn_add_next_pathnode := Button.new()
		var _btn_snap_to_ground := Button.new()
		var _label_pathnode_id := Label.new()
		var _label_pathnode_area_owner := Label.new()
		var _label_pathnode_prev := Label.new()
		
		var _label_links_list_title := Label.new()
		var _vbox_links_list_vertical := VBoxContainer.new()
		
		_btn_add_next_pathnode.text = "Add Next Pathnode"
		_btn_snap_to_ground.text = "Snap to Ground"
		_label_pathnode_id.text = "PathnodeID: " + str(pathnode_id)
		_label_pathnode_area_owner.text = "AreaID: " + str(area_id)
		_label_pathnode_prev.text = "Previous PathNode: " + str(prev.name) if prev else "Previous Pathnode: Nil"
		_label_links_list_title.text = "Links: [Array] - " + str(pathnode_links.size())
		
		# Logic to show all nodes that are linked to the selected pathnode
		for id in pathnode_links:
			var pathnode_link = pathnodes_list[id]
			if pathnode != null:
				var pathnode_label := Label.new()
				pathnode_label.text = "  >  " + "[" + str(id) + "]:  " + str(pathnode.name)
				_vbox_links_list_vertical.add_child(pathnode_label)
		
		# To create a new pathnode that will be automatically connected to the selected pathnode.
		_btn_add_next_pathnode.pressed.connect(func():
			var new_pathnode = controller._editor_add_pathnode(area, pathnode)
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_pathnode)
			)
		
		_btn_snap_to_ground.pressed.connect(func():
			pathnode._snap_to_ground()
			)
		
		add_custom_control(_label_pathnode_id)
		add_custom_control(_label_pathnode_area_owner)
		add_custom_control(_label_pathnode_prev)
		add_custom_control(_label_links_list_title)
		add_custom_control(_vbox_links_list_vertical)
		add_custom_control(_btn_add_next_pathnode)
		add_custom_control(_btn_snap_to_ground)
#endregion
