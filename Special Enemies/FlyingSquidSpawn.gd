extends Node2D

const FlyingSquidSpawnSound = preload("res://Special Enemies/FlyingSquidSpawnSound.tscn")

export var speed = 100

onready var area = $Area2D
onready var audiostream = $AudioStreamPlayer

func _ready():
	set_as_toplevel(true)
	global_position = get_parent().global_position


func _process(delta):
	position.y += speed * delta
	
	var collider = area.get_overlapping_bodies()
	for object in collider:
		if object.name == "PlayerRed":
			get_tree().call_group("Gamestate", "hurt")

		var flyingSquidSpawnSound = FlyingSquidSpawnSound.instance()
		get_tree().current_scene.add_child(flyingSquidSpawnSound)
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

