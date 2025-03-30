@tool
extends EditorPlugin

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Write notes right in the godot editor in a more GUI centered way.
## Instantiates the main scene
## 

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const NOTEBOOK_ROOT := preload("res://addons/godot-notebook/scenes/notebook_root.tscn")
var root_instance: Control

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Initialize plugin
func _enter_tree():
	# Setup plugin
	root_instance = NOTEBOOK_ROOT.instantiate()
	root_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
	EditorInterface.get_editor_main_screen().add_child(root_instance)
	_make_visible(false)

## Cleanup
func _exit_tree():
	if (root_instance):
		root_instance.queue_free()

## Is this a main screen plugin
func _has_main_screen():
	return true

## Change visibilty of plugin
func _make_visible(visible: bool):
	if (root_instance):
		root_instance.visible = visible

## What is the name of the plugin
func _get_plugin_name():
	return "Notebook"

## Get the icon that appears in the top middle of the screen
func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
