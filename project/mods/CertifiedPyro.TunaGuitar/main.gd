extends Node

const mod_buttons_scene := preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/mod_buttons.tscn")
const load_chords_menu_scene := preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/LoadChordsMenu/load_chords_menu.tscn")
const save_as_chords_menu_scene := preload("res://mods/CertifiedPyro.TunaGuitar/Scenes/SaveAsChordsMenu/save_as_chords_menu.tscn")


func _ready() -> void:
	get_tree().connect("node_added", self, "_init_mod")

	
func _init_mod(node: Node) -> void:
	if node.name != "guitar":
		return

	var fret_main := node.get_node("fret_main")
	
	var mod_buttons := mod_buttons_scene.instance() as Control
	# Hide chords menus until mod buttons (load/save) are clicked.
	var load_chords_menu := load_chords_menu_scene.instance() as Control
	load_chords_menu.visible = false
	var save_as_chords_menu := save_as_chords_menu_scene.instance() as Control
	save_as_chords_menu.visible = false
	
	fret_main.add_child(mod_buttons)
	node.add_child(load_chords_menu)
	node.add_child(save_as_chords_menu)
#	node.print_tree_pretty()
