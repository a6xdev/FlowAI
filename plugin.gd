@tool
extends EditorPlugin

var flowai_inspector_plugin

func _enter_tree() -> void:
	flowai_inspector_plugin = preload("res://addons/FlowAI/scripts/editor/FlowAIEditor.gd").new()
	add_inspector_plugin(flowai_inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(flowai_inspector_plugin)
