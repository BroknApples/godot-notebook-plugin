@tool
extends Control

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Root scene of the notebook
## Will instantiate the rest of the scenes
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var tab_container := $HBoxContainer/TabContainer
@onready var delete_button := $"HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Delete Button"
@onready var delete_menu := $ConfirmDeleteMenu
@onready var yes_delete_button := $"ConfirmDeleteMenu/VBoxContainer/MarginContainer/HBoxContainer/Yes Button"
@onready var no_delete_button := $"ConfirmDeleteMenu/VBoxContainer/MarginContainer/HBoxContainer/No Button"
@onready var open_file_menu := $OpenFileMenu

const NEW_NOTE_TEMPLATE := preload("res://addons/godot-notebook-plugin/scenes/new_note.tscn")
const NOTE_BLOCK_TEMPLATE := preload("res://addons/godot-notebook-plugin/scenes/note_block.tscn")
const NOTES_DIRECTORY: String = "res://addons/godot-notebook-plugin/notes"

var save_file_path: String
var delete_node: Control = null
var total_word_count := 0
var total_char_count := 0

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Create new file
func _on_new_button_pressed() -> void:
	var new_note = NEW_NOTE_TEMPLATE.instantiate()
	tab_container.add_child(new_note)

## Open a note file
func _on_open_button_pressed() -> void:
	pass # Replace with function body.

## Save data to file
func _on_save_button_pressed() -> void:
	# Save file path has not been set yet, so prompt user to set path
	if (self.has_meta("SaveFilePath") && !self.get_meta("SaveFilePath")):
		print("Save file path not yet set.")
	
	_saveNote()

## Enter delete mode to delete note blocks
func _on_delete_button_toggled(toggled_on: bool) -> void:
	var target_tab_index = tab_container.current_tab
	if (target_tab_index == -1): return # Invalid tab choice
	var target_tab = tab_container.get_child(target_tab_index)
	
	_enterDeleteMode(target_tab, toggled_on)

## Do delete the node
func _on_yes_button_pressed() -> void:
	delete_node.queue_free()
	delete_menu.visible = false

## Don't delete the node
func _on_no_button_pressed() -> void:
	delete_node = null
	delete_menu.visible = false

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Display the notes in the notes directory on the screen
func _displayNotes() -> void:
	# TODO: Display folders in their own submenu
	var notes: Array = _getNotesInDirectory(NOTES_DIRECTORY)

## Display notes in the a given directory
## path: Path to the directory to check
## returns: a set-like Array
func _getNotesInDirectory(path: String) -> Array:
	var dir := DirAccess.open(path)
	var note_list: Array = []
	
	if (dir):
		dir.list_dir_begin()
		var file := dir.get_next()
		
		# Read files
		while file != "":
			if (dir.current_is_dir()):
				# File is a directory
				var inner_note_list: Array = _getNotesInDirectory(file)
				note_list.push_back(inner_note_list)
			else:
				note_list.push_back(file.get_basename())
		
		# Get next file
		file = dir.get_next()
	else:
		print("Failed to open directory: " + path)
	
	return note_list

## Load a note from a file and create a new tab
func _loadNote(note_path: String) -> void:
	var file = FileAccess.open(note_path, FileAccess.READ)
	
	var note_instance = NEW_NOTE_TEMPLATE.instantiate()
	var tab_index = tab_container.get_child_count()
	tab_container.add_child(note_instance)
	
	if (file):
		var data := file.get_as_text()
		var size := data.length()
		var i := 0 # Index counter
		var text: String = ""
		
		# File always contains
		# line1: 'Title'
		# line2: ''
		while (i < size):
			if (data[i] == '\n'): break # Not on line2 anymore
			text += data[i]
			i += 1
		i += 1 # Line 2
		
		# We should be on line 3 right now
		var prev_tab_level = 0
		var curr_tab_level = 0
		var parent_node: MarginContainer # This is a note block scene instance
		var curr_node: MarginContainer # This is a note block scene instance
		while (i < size):
			if (data[i] == '\t'):
				# Current char is a tab, so increase tab count
				curr_tab_level += 1 
			elif (data[i] == '\n'):
				# Set previous tab level to current and current tab level to 0
				# We are on a new line now
				prev_tab_level = curr_tab_level
				curr_tab_level = 0
				
				# Create new note block
				if (curr_tab_level > prev_tab_level):
					# Add at child of current VBoxContainer
					pass
				elif (curr_tab_level == prev_tab_level):
					# Add at current VBoxContainer
					pass
				else:
					# Add at parent VBoxContainer
					pass
				
			else:
				text += data[i]
			
			i += 1
	else:
		print("Could not open file: " + file)

## Save the current note to a file
func _saveNote() -> void:
	# TODO: Prohibit these chars
	# Invalid chars in windows filename
	# \ (backslash)
	# / (forward slash)
	# : (colon)
	# * (asterisk)
	# ? (question mark)
	# " (double quotation mark)
	# < (less than)
	# > (greater than)
	# | (pipe)
	
	# Get note data
	var target_tab_index = tab_container.current_tab
	if (target_tab_index == -1): return # Invalid tab choice
	var target_tab = tab_container.get_child(target_tab_index)
	var title = target_tab.getTitle()
	if (title == ""): return
	
	# Get filename
	var filename: String = NOTES_DIRECTORY + "/" + title + ".txt"
	var note_data = _getNoteData(target_tab)
	
	# Write to file
	print("Saving to " + filename)
	var file = FileAccess.open(filename, FileAccess.WRITE)
	
	if (file):
		file.store_string(note_data)
		file.close()
		print("File successfully saved!\n")
	else:
		print("Failed to open file: " + filename + "\n")

## Get the data contained in the current note
## target_tab: Target tab node to get the text data from
func _getNoteData(target_tab: MarginContainer) -> String:
	var str: String
	
	# Get title
	str += target_tab.getTitle() + "\n\n"
	
	# Get actual note data
	var notes_vbox: VBoxContainer = target_tab.getNoteDataVBox()
	for child in notes_vbox.get_children():
		if (!child.has_meta("NoteBlock")): continue ## Skip non-note-block nodes
		
		str += child.getData(0) + '\n' # Start initial tab level at 0
	return str

## Enter delete mode for the given tab
func _enterDeleteMode(target_tab: MarginContainer, delete_status: bool) -> void:
	target_tab.setDeleteMode(delete_status)
	var vbox: VBoxContainer = target_tab.getNoteDataVBox()
	for entry in vbox.get_children():
		if (entry.has_meta("NoteBlock") && entry.get_meta("NoteBlock")):
			entry.setDeleteMode(delete_status)
			
			if (entry.getNoteDataVBox().get_child_count() > 1):
				_enterDeleteMode(entry, delete_status)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# New Button
	var new_button = $"HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/New Button"
	if (!new_button.is_connected("pressed", _on_new_button_pressed)):
		new_button.connect("pressed", _on_new_button_pressed)
	
	# Open Button
	var open_button =$"HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Open Button"
	if (!open_button.is_connected("pressed", _on_open_button_pressed)):
		open_button.connect("pressed", _on_open_button_pressed)
	
	# Save Button
	var save_button = $"HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Save Button"
	if (!save_button.is_connected("pressed", _on_save_button_pressed)):
		save_button.connect("pressed", _on_save_button_pressed)
	
	# Delete Button
	if (!delete_button.is_connected("toggled", _on_delete_button_toggled)):
		delete_button.connect("toggled", _on_delete_button_toggled)
	
	# Set metadata
	self.set_meta("NotebookRoot", true)
	self.set_meta("SaveFilePath", false)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Is the notebook in delete mode?
func getDeleteMode() -> bool:
	return delete_button.button_pressed


## Display delete children prompt
## node: Node to delete
## count: number of children it has
func deleteChildrenPrompt(node: Control, count: int) -> void:
	if (open_file_menu.visible): return # Ensure the open file menu can't be visible
	
	delete_node = node
	delete_menu.visible = true
