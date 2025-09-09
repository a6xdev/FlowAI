extends Node
class_name FlowAIAreaNode

@export var area_resource:AreaNodeData

func create_astar() -> AStar3D:
	if area_resource.area_pathnodes.size() > 0:
		var new_astar := AStar3D.new()
		
		# Add point logic
		for pathnode_path in area_resource.area_pathnodes:
			var pathnode:FlowAIPathNode = get_node_or_null(pathnode_path)
			if pathnode:
				var id_a:int = pathnode.get_instance_id()
				new_astar.add_point(id_a, pathnode.global_position)
				
				# Connect point logic
				for neighbor_path in pathnode.pathnode_resource.pathnode_links:
					var neighbor:FlowAIPathNode = get_node_or_null(neighbor_path)
					var id_b = neighbor.get_instance_id()
					if not new_astar.are_points_connected(id_a, id_b):
						new_astar.connect_points(id_a, id_b, true)
					
		return new_astar
	return null
