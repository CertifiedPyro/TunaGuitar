extends Control


signal preset_activated(preset_name, saved_shapes)
signal preset_selected(preset_name, saved_shapes)
signal preset_deselected()
signal preset_renamed(old_preset_name, new_preset_name)
signal preset_deleted(preset_name)

const CustomDialog = preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/PresetsList/custom_dialog.gd")

const rename_initial_texture := preload("res://Assets/Textures/Items/toolicons17.png")
const delete_initial_texture := preload("res://Assets/Textures/UI/player_options7.png")

const FILE_PATH: String = "user://tunaguitar.json"

var rename_texture: Texture
var delete_texture: Texture

# Map of preset name (string) to saved guitar shapes (array of arrays)
var presets_dict: Dictionary
var previous_selected_tree_item: TreeItem
var is_previous_selected_tree_item_selected: bool = false

onready var presets_tree := $"%PresetsTree" as Tree


func _ready() -> void:
	# Load the textures for the rename and delete buttons (for each preset's row).
	var rename_image := rename_initial_texture.get_data()
	rename_image.resize(24, 24)
	rename_texture = ImageTexture.new()
	rename_texture.create_from_image(rename_image)
	
	var delete_image = delete_initial_texture.get_data()
	delete_image.resize(24, 24)
	delete_texture = ImageTexture.new()
	delete_texture.create_from_image(delete_image)


# Load presets from file and populates the presets tree.
func refresh_presets() -> void:
	presets_tree.clear()

	var read_success = _read_presets_from_file()
	if not read_success:
		return

	var root := presets_tree.create_item()
	for key in presets_dict:
		var tree_item := presets_tree.create_item(root)
		tree_item.set_text(0, key)
		tree_item.add_button(0, rename_texture)
		tree_item.add_button(0, delete_texture)


# Async function, caller must ALWAYS YIELD.
# Save given preset to file, which might show a confirmation dialog if preset name already exists.
func save_preset(preset_name: String, saved_shapes: Array) -> bool:
	# Force callers to yield.
	yield(get_tree(), "idle_frame")
	
	# If preset name already exists, show confirmation dialog first.
	if presets_dict.has(preset_name):
		# Select item that will be overridden.
		# This is necessary if user presses the "Save" mod button (since menu is not open).
		var root := presets_tree.get_root()
		var tree_item := root.get_children()
		while tree_item != null:
			tree_item = tree_item as TreeItem
			if tree_item.get_text(0) == preset_name:
				presets_tree.scroll_to_item(tree_item)
				tree_item.select(0)
				break
			
			tree_item = tree_item.get_next()
		
		# Show confirmation dialog.
		var dialog := $"%OverwriteDialog" as CustomDialog
		dialog.popup("Are you sure you want to overwrite this preset:\n" + preset_name)
		
		# Wait for user to respond and confirm.
		var dialog_result := yield(dialog, "responded") as Array
		var confirmed := dialog_result[0] as bool
		if not confirmed:
			return false
	
	# Write presets to file.
	presets_dict[preset_name] = saved_shapes
	var write_success := _write_presets_to_file()
	if not write_success:
		return false
	
	PlayerData._send_notification("Saved preset to file!")
	return true


# Get the selected preset.
func activate_preset() -> void:
	var selected_item := presets_tree.get_selected()
	var preset_name := selected_item.get_text(0)
	var preset_shapes := (presets_dict[preset_name] as Array).duplicate(true)
	emit_signal("preset_activated", preset_name, preset_shapes)


# Run when tree item is double-clicked.
func _on_tree_item_activated() -> void:
	var selected_item := presets_tree.get_selected()
	
	# Selected item can be null if an item was selected, then user double-clicks.
	# In this case, select the item again.
	if selected_item == null:
		previous_selected_tree_item.select(0)
		is_previous_selected_tree_item_selected = false
		self._on_tree_item_selected()
		return
	
	self.activate_preset()


# Run when tree item is selected (only fires once on double-click).
func _on_tree_item_selected() -> void:
	var item := presets_tree.get_selected()
	
	if item == previous_selected_tree_item and is_previous_selected_tree_item_selected:
		# Deselect item if it's already selected.
		item.deselect(0)
		is_previous_selected_tree_item_selected = false
		emit_signal("preset_deselected")
	else:
		# Select the item.
		var preset_name := item.get_text(0)
		var preset_shapes := (presets_dict[preset_name] as Array).duplicate(true)
		previous_selected_tree_item = item
		is_previous_selected_tree_item_selected = true
		emit_signal("preset_selected", preset_name, preset_shapes)


# Run when no tree item is selected.
func _on_tree_nothing_selected() -> void:
	var item := presets_tree.get_selected()
	if item != null:
		item.deselect(0)
	
	previous_selected_tree_item = item
	is_previous_selected_tree_item_selected = false
	emit_signal("preset_deselected")


# Run when the rename or delete buttons on a tree item are pressed.
func _on_tree_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var preset_name = item.get_text(0)
	
	var button_index := item.get_button_by_id(column, id)
	if button_index == -1:
		return
	
	var button_texture := item.get_button(column, button_index)
	if button_texture == rename_texture:
		yield(_handle_rename_preset_request(preset_name), "completed")
	elif button_texture == delete_texture:
		yield(_handle_delete_preset_request(preset_name), "completed")


# Async function, caller must ALWAYS YIELD.
# Rename a preset and save to file, after showing a confirmation dialog.
func _handle_rename_preset_request(preset_name: String) -> void:
	# Show confirmation dialog.
	var dialog := $"%DeleteDialog" as CustomDialog
	dialog.popup("Enter the new name for this preset:", true, preset_name)
	
	# Wait for user to respond.
	var dialog_result := yield(dialog, "responded") as Array
	var confirmed := dialog_result[0] as bool
	if not confirmed:
		return
	
	# Rename the preset.
	var new_preset_name := dialog_result[1] as String
	var saved_chords := presets_dict[preset_name] as Array
	presets_dict.erase(preset_name)
	presets_dict[new_preset_name] = saved_chords
	
	# Write presets to file.
	var write_success = _write_presets_to_file()
	if not write_success:
		return
	
	emit_signal("preset_renamed", preset_name, new_preset_name)
	PlayerData._send_notification("Renamed preset!")
	self.refresh_presets()


# Async function, caller must ALWAYS YIELD.
# Delete a preset and save to file, after showing a confirmation dialog.
func _handle_delete_preset_request(preset_name: String) -> void:
	# Show confirmation dialog.
	var dialog := $"%DeleteDialog" as CustomDialog
	dialog.popup("Are you sure you want to delete this preset:\n" + preset_name)
	
	# Wait for user to respond.
	var dialog_result := yield(dialog, "responded") as Array
	var confirmed := dialog_result[0] as bool
	if not confirmed:
		return
	
	# Delete the preset and write presets to file.
	presets_dict.erase(preset_name)
	var write_success = _write_presets_to_file()
	if not write_success:
		return
	
	emit_signal("preset_deleted", preset_name)
	PlayerData._send_notification("Deleted preset from file!")
	self.refresh_presets()


func _read_presets_from_file() -> bool:
	var file := File.new()
	var error := file.open(FILE_PATH, File.READ)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		file.close()
		PlayerData._send_notification("Error opening tunaguitar.json!", 1)
		return false

	var json := file.get_as_text()
	file.close()
	
	# Handle case where user opens mod for first time (and file is created).
	if json.empty():
		presets_dict = {}
		return true
	
	var json_parse_result := JSON.parse(json)
	if json_parse_result.error != OK or not (json_parse_result.result is Dictionary):
		pass
	
	presets_dict = json_parse_result.result as Dictionary
	return true


func _write_presets_to_file() -> bool:
	var json := JSON.print(presets_dict, "", true)
	
	var file := File.new()
	if file.open(FILE_PATH, File.WRITE) != OK:
		file.close()
		PlayerData._send_notification("Error opening tunaguitar.json!", 1)
		return false
	
	file.store_string(json)
	file.close()
	return true
