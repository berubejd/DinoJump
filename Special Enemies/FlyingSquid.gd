extends KinematicBody2D

enum DIRECTION {
	LEFT = -1,
	RIGHT = 1
}

export var speed = 20
export(DIRECTION) var moving_direction = DIRECTION.RIGHT

var attack_cooldown = false
var facing_reversed
var motion = Vector2.ZERO
var spawn_position

onready var animation = $AnimatedSprite
onready var audiostream = $AudioStreamPlayer
onready var notifier = $VisibilityNotifier2D
onready var raycast = $RayCast2D
onready var timer_attack = $AttackTimer
onready var timer_move = $MovementTimer


func _ready():
	randomize()
	timer_move.start()
	facing_reversed = false if moving_direction == DIRECTION.RIGHT else true
	spawn_position = global_position


func _physics_process(_delta):
	if is_on_wall():
		moving_direction = -moving_direction

	motion.x = speed * moving_direction

	if notifier.is_on_screen():
		if raycast.is_colliding() and not attack_cooldown:
			add_child(load("res://Special Enemies/FlyingSquidSpawn.tscn").instance())
			animation.play("Hit")
			audiostream.play()
			connect_animation_signal()
			attack_cooldown = true
			timer_move.start(2)
			timer_attack.start(3)

	animate()	
	motion = move_and_slide(motion, Vector2.UP)


func animate():
	if animation.get_animation() == 'Hit':
		return

	animation.play("Idle")
	
	if motion.x < 0:
		animation.flip_h = true
	else:
		animation.flip_h = false

	if facing_reversed:
		animation.flip_h = not animation.flip_h


func connect_animation_signal():
	if not animation.is_connected("animation_finished", self, "finished_animation"):
		var _ret = animation.connect("animation_finished", self, "finished_animation")


func finished_animation():
	if animation.is_connected("animation_finished", self, "finished_animation"):
		animation.disconnect("animation_finished", self, "finished_animation")
	animation.play("Idle")


func _on_MovementTimer_timeout():
	# Send back towards spawn point if too far away
	if abs(spawn_position.x - global_position.x) > 100:
		moving_direction = -moving_direction
	else:
		var flip = randi()%2
		match flip:
			0:
				moving_direction = DIRECTION.LEFT
			1:
				moving_direction = DIRECTION.RIGHT

	timer_move.start(randi()%10 + 1)


func _on_AttackTimer_timeout():
	attack_cooldown = false
