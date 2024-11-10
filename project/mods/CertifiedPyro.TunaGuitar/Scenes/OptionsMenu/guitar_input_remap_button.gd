extends "res://Scenes/Singletons/OptionsMenu/input_remap_button.gd"


func _ready():
#	OptionsMenu.connect("_rebinding_key", self, "_input_check")

	default_action = InputMap.get_action_list(action)[0]

	add_to_group("input_remap")
	set_process_unhandled_key_input(false)
	_display_key()


func _on_input_forward_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = ". . ."
#		OptionsMenu.emit_signal("_rebinding_key", action)
	elif queued_action:
		text = _get_text(queued_action)
	else :
		_display_key()


func _unhandled_key_input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		pressed = false
		return 
	
	# Only check conflicts with guitar keybinds, rather than all global keybinds.
	for button in get_tree().get_nodes_in_group("guitar_input_remap"):
		if button != self:
			var valid = true
			if button.set_action and button.set_action.scancode == event.scancode: valid = false
			if button.queued_action and button.queued_action.scancode == event.scancode: valid = false
			if not valid:
				if button.default_action.scancode != event.scancode:
					button.queued_action = button.default_action
				else :
					button.queued_action = set_action
				
				button._on_input_forward_toggled(false)
	
	queued_action = event
	
	pressed = false
