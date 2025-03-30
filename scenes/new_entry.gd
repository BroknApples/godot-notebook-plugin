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

const NOTE_BLOCK_TEMPLATE = preload("res://addons/godot-notebook-plugin/scenes/note_block.tscn")

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
	var note_block_instance := NOTE_BLOCK_TEMPLATE.instantiate()
	
	# Add new note block to parent vbox
	parent.add_child(note_block_instance)
	
	# Find root node and set the delete status
	var node: Control = self
	while !node.has_meta("NotebookRoot"):
		node = node.get_parent()
	note_block_instance.setDeleteMode(node.getDeleteMode())
	
	parent.move_child(note_block_instance, list_size - 1)

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
