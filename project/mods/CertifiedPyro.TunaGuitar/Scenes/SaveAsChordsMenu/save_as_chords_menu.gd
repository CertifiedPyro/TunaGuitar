extends Control

const PlayerHud = preload("res://Scenes/HUD/playerhud.gd")
const GuitarMinigame = preload("res://Scenes/Minigames/Guitar/guitar_minigame.gd")
const PresetsList = preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/PresetsList/presets_list.gd")

var last_activated_preset_name: String
var last_activated_preset_shapes: Array

onready var player_hud := $"/root/playerhud" as PlayerHud
onready var guitar := $"/root/playerhud/guitar" as GuitarMinigame
onready var presets_list := $"%PresetsList" as PresetsList
onready var preset_text_input := $"%PresetTextInput" as LineEdit
onready var save_button := $"%SaveButton" as Button


func _ready() -> void:
	self.visible = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if self.visible and event.is_action_pressed("esc_menu"):
		get_tree().set_input_as_handled()
		self._on_exit_button_pressed()


func open_menu() -> void:
	presets_list.refresh_presets()
	preset_text_input.clear()
	save_button.disabled = true
	self.visible = true
	self._enter_menu_state()


# Async function, caller must ALWAYS YIELD.
# Overwrites the last selected preset, after showing a confirmation dialog.
func overwrite_current_preset() -> void:
	if last_activated_preset_name.empty():
		PlayerData._send_notification("Load a preset first!", 1)
		return
	
	var current_shapes = guitar.saved_shapes.duplicate(true)
	if self._are_shapes_equal(current_shapes, last_activated_preset_shapes):
		PlayerData._send_notification("No changes to preset detected!", 1)
		return
	
	self.open_menu()
	var saved = yield(presets_list.save_preset(last_activated_preset_name, current_shapes), "completed")
	if saved:
		last_activated_preset_shapes = current_shapes
	
	self._on_exit_button_pressed()


# Run if preset is activated outside of this menu (i.e. a preset is loaded in the load menu).
func handle_external_activated_preset(preset_name: String, saved_shapes: Array) -> void:
	last_activated_preset_name = preset_name
	last_activated_preset_shapes = saved_shapes


func _on_exit_button_pressed() -> void:
	self.visible = false
	self._exit_menu_state()


func _on_edit_text_changed(new_text: String) -> void:
	save_button.disabled = new_text.empty()
	presets_list._on_tree_nothing_selected()


# Async function, caller must ALWAYS YIELD.
func _on_save_button_pressed() -> void:
	var preset_name := preset_text_input.text
	var saved_shapes = guitar.saved_shapes.duplicate(true)
	
	var saved = yield(presets_list.save_preset(preset_name, saved_shapes), "completed")
	if saved:
		last_activated_preset_name = preset_name
		last_activated_preset_shapes = saved_shapes
		self._on_exit_button_pressed()


# Run when tree item is double-clicked.
func _on_preset_activated(preset_name, saved_shapes) -> void:
	self._on_save_button_pressed()


func _on_preset_selected(preset_name: String, saved_shapes: Array) -> void:
	preset_text_input.text = preset_name
	save_button.disabled = false


func _on_preset_renamed(old_preset_name, new_preset_name) -> void:
	if last_activated_preset_name == old_preset_name:
		last_activated_preset_name = new_preset_name


func _on_preset_deleted(preset_name) -> void:
	if last_activated_preset_name == preset_name:
		last_activated_preset_name = ""


func _are_shapes_equal(array1: Array, array2: Array) -> bool:
	if array1.size() != array2.size():
		return false
	
	for i in array1.size():
		var strings1 := array1[i] as Array
		var strings2 := array2[i] as Array
		if strings1.size() != strings2.size():
			return false
		
		for j in strings1.size():
			if strings1[j] != strings2[j]:
				return false
	
	return true


# Enters the menu state used by other vanilla menus (shop, etc.)
# This disables most keybinds, and also temporarily disables the guitar keybinds.
func _enter_menu_state() -> void:
	if player_hud != null:
		OptionsMenu.open = true
		player_hud.menu = PlayerHud.MENUS.EMOTE
		guitar.set_process(false)


# Exits the menu state.
func _exit_menu_state() -> void:
	if player_hud != null:
		OptionsMenu.open = false
		player_hud.menu = PlayerHud.MENUS.DEFAULT
		guitar.set_process(true)
