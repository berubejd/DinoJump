extends Node2D

onready var animation = $AnimatedSprite


func _on_Area2D_body_entered(body):
	animation.play("Open")


func _on_Area2D_body_exited(body):
	animation.play("Open", true)


func _on_AnimatedSprite_animation_finished():
	get_tree().change_scene("res://Levels/WinGame.tscn")
