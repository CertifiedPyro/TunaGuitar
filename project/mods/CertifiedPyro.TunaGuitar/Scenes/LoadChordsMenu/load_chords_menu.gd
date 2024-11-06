extends Control


signal preset_loaded(preset_name, saved_shapes)

const GuitarMinigame = preload("res://Scenes/Minigames/Guitar/guitar_minigame.gd")
const PlayerHud = preload("res://Scenes/HUD/playerhud.gd")
const PresetsList = preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/PresetsList/presets_list.gd")

const file_path: String = "user://tunaguitar.json"

onready var player_hud := $"/root/playerhud" as PlayerHud
onready var guitar := $"/root/playerhud/guitar" as GuitarMinigame
onready var presets_list := $"%PresetsList" as PresetsList
onready var load_button := $"%LoadButton" as Button


func _ready() -> void:
	self.visible = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if self.visible and event.is_action_pressed("esc_menu"):
		get_tree().set_input_as_handled()
		self._on_exit_button_pressed()


func open_menu() -> void:
	presets_list.refresh_presets()
	load_button.disabled = true
	self.visible = true
	self._enter_menu_state()


func _on_exit_button_pressed() -> void:
	self.visible = false
	self._exit_menu_state()


func _on_load_button_pressed() -> void:
	# Activate preset so we can actually get the preset name and shapes.
	presets_list.activate_preset()


# Run when tree item is double-clicked.
func _on_preset_activated(preset_name: String, saved_shapes: Array) -> void:
	guitar.saved_shapes = saved_shapes.duplicate(true)
	guitar._select_shape(guitar.selected_shape)
	
	PlayerData._send_notification("Loaded preset from file!")
	emit_signal("preset_loaded", preset_name, saved_shapes)
	self._on_exit_button_pressed()


func _on_preset_selected(preset_name: String, saved_shapes: Array) -> void:
	load_button.disabled = false


func _on_preset_deselected() -> void:
	load_button.disabled = true


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
