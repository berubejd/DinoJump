extends Control

onready var sceneTree = get_tree()


func _on_RestartButton_pressed():
	sceneTree.change_scene("res://Levels/Level1.tscn")
