# Copying input_remap_button.gd because the parent's _unhandled_key_input() is always called after child,
# despite my attempts to suppress the event after handling it.
extends Button

export  var action = "move_forward"

var default_action
var set_action
var queued_action


func _ready():
	default_action = InputMap.get_action_list(action)[0]

	add_to_group("guitar_input_remap")
	set_process_unhandled_key_input(false)
	_display_key()


func _display_key():
	text = _get_text(InputMap.get_action_list(action)[0])


func _get_text(action):
	var new = "%s" % action.as_text()
	return new


func _on_input_forward_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = ". . ."
	elif queued_action:
		text = _get_text(queued_action)
	else :
		_display_key()


func _unhandled_key_input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		pressed = false
		return
	
	# Ignore keybinds for the chord shapes (1-9).
	for i in range(1, 10):
		var chord_shape_action_name := "bind_" + str(i)
		if InputMap.action_has_event(chord_shape_action_name, event):
			get_tree().set_input_as_handled()
			queued_action = null
			pressed = false
			return
	
	# Only check conflicts with guitar keybinds, rather than all global keybinds.
	for button in get_tree().get_nodes_in_group("guitar_input_remap"):
		if button != self:
			var valid := true
			if button.set_action and button.set_action.scancode == event.scancode:
				valid = false
			if button.queued_action and button.queued_action.scancode == event.scancode:
				valid = false
			if not valid:
				if button.default_action.scancode != event.scancode:
					button.queued_action = button.default_action
				else :
					button.queued_action = set_action
				
				button._on_input_forward_toggled(false)
	
	queued_action = event
	pressed = false


func _input_check(new_action):
	if action == new_action: return 
	pressed = false


func _set_queued(event):
	queued_action = event
	_on_input_forward_toggled(false)


func _remap_key():
	var event = default_action
	if queued_action:
		event = queued_action
	elif set_action:
		event = set_action
	
	var events_to_add = []
	events_to_add.append(event)
	
	if events_to_add.size() > 0:
		InputMap.action_erase_events(action)
		for e in events_to_add:
			if not InputMap.action_has_event(action, e):
				InputMap.action_add_event(action, e)
	
	queued_action = null
	set_action = event
	_display_key()


func _duplicate_reset(new_action):
	if set_action == new_action or queued_action == new_action:
		set_action = default_action
		queued_action = default_action
		_remap_key()
		return true
	return false

