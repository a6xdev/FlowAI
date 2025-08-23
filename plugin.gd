@tool
extends EditorPlugin

var current_waypoint_manager:FlowAIPedestrianWaypointManager = null
var selected_peds_waypoint:FlowAIPedestrianWaypoint = null

var fa_add_waypoint := Button.new()
var fa_add_next_waypoint := Button.new()
var fa_remove_waypoint := Button.new()
var fa_generate_mesh := Button.new()

#region GODOT FUNCTIONS
func _enter_tree() -> void:
	fa_add_waypoint.text = "AW"
	fa_add_next_waypoint.text = "ANW"
	fa_remove_waypoint.text = "RW"
	fa_generate_mesh.text = "GM"
	
	fa_add_waypoint.pressed.connect(_add_waypoint_pressed)
	fa_add_next_waypoint.pressed.connect(_add_next_waypoint_pressed)
	fa_remove_waypoint.pressed.connect(_remove_waypoint_pressed)
	fa_generate_mesh.pressed.connect(_generate_mesh_pressed)
	
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU , fa_add_waypoint)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU , fa_add_next_waypoint)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU , fa_remove_waypoint)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU , fa_generate_mesh)

func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_TOOLBAR, fa_add_waypoint)
	remove_control_from_container(CONTAINER_TOOLBAR, fa_add_next_waypoint)
	remove_control_from_container(CONTAINER_TOOLBAR, fa_remove_waypoint)
	remove_control_from_container(CONTAINER_TOOLBAR, fa_generate_mesh)
	
	fa_add_waypoint.queue_free()
	fa_add_next_waypoint.queue_free()
	fa_remove_waypoint.queue_free()

func _process(delta: float) -> void:
	#print(current_waypoint_manager)
	if Engine.is_editor_hint():
		var selected_node = get_editor_interface().get_selection().get_selected_nodes()
		var waypoint_manager_nodes = get_tree().get_nodes_in_group("FlowAIPedestrianWaypoint")
		
		if waypoint_manager_nodes.is_empty():
			current_waypoint_manager = null
			
		for node in waypoint_manager_nodes:
			if waypoint_manager_nodes.size() > 1:
				printerr("FLOW AI ALERT: There is more than 1 FlowAIPedestrianWaypointManager in the scene! Only 1 is allowed.")
			else:
				current_waypoint_manager = node
		
		for node in selected_node:
			if node is FlowAIPedestrianWaypoint:
				selected_peds_waypoint = node
			else:
				selected_peds_waypoint = null
	
	update_plugin_interface_visibility()
#endregion GODOT FUNCTIONS

#region CALLS
func update_plugin_interface_visibility() -> void:
	var waypoint_manager_visible:bool = current_waypoint_manager != null
	var waypoint_visible:bool = selected_peds_waypoint != null
	fa_generate_mesh.visible = waypoint_manager_visible
	fa_add_waypoint.visible = waypoint_manager_visible
	fa_add_next_waypoint.visible = waypoint_visible
	fa_remove_waypoint.visible = waypoint_visible
#endregion CALLS

#region SIGNALS
func _add_waypoint_pressed() -> void:
	if current_waypoint_manager:
		current_waypoint_manager.add_waypoint()

func _add_next_waypoint_pressed() -> void:
	if selected_peds_waypoint and current_waypoint_manager:
		current_waypoint_manager.add_next_waypoint(selected_peds_waypoint)

func _remove_waypoint_pressed() -> void:
	if selected_peds_waypoint and current_waypoint_manager:
		current_waypoint_manager.remove_waypoint(selected_peds_waypoint)

func _generate_mesh_pressed() -> void:
	if current_waypoint_manager:
		current_waypoint_manager.generate_mesh()
#endregion SIGNALS
