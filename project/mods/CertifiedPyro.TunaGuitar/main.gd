extends Node

const mod_menu_scene := preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/ModMenu/mod_menu.tscn")
const load_chords_menu_scene := preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/LoadChordsMenu/load_chords_menu.tscn")
const save_as_chords_menu_scene := preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/SaveAsChordsMenu/save_as_chords_menu.tscn")


func _ready() -> void:
	get_tree().connect("node_added", self, "_init_mod")

	
func _init_mod(node: Node) -> void:
	if node.name != "guitar":
		return
	
	var mod_menu := mod_menu_scene.instance() as Control
	var load_chords_menu := load_chords_menu_scene.instance() as Control
	var save_as_chords_menu := save_as_chords_menu_scene.instance() as Control

	mod_menu.connect("load_menu_requested", load_chords_menu, "open_menu")
	mod_menu.connect("save_menu_requested", save_as_chords_menu, "overwrite_current_preset")
	mod_menu.connect("save_as_menu_requested", save_as_chords_menu, "open_menu")
	
	# This signal connection is needed so save menu knows when a preset was loaded from the load menu.
	# This allows the "Save" button to work properly.
	load_chords_menu.connect("preset_loaded", save_as_chords_menu, "handle_external_activated_preset")
	
	var fret_main := node.get_node("fret_main")
	fret_main.add_child(mod_menu)
	node.add_child(load_chords_menu)
	node.add_child(save_as_chords_menu)
