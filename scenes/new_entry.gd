@tool
extends Button

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Create a new note block entry in a notebook
## 
## 
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# TODO: ERROR using this preload for some reason
#const NOTE_BLOCK_TEMPLATE := preload("res://addons/godot-notebook-plugin/scenes/note_block.tscn")

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Create a new text area
func _on_pressed() -> void:
	# Get parent list
	var parent: VBoxContainer = self.get_parent()
	if (parent is not VBoxContainer):
		print("ERROR: Parent of 'NewEntry Button' is not a VBoxContainer")
		return
	
	# list_size - 1 is the position of the new text_edit area
	var list_size := parent.get_child_count()
	
	# Create new note block
	var note_block_template := load("res://addons/godot-notebook-plugin/scenes/note_block.tscn")
	var note_block_instance = note_block_template.instantiate()
	
	# Add new note block to parent vbox
	parent.add_child(note_block_instance)
	parent.move_child(note_block_instance, list_size - 1)
	
	# Find root node and set the delete status
	var node: Control = self
	while !node.has_meta("NotebookRoot"):
		node = node.get_parent()
	var tab_container = node.get_node("HBoxContainer/TabContainer")
	var curr_tab = tab_container.get_child(tab_container.current_tab)
	
	if (note_block_instance.has_method("setDeleteMode")):
		note_block_instance.setDeleteMode(node.getDeleteMode())
	else:
		print("[GodotNotebookPlugin] ERROR: Could not set newly created text block to delete mode.")
	note_block_instance.setNote(curr_tab)

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Ensure the signal is connected, bug has been occurring where it isn't
func _ready() -> void:
	# Root Button
	if (!self.is_connected("pressed", _on_pressed)):
		self.connect("pressed", _on_pressed)
