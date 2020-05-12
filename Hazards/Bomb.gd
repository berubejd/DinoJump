extends Area2D

enum {
	OFF,
	ON
	}

export var bomb_lit = false

onready var animation = $AnimatedSprite
onready var audiostream = $AudioStreamPlayer2D
onready var collision = $CollisionShape2D
onready var state = ON if bomb_lit else OFF
onready var timer = $Timer

var player = null


func detonate_bomb():
	if player:
		get_tree().call_group("Gamestate", "end_game")

	queue_free()


func trigger_bomb():
	animation.play("Explode")
	audiostream.play()
	var _ret = animation.connect("animation_finished", self, "detonate_bomb")
	
	if player:
		player.immobilize()
		player.hide()


func _on_Bomb_body_entered(body):
	player = body
	
	if state == OFF:
		timer.start(2)
		animation.play("On")
		state = ON
	elif state == ON:
		timer.stop()
		trigger_bomb()


func _on_Bomb_body_exited(_body):
	player = null


func _on_Timer_timeout():
	trigger_bomb()
