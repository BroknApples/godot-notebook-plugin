@tool
extends HBoxContainer

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Add a new chunk of notes to a note
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const spacer_template = preload("res://addons/godot-notebook/scenes/note_block_spacer.tscn")

@onready var root = $"." ## HBoxContainer that contains the spacers to correctly tab the Note
@onready var show_children_button = $VBoxContainer/HBoxContainer/Button ## Button that opens and closes the text data
@onready var text_edit = $VBoxContainer/HBoxContainer/TextEdit ## Actual note data
@onready var child_vbox = $VBoxContainer/VBoxContainer ## VBoxContainer that contains all the child note data

const NOTE_BLOCK_META_TAG: String = "NoteBlock"
const SPACER_INDEX: int = 3
const MINIMUM_TEXT_EDIT_HEIGHT: int = 40

var tab_level := 0
var char_count := 0 # TODO
var word_count := 0 # TODO

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Set child note blocks visibility
func _on_button_toggled(toggled_on: bool) -> void:
	child_vbox.visible = toggled_on
	if (toggled_on):
		show_children_button.text = "   v   "
	else:
		show_children_button.text = "   >   "

## Remove a spacer
func _on_tab_out_button_pressed() -> void:
	_removeSpacer()

## Add a spacer
func _on_tab_in_button_pressed() -> void:
	_addSpacer()

## Auto resize text edit with new lines when added
func _on_text_edit_text_changed() -> void:
	const MIN_HEIGHT: int = 40  # Base height
	var text_height: int = text_edit.get_line_count() * text_edit.get_line_height() + (MINIMUM_TEXT_EDIT_HEIGHT/3)
	text_edit.custom_minimum_size.y = max(MIN_HEIGHT, text_height)

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Set indentation level of the drop-down style button
func _setTabLevel(new_tab_level: int) -> void:
	tab_level = new_tab_level

## Add a spacer from the HBoxContainer that formats the button
func _addSpacer() -> void:
	# Create new spacer instance
	var spacer_instance = spacer_template.instantiate()
	root.add_child(spacer_instance)
	
	# Move to front of HBoxContainer
	root.move_child(spacer_instance,  SPACER_INDEX)
	tab_level += 1

## Remove a spacer from the HBoxContainer that formats the button
func _removeSpacer() -> void:
	# Check if there are no spacers
	if (root.get_child_count() <= 4): return
	
	var spacer_instance = root.get_child(SPACER_INDEX)
	root.remove_child(spacer_instance)
	tab_level -= 1

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Add a note block meta tag and other misc
func _ready() -> void:
	root.set_meta(NOTE_BLOCK_META_TAG, true)
	text_edit.custom_minimum_size.y = MINIMUM_TEXT_EDIT_HEIGHT

# ************************************************************ #
#                    * Public Functions *                      #
# ************************************************************ #

## Return the data held in the current
## Calls child getData notes as well
func getData(tabs: int) -> String:
	# TODO: Fix text formatting
	var str: String
	
	# Add tabs
	for i in range(tabs + tab_level):
		str += "\t"
	
	# Get current node data
	str += text_edit.text
	if (child_vbox.get_child_count() > 1):
		str += '\n'
		# Get all child node data
		for child in child_vbox.get_children():
			if (child.has_meta(NOTE_BLOCK_META_TAG)):
				str += child.getData(tabs + 1)
				
				# If this child node is the last one in the list, then do not add an extra newline
				if (child != child_vbox.get_child(child_vbox.get_child_count() - 1)):
					str += '\n'
			else:
				print("Invalid child node in note tree.")
	return str
