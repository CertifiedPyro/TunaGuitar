extends Node


signal load_menu_requested
signal save_menu_requested
signal save_as_menu_requested


func _on_load_button_pressed() -> void:
	emit_signal("load_menu_requested")


func _on_save_button_pressed() -> void:
	emit_signal("save_menu_requested")


func _on_save_as_button_pressed() -> void:
	emit_signal("save_as_menu_requested")
