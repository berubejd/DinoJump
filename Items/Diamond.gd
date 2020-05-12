extends Node2D

export var value = 1

onready var animation_player = $AnimationPlayer
onready var audiostream = $AudioStreamPlayer2D

func _on_Area2D_body_entered(_body):
	animation_player.play("Despawn")
	audiostream.play()
	get_tree().call_group("Gamestate", "add_diamond", value)
