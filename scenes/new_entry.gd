@tool
extends Button

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## 
## 
## 
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const NOTE_BLOCK_TEMPLATE = preload("res://addons/godot-notebook/scenes/note_block.tscn")

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
	parent.move_child(note_block_instance, list_size - 1)

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #
