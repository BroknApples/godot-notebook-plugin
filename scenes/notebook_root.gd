@tool
extends Control

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

const NEW_NOTE_TEMPLATE := preload("res://addons/godot-notebook/scenes/new_note.tscn")

@onready var tab_container := $HBoxContainer/TabContainer

const NOTES_DIRECTORY = "res://addons/godot-notebook/notes"

var total_word_count := 0
var total_char_count := 0

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Save data to file
func _on_save_button_pressed() -> void:
	_saveNote()

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
func _loadNote(note_name: String) -> void:
	# Load a note from a file
	pass

## Save the current note to a file
func _saveNote() -> void:
	# Get note data
	var target_tab_index = tab_container.current_tab
	if (target_tab_index == -1): return # Invalid tab choice
	var target_tab = tab_container.get_child(target_tab_index)
	
	var note_data = _getNoteData(target_tab)
	print("Saving...\n\n" + note_data)

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

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #
