@tool
extends MarginContainer

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Default template when creating a new page of notes
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var root := $"."
@onready var title_line_edit := $"VBoxContainer/HBoxContainer/Title LineEdit"
@onready var word_count_label := $"VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/WordCount Label"
@onready var char_count_label := $"VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/MarginContainer2/HBoxContainer/CharacterCount Label"
@onready var note_data_vbox := $VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer
@onready var new_entry_button := $"VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer/NewEntry Button"

var total_word_count := 0
var total_char_count := 0
var total_tab_level := 0

const UNSAVED_SYMBOL = "(*)"
var unsaved_changes := true

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Set new title
func _on_title_line_edit_text_submitted(new_text: String) -> void:
	if (new_text != ""):
		root.name = new_text
		saveData()

## Set new title
func _on_title_line_edit_focus_exited() -> void:
	if (title_line_edit.text != ""):
		root.name = title_line_edit.text
		_addUnsavedSymbol()

## Set visibility of the word count label
func _on_word_count_check_button_toggled(toggled_on: bool) -> void:
	word_count_label.visible = toggled_on

## Set visibility of the character count label
func _on_character_count_check_button_toggled(toggled_on: bool) -> void:
	char_count_label.visible = toggled_on

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Add an asterisk to the node name, indicating unsaved changes
func _addUnsavedSymbol() -> void:
	root.name += UNSAVED_SYMBOL

func _checkUnsavedSymbol() -> bool:
	# Data setup
	var name = root.name
	var length = name.length()
	
	# If length < 4, it cannot possible have an unsaved symbol
	if (length < 4): return false
	
	# If there is an unsaved symbol, return true
	if (name.substr(length - 3, length) == UNSAVED_SYMBOL):
		return true
	# else return false
	else:
		return false

## Remove the asterisk from after the name
func _removeUnsavedSymbol() -> void:
	# If there is no unsaved symbol, do not remove
	if (!_checkUnsavedSymbol()): return
	
	# Data setup
	var name: String = root.name
	var length := name.length()
	
	# If length < 4, it cannot possible have an unsaved symbol
	if (length < 4): return
	var substr: String = name.substr(length - 3, length)
	
	# If there is an unsaved symbol, remove it
	if (substr == UNSAVED_SYMBOL):
		root.name = substr

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Ensure signals are connected, bug has been occurring where they aren't
func _ready() -> void:
	# Title Line Edit
	if (!title_line_edit.is_connected("text_submitted", _on_title_line_edit_text_submitted)):
		title_line_edit.connect("text_submitted", _on_title_line_edit_text_submitted)
	if (!title_line_edit.is_connected("focus_exited", _on_title_line_edit_focus_exited)):
		title_line_edit.connect("focus_exited", _on_title_line_edit_focus_exited)
	
	# Word Count Button
	var word_count_button = $"VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/WordCount CheckButton"
	if (!word_count_button.is_connected("toggled", _on_word_count_check_button_toggled)):
		word_count_button.connect("toggled", _on_word_count_check_button_toggled)
	
	# Character Count button
	var char_count_button = $"VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/MarginContainer2/HBoxContainer/CharacterCount CheckButton"
	if (!char_count_button.is_connected("toggled", _on_character_count_check_button_toggled)):
		char_count_button.connect("toggled", _on_character_count_check_button_toggled)

# ************************************************************ #
#                    * Public Functions *                      #
# ************************************************************ #

## Save data to a file and show there are no longer unsaved changes
func saveData() -> void:
	unsaved_changes = false
	_removeUnsavedSymbol()

## Get the title of the note
func getTitle() -> String:
	return title_line_edit.text

## Get the VBoxContianer that holds all the note data
func getNoteDataVBox() -> VBoxContainer:
	return note_data_vbox

## Disable new entry buton in delete mode
func setDeleteMode(delete_status: bool) -> void:
	new_entry_button.disabled = delete_status
