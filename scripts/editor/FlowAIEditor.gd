extends EditorInspectorPlugin

func _can_handle(object) -> bool:
	return object is FlowAIController or object is FlowAIAreaNode or object is FlowAIPathNode

func _parse_begin(object):
	if object is FlowAIController:
		var save_resource_btn := Button.new()
		var load_resource_btn := Button.new()
		var add_area_btn := Button.new()
		#var debug_checkbox := CheckButton.new()
		
		#debug_checkbox.text = "Active Debug"
		save_resource_btn.text = "Save Resource"
		load_resource_btn.text = "Load Resource"
		add_area_btn.text = "Add Area"
		
		#debug_checkbox.pressed.connect(func():
			#if not debug_checkbox.button_pressed == false:
				#print("aa")
		#)
		
		save_resource_btn.pressed.connect(func():
			object.save_data()
			)
			
		load_resource_btn.pressed.connect(func():
			object.load_data()
			)
		
		add_area_btn.pressed.connect(func():
			var new_area = object.create_area()
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_area)
		)
		
		#add_custom_control(debug_checkbox)
		add_custom_control(save_resource_btn)
		add_custom_control(load_resource_btn)
		add_custom_control(add_area_btn)
	
	elif object is FlowAIAreaNode:
		var add_pathnode_btn := Button.new()
		add_pathnode_btn.text = "Add PathNode"
		add_pathnode_btn.pressed.connect(func():
			var new_pathnode = object.flowAI_controller.create_pathnode(object)
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_pathnode)
			)
		
		add_custom_control(add_pathnode_btn)
	
	elif object is FlowAIPathNode:
		var pathnode_id = object.ID
		var pathnode_links = object.links
		
		var controller:FlowAIController = object.flowAI_controller
		var area:FlowAIAreaNode = controller.all_areas[object.areaID - 1]
		var prev:FlowAIPathNode = controller.all_pathnodes[object.prev_pathnode - 1] if area.area_pathnodes.size() != 1 else null
		
		# UI
		var add_next_pathnode := Button.new()
		var pathnode_id_label := Label.new()
		var pathnode_area_owner_label := Label.new()
		var pathnode_prev_label := Label.new()
		
		var links_list_title := Label.new()
		var links_list_vertical := VBoxContainer.new()
		
		add_next_pathnode.text = "Add Next Pathnode"
		pathnode_id_label.text = "PathnodeID: " + str(pathnode_id)
		pathnode_area_owner_label.text = "AreaID: " + str(object.areaID)
		pathnode_prev_label.text = "Previous PathNode: " + str(prev.name) if prev != null else "Previous Pathnode: Nil"
		links_list_title.text = "Links: [Array] - " + str(pathnode_links.size())
		
		for id in pathnode_links:
			var pathnode = controller.all_pathnodes[id - 1]
			if pathnode != null:
				var pathnode_label := Label.new()
				pathnode_label.text = "  >  " + "[" + str(id - 1) + "]:  " + str(pathnode.name)
				links_list_vertical.add_child(pathnode_label)
		
		add_next_pathnode.pressed.connect(func():
			var new_pathnode = controller.create_pathnode(area, object, {})
			if Engine.is_editor_hint():
				EditorInterface.edit_node(new_pathnode)
			)
		
		add_custom_control(pathnode_id_label)
		add_custom_control(pathnode_area_owner_label)
		add_custom_control(pathnode_prev_label)
		add_custom_control(links_list_title)
		add_custom_control(links_list_vertical)
		add_custom_control(add_next_pathnode)
