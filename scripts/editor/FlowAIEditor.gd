extends EditorInspectorPlugin

func _can_handle(object) -> bool:
	return object is FlowAIController or object is FlowAIAreaNode or object is FlowAIPathNode

func _parse_begin(object):
	if object is FlowAIController:
		var add_area_btn := Button.new()
		var debug_checkbox := CheckButton.new()
		
		debug_checkbox.text = "Active Debug"
		add_area_btn.text = "Add Area"
		
		debug_checkbox.pressed.connect(func():
			if not debug_checkbox.button_pressed == false:
				print("aa")
		)
		
		add_area_btn.pressed.connect(func():
			object.add_area()
		)
		
		add_custom_control(debug_checkbox)
		add_custom_control(add_area_btn)
	
	elif object is FlowAIAreaNode:
		var add_pathnode_btn := Button.new()
		add_pathnode_btn.text = "Add PathNode"
		add_pathnode_btn.pressed.connect(func():
			var controller:FlowAIController = object.get_node_or_null(object.area_resource.pathnode_controller)
			controller.add_pathnode(object)
			)
		add_custom_control(add_pathnode_btn)
	
	elif object is FlowAIPathNode:
		# get pathnode info 
		var pathnode_id = object.pathnode_resource.pathnodeID
		var pathnode_links = object.pathnode_resource.pathnode_links
		var pathnode_area:FlowAIAreaNode = object.get_node_or_null(object.pathnode_resource.area_owner)
		var pathnode_prev = object.get_node_or_null(object.pathnode_resource.prev_pathnode)
		
		var area_id_label := Label.new()
		var pathnode_id_label := Label.new()
		var pathnode_prev_label := Label.new()
		var list_link_vertical := VBoxContainer.new()
		var title_list_label := Label.new()
		var add_next_pathnode_btn := Button.new()
		
		area_id_label.text = "AreaID: " + str(pathnode_area.area_resource.areaID)
		pathnode_id_label.text = "PathNodeID: " + str(pathnode_id)
		pathnode_prev_label.text = "Previous PathNode: " + str(pathnode_prev.name) if pathnode_prev != null else "Previous PathNode: Nil"
		title_list_label.text = "Links [Array]:"
		
		for link in pathnode_links:
			var obj_link = object.get_node_or_null(link)
			if obj_link != null:
				var link_label := Label.new()
				link_label.text = "  >  " + "[" + str(pathnode_links.find(link)) + "] " + str(obj_link.name)
				list_link_vertical.add_child(link_label)
			
		add_next_pathnode_btn.text = "Add Next PathNode"
		add_next_pathnode_btn.pressed.connect(func():
			var area:FlowAIAreaNode = object.get_node_or_null(object.pathnode_resource.area_owner)
			var controller:FlowAIController = area.get_node_or_null(area.area_resource.pathnode_controller)
			controller.add_pathnode(area, object)
			)
		
		add_custom_control(area_id_label)
		add_custom_control(pathnode_id_label)
		add_custom_control(pathnode_prev_label)
		add_custom_control(title_list_label)
		add_custom_control(list_link_vertical)
		add_custom_control(add_next_pathnode_btn)
