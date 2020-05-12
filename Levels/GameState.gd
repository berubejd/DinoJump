extends Node2D

const OneUp = preload("res://Items/Heart.tscn")

export var lives = 3
export var one_up_cost = 10

onready var bounds = $Bounds
onready var camera = $PlayerRed/Camera2D
onready var diamonds = 0
onready var player = $PlayerRed
onready var ui_count_diamond = $GUI/Control/TextureRect/HBoxContainer/DiamondCount
onready var ui_count_life = $GUI/Control/TextureRect/HBoxContainer/LifeCount


func _ready():
	add_to_group("Gamestate")
	
	camera.set_limit(MARGIN_LEFT, bounds.position.x)
	player.stop_left = bounds.position.x
	camera.set_limit(MARGIN_TOP, bounds.position.y)
	# Don't set this value in order to allow player to extend beyond camera at top of jump
	# player.stop_top = bounds.position.y
	camera.set_limit(MARGIN_RIGHT, bounds.position.x + bounds.get_scale().x)
	player.stop_right = bounds.position.x + bounds.get_scale().x
	camera.set_limit(MARGIN_BOTTOM, bounds.position.y + bounds.get_scale().y)
	player.stop_bottom = bounds.position.y + bounds.get_scale().y

	ui_count_diamond.text = str(diamonds)
	ui_count_life.text = str(lives)


func add_diamond(value):
	diamonds += value
	ui_count_diamond.text = str(diamonds)
	
	if diamonds % one_up_cost == 0:
		lives += 1
		ui_count_life.text = str(lives)
		var oneUp = OneUp.instance()
		player.add_child(oneUp)


func end_game():
	var _val = get_tree().change_scene("res://Levels/LoseGame.tscn")


func hurt(damage=1):
	lives -= damage
	player.hurt()
	
	if lives <= 0:
		end_game()
	else:
		ui_count_life.text = str(lives)
