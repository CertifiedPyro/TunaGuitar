extends Node

const MainTheme = preload("res://Assets/Themes/main.tres")
#const Player = preload("res://Scenes/Entities/Player/player.gd")
const PlayerHud = preload("res://Scenes/HUD/playerhud.gd")

#var player: Player


func _ready() -> void:
	print("ModButtons ready!")
#	get_tree().connect("node_added", self, "_get_player")


func _on_load_button_pressed() -> void:
	var menu := $"../../LoadChordsMenu" as Control
	menu.visible = true


func _on_save_as_button_pressed() -> void:
	var menu := $"../../SaveAsChordsMenu" as Control
	menu.visible = true
	
#	player = $"/root/world/Viewport/main/entities/player" as Player
#	if player != null:
#		print("Got player node!")
#		player.busy = true

	var player_hud := $"/root/playerhud" as PlayerHud
	if player_hud != null:
		print("Got player_hud node!")
		OptionsMenu.open = true
		player_hud.menu = PlayerHud.MENUS.EMOTE


#func _get_player(node: Node) -> void:
#	if node.name == "player":
#		print("Got player node!")
#		var player = node as Player
