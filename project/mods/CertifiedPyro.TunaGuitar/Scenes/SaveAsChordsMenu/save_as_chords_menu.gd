extends Control

#const Player = preload("res://Scenes/Entities/Player/player.gd")
const PlayerHud = preload("res://Scenes/HUD/playerhud.gd")

#var player: Player


func _ready() -> void:
	print("SaveAsChordsMenu ready!")
#	get_tree().connect("node_added", self, "_get_player")


func _on_exit_button_pressed() -> void:
	print("SaveAsChordsMenu exited!")
	self.visible = false
#	if player != null:
#		player.busy = false

	var player_hud := $"/root/playerhud" as PlayerHud
	if player_hud != null:
		print("Got player_hud node!")
		OptionsMenu.open = false
		player_hud.menu = PlayerHud.MENUS.DEFAULT


func _on_save_button_pressed() -> void:
#	self.print_tree_pretty(	)
	var node := self.get_node("%NewPresetName") as LineEdit


#func _get_player(node: Node) -> void:
#	if node.name == "player":
#		var player = node as Player
