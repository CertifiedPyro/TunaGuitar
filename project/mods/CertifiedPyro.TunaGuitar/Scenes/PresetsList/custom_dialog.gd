extends Control


# Signal emitted when dialog is responded to (confirm or cancel).
# confirmed: Whether the dialog was confirmed, as a bool.
# input: The text in the text input field, if it was visible, as a String.
signal responded(confirmed, input)

var initial_input_text: String

onready var dialog_text := $"%DialogText" as Label
onready var text_input_container := $"%TextInputContainer" as Control
onready var text_input := $"%TextInput" as LineEdit
onready var ok_button := $"%OkButton" as Button


func _ready() -> void:
	self.visible = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if self.visible and event.is_action_pressed("esc_menu"):
		get_tree().set_input_as_handled()
		self._on_cancel_button_pressed()


func popup(requested_dialog_text: String, requires_input: bool = false, input_text: String = "") -> void:
	dialog_text.text = requested_dialog_text
	text_input_container.visible = requires_input
	if requires_input:
		text_input.text = input_text
		self.initial_input_text = input_text
		ok_button.disabled = true
	else:
		ok_button.disabled = false
	
	self.visible = true


func _on_ok_button_pressed() -> void:
	var input := text_input.text if text_input_container.visible else ""
	self.visible = false
	emit_signal("responded", true, input)


func _on_cancel_button_pressed() -> void:
	self.visible = false
	emit_signal("responded", false, null)


func _on_text_input_changed(new_text: String) -> void:
	ok_button.disabled = new_text == initial_input_text or new_text.empty()
