extends EditorInspectorPlugin

func _can_handle(object) -> bool:
	return object is FlowAIController or object is FlowAIAreaNode or object is FlowAIPathNode

func _parse_begin(object):
	if object is FlowAIController:
		var save_resource_btn := Button.new()
		var load_resource_btn := Button.new()
		var add_area_btn := Button.new()
		
		load_resource_btn.text = "Load Data"
		add_area_btn.text = "Add Area"
		
		# Save current data
		save_resource_btn.pressed.connect(func():
			object.save_data()
			)
			
		# Load current data
		load_resource_btn.pressed.connect(func():
			object.load_data()
			)
		
		# Create Area
		add_area_btn.pressed.connect(func():
			var new_area = object.create_area()
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_area)
		)
		
		add_custom_control(save_resource_btn)
		add_custom_control(load_resource_btn)
		add_custom_control(add_area_btn)
	
	elif object is FlowAIAreaNode:
		var add_pathnode_btn := Button.new()
		var snap_all_pahtnodes_to_ground := Button.new()
		
		# Create Pathnode
		add_pathnode_btn.text = "Add PathNode"
		snap_all_pahtnodes_to_ground.text = "Snap All Pathnodes to Ground"
		
		add_pathnode_btn.pressed.connect(func():
			var new_pathnode = object.flow_controller.create_pathnode(object)
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_pathnode)
			)
		
		snap_all_pahtnodes_to_ground.pressed.connect(func():
			for node in object.get_children():
				if node is FlowAIPathNode:
					node.snap_to_ground()
			)
		
		add_custom_control(add_pathnode_btn)
		add_custom_control(snap_all_pahtnodes_to_ground)
	
	elif object is FlowAIPathNode:
		var pathnode_id = object.ID
		var pathnode_links = object.links
		var controller:FlowAIController = object.flow_controller
		var area:FlowAIAreaNode = controller.all_areas[object.areaID - 1]
		var prev:FlowAIPathNode = controller.all_pathnodes[object.prev_pathnode - 1] if area.area_pathnodes.size() != 1 else null
		
		# Inspector UI
		var add_next_pathnode := Button.new()
		var snap_to_ground := Button.new()
		var pathnode_id_label := Label.new()
		var pathnode_area_owner_label := Label.new()
		var pathnode_prev_label := Label.new()
		
		var links_list_title := Label.new()
		var links_list_vertical := VBoxContainer.new()
		
		add_next_pathnode.text = "Add Next Pathnode"
		snap_to_ground.text = "Snap to Ground"
		pathnode_id_label.text = "PathnodeID: " + str(pathnode_id)
		pathnode_area_owner_label.text = "AreaID: " + str(object.areaID)
		pathnode_prev_label.text = "Previous PathNode: " + str(prev.name) if object.ID != 1 and area.area_pathnodes.size() > 1 else "Previous Pathnode: Nil"
		links_list_title.text = "Links: [Array] - " + str(pathnode_links.size())
		
		# Logic to show all nodes that are linked to the selected pathnode
		for id in pathnode_links:
			var pathnode = controller.all_pathnodes[id - 1]
			if pathnode != null:
				var pathnode_label := Label.new()
				pathnode_label.text = "  >  " + "[" + str(id - 1) + "]:  " + str(pathnode.name)
				links_list_vertical.add_child(pathnode_label)
		
		# To create a new pathnode that will be automatically connected to the selected pathnode.
		add_next_pathnode.pressed.connect(func():
			var new_pathnode = controller.create_pathnode(area, object, {})
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_pathnode)
			)
		
		snap_to_ground.pressed.connect(func():
			object.snap_to_ground()
			)
		
		add_custom_control(pathnode_id_label)
		add_custom_control(pathnode_area_owner_label)
		add_custom_control(pathnode_prev_label)
		add_custom_control(links_list_title)
		add_custom_control(links_list_vertical)
		add_custom_control(add_next_pathnode)
		add_custom_control(snap_to_ground)
