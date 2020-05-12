extends Area2D

onready var animationPlayer = $AnimationPlayer
onready var audiostream = $AudioStreamPlayer

func _on_JumpPad_body_entered(body):
	if body.has_method("boost"):
		animationPlayer.play("Boost")
		audiostream.stream = load("res://Sound/sfx_sounds_powerup2.wav")
		audiostream.play()
		body.boost()
