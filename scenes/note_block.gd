@tool
extends MarginContainer

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

const spacer_template = preload("res://addons/godot-notebook-plugin/scenes/note_block_spacer.tscn")

@onready var main_hbox = $HBoxContainer ## HBoxContainer that contains the spacers to correctly tab the Note
@onready var show_children_button = $HBoxContainer/VBoxContainer/HBoxContainer/Button ## Button that opens and closes the text data
@onready var text_edit = $HBoxContainer/VBoxContainer/HBoxContainer/TextEdit ## Actual note data
@onready var child_vbox = $HBoxContainer/VBoxContainer/VBoxContainer ## VBoxContainer that contains all the child note data
@onready var new_entry_button = $"HBoxContainer/VBoxContainer/VBoxContainer/NewEntry Button"
@onready var delete_button = $"Delete Button"

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
	var height = max(MIN_HEIGHT, text_height)
	text_edit.custom_minimum_size.y = height
	delete_button.custom_minimum_size.y = height

## Delete node -- If there are children, display a prompt
func _on_delete_button_pressed() -> void:
	if (child_vbox.get_child_count() > 1):
		print("This node contains children, deleting it will remove all child nodes... Confirm?")
	
	self.queue_free()

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
	main_hbox.add_child(spacer_instance)
	
	# Move to front of HBoxContainer
	main_hbox.move_child(spacer_instance,  SPACER_INDEX)
	tab_level += 1

## Remove a spacer from the HBoxContainer that formats the button
func _removeSpacer() -> void:
	# Check if there are no spacers
	if (main_hbox.get_child_count() <= 4): return
	
	var spacer_instance = main_hbox.get_child(SPACER_INDEX)
	main_hbox.remove_child(spacer_instance)
	tab_level -= 1

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Add a note block meta tag and other misc and set signals
func _ready() -> void:
	# Show Children Button
	if (!show_children_button.is_connected("toggled", _on_button_toggled)):
		show_children_button.connect("toggled", _on_button_toggled)
	
	# Tab Out Button
	var tab_out_button = $"HBoxContainer/TabOut Button"
	if (!tab_out_button.is_connected("pressed", _on_tab_out_button_pressed)):
		tab_out_button.connect("pressed", _on_tab_out_button_pressed)
	
	# Tab In Button
	var tab_in_button = $"HBoxContainer/TabIn Button"
	if (!tab_in_button.is_connected("pressed", _on_tab_in_button_pressed)):
		tab_in_button.connect("pressed", _on_tab_in_button_pressed)
	
	# Delete button
	if (!delete_button.is_connected("pressed", _on_delete_button_pressed)):
		delete_button.connect("pressed", _on_delete_button_pressed)
	
	# Set metadata and minimum size
	self.set_meta(NOTE_BLOCK_META_TAG, true)
	text_edit.custom_minimum_size.y = MINIMUM_TEXT_EDIT_HEIGHT
	

# ************************************************************ #
#                    * Public Functions *                      #
# ************************************************************ #

## Return the data held in the current
## Calls child getData notes as well
func getData(tabs: int) -> String:
	# Set tabs and text data
	var str: String = "\t".repeat(tabs + tab_level) + text_edit.text
	
	var child_data := []
	# Get all child node data
	for child in child_vbox.get_children():
		if (child.has_meta(NOTE_BLOCK_META_TAG) && child.get_meta(NOTE_BLOCK_META_TAG)):
			child_data.append(child.getData(tabs + 1))
	
	# Join child data
	if child_data.size() > 0:
		str += "\n" + "\n".join(child_data)
	
	return str

## Get the VBoxContainer holding all child nodes
func getNoteDataVBox() -> VBoxContainer:
	return child_vbox

func setDeleteMode(delete_mode: bool) -> void:
	delete_button.visible = delete_mode
	new_entry_button.disabled = delete_mode
