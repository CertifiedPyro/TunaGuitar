extends Control


const PlayerHud := preload("res://Scenes/HUD/playerhud.gd")
const GuitarMinigame := preload("res://Scenes/Minigames/Guitar/guitar_minigame.gd")

const FILE_PATH: String = "user://tunaguitar_keybinds.json"

var key_rebindings := {}

onready var player_hud := $"/root/playerhud" as PlayerHud
onready var guitar := $"/root/playerhud/guitar" as GuitarMinigame


func _ready() -> void:
	self.visible = false
	self.apply_saved_keybinds()


func _unhandled_key_input(event: InputEventKey) -> void:
	if self.visible and event.is_action_pressed("esc_menu"):
		get_tree().set_input_as_handled()
		self._on_exit_button_pressed()


func apply_saved_keybinds() -> void:
	var read_success := self._read_keybinds_from_file()
	if not read_success:
		return
	
	var nodes := get_tree().get_nodes_in_group("guitar_input_remap")
	for button in nodes:
		# Clear queued action, so it doesn't override current keybind.
		button.queued_action = null
		for remap_action in key_rebindings:
			if button.action == remap_action:
				var ek = InputEventKey.new()
				ek.scancode = key_rebindings[remap_action]
				button.queued_action = ek
	get_tree().call_group("guitar_input_remap", "_remap_key")


func open_menu() -> void:
	# Reload keybinds from file.
	self.apply_saved_keybinds()
	self.visible = true
	self._enter_menu_state()


func _on_exit_button_pressed() -> void:
	self.visible = false
	self._exit_menu_state()


func _on_apply_pressed() -> void:
	get_tree().call_group("guitar_input_remap", "_remap_key")
	yield (get_tree().create_timer(0.1), "timeout")
	
	key_rebindings = {}
	for button in get_tree().get_nodes_in_group("guitar_input_remap"):
		if button.set_action != button.default_action:
			key_rebindings[button.action] = button.set_action.scancode
	var write_success := self._write_keybinds_to_file()
	if not write_success:
		return false
	
	PlayerData._send_notification("Saved keybinds to file!")
	self._on_exit_button_pressed()


func _on_reset_pressed() -> void:
	for button in get_tree().get_nodes_in_group("guitar_input_remap"):
		button.queued_action = button.default_action
		button._on_input_forward_toggled(false)


func _read_keybinds_from_file() -> bool:
	var file := File.new()
	var error := file.open(FILE_PATH, File.READ)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		file.close()
		PlayerData._send_notification("Error opening tunaguitar_keybinds.json!", 1)
		return false

	var json := file.get_as_text()
	file.close()

	# Handle case where user opens mod for first time (and file is created).
	if json.empty():
		key_rebindings = {}
		return true

	var json_parse_result := JSON.parse(json)
	if json_parse_result.error != OK or not (json_parse_result.result is Dictionary):
		pass

	key_rebindings = json_parse_result.result as Dictionary
	return true


func _write_keybinds_to_file() -> bool:
	var json := JSON.print(key_rebindings, "", true)
	
	var file := File.new()
	if file.open(FILE_PATH, File.WRITE) != OK:
		file.close()
		PlayerData._send_notification("Error opening tunaguitar_keybinds.json!", 1)
		return false
	
	file.store_string(json)
	file.close()
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
