# FlowAI 1.3.0

FlowAI is a node-based (Pathnode) navigation plugin for NPCs in Godot 4. Unlike the native NavigationServer, FlowAI provides precise, visual, and manual control over the exact routes and flows your NPCs can follow.

Version 1.3.0 introduces a major architectural overhaul, ensuring data stability, reliability, and security. The Debug system has been significantly improved to help visualize and implement Pathnodes, making the plugin more consistent and developer-friendly.

## Installation
1. Download the repository and copy the flow_ai folder into your project's ``addons`` directory.

2. Go to ``Project Settings > Plugins`` and enable FlowAI.

## Core Components
Once enabled, four new nodes will be available:

- FlowAIController: The central brain of the system. Selecting this node allows you to manage navigation areas via the Inspector. It includes global Debug toggles:
  - ``show_pathnode_lines``: Visualize connections between nodes.
  - ``show_pathnode_shape``: Show the physical boundaries of nodes.
  - ``show_pathnode_label``: Display IDs and metadata in the 3D viewport.
- *FlowAIArea*: Defines a specific navigation sector or neighborhood. It features quick Pathnode creation and Auto-Snap tools to align nodes to your terrain. It also supports a ``Transform Parent``, allowing the entire navigation graph to follow moving objects like ships or elevators.
- *FlowAIPathnode*: Individual points in your graph. They store link data, previous nodes, and Area ownership. You can easily branch paths by creating new nodes that inherit the properties of the selected one.
- *FlowAIAgent3D*: The component added as a child of your ``CharacterBody3D`` to handle movement logic and path requests.

> [!TIP]
> Quick Linking: You can connect two existing pathnodes by selecting both in the SceneTree (Hold Ctrl). A "Link Pathnodes" button will appear in the 3D viewport toolbar for instant connection.

## Moving the Agent
In your ``CharacterBody3D`` script, you can implement random wandering or set specific targets:

```GDScript
func _ready() -> void:
    # Starts a random path within the configured area
    flow_ai_agent.get_random_path()

func _physics_process(delta):
    # Check if the NPC has reached the end of the current path
    if flow_ai_agent.is_path_complete():
        flow_ai_agent.get_random_path()

    # Get the next world position in the calculated path
    var target_pos = flow_ai_agent.get_next_path_position()
    var direction = (target_pos - global_position).normalized()
    
    velocity = direction * speed
    move_and_slide()
```

Tip: To force an NPC to move to a specific pathnode, use ``flow_ai_agent.set_goal_pathnode(pathnode_target)``.

## Debugging
FlowAI 1.3.0 includes an integrated debug system to visualize navigation flows in real-time. Make sure to check the Debug Group in the ``FlowAIController`` to see your pathnode network during development.

## Credits
Internal Debug System: Powered by a modified version of the ``DebugDraw`` utility by *Zylann* [Github](https://github.com/Zylann/godot_debug_draw).