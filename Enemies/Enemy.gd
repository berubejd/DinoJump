extends KinematicBody2D

const GRAVITY = 30

enum DIRECTION {
	LEFT = -1,
	RIGHT = 1
}

enum {
	HIDDEN,
	IDLE,
	WALK,
	HIT,
	DEATH,
	ATTACK
}

export var life = 1
export var speed = 30
export(DIRECTION) var walking_direction = DIRECTION.RIGHT

var facing_reversed
var motion = Vector2.ZERO
var timeout

onready var animation = $AnimatedSprite
onready var raycast = $RayCast2D
onready var state = HIDDEN if animation.animation == "Hidden" else IDLE
onready var timer = $Timer


func _ready():
	randomize()
	if not state == HIDDEN:
		timer.start()
	facing_reversed = false if walking_direction == DIRECTION.RIGHT else true


func _physics_process(_delta):
	motion.y += GRAVITY
	
	match state:
		HIDDEN:
			pass

		IDLE:
			motion.x = 0

		WALK:
			if is_on_wall() or not raycast.is_colliding():
				walking_direction = -walking_direction
				raycast.position.x = -raycast.position.x

			motion.x = speed * walking_direction

		HIT:
			pass

		DEATH:
			pass

		ATTACK:
			pass

	animate()	
	motion = move_and_slide(motion, Vector2.UP)


func _on_Aggro_body_entered(_body):
	if state == HIDDEN:
		if animation.frames.has_animation("Emerge"):
			animation.play("Emerge")
			connect_animation_signal()
		state = IDLE
		timer.start()


func _on_Timer_timeout():
	match state:
		IDLE:
			var flip = randi()%2
			# Is there a better way to calculate the raycast position?
			match flip:
				0:
					walking_direction = DIRECTION.LEFT
					raycast.position.x = -abs(raycast.position.x)
				1:
					walking_direction = DIRECTION.RIGHT
					raycast.position.x = abs(raycast.position.x)

			state = WALK
			timeout = randi()%10

		WALK:
			state = IDLE
			timeout = randi()%6

		_:
			timeout = randi()%6

	timer.start(timeout + 1)
	# Disable debug statement until new state testing
	# print("Current state: " + str(state) + " Timer: " + str(timeout) + "s" )

func _on_HitBox_body_entered(_body):
	get_tree().call_group("Gamestate", "hurt")


func animate():
	# Let 'Hit' or 'Emerge' animations complete
	var current_animation = animation.get_animation()
	if current_animation == 'Hit' or current_animation == 'Emerge':
		return

	# Set animation to play based on movement
	if motion.x != 0:
		animation.play("Walk")

		# Determine direction for sprite based on motion
		if motion.x < 0:
			animation.flip_h = true
		else:
			animation.flip_h = false

		if facing_reversed:
			animation.flip_h = not animation.flip_h

	else:
		if state == HIDDEN:
			animation.play("Hidden")
		else:
			animation.play("Idle")


func connect_animation_signal():
	if not animation.is_connected("animation_finished", self, "finished_animation"):
		var _ret = animation.connect("animation_finished", self, "finished_animation")


func finished_animation():
	if animation.is_connected("animation_finished", self, "finished_animation"):
		animation.disconnect("animation_finished", self, "finished_animation")
	animation.play("Idle")


func hit(_damage=1):
	# Uncomment this check once things are sorted
	# life -= damage
	if life <= 0:
		# Better done with an AnimationPlayer?
		# audiostream.stream = load("Some death resource")
		# audiostream.play()
		if animation.frames.has_animation("Death"):
			animation.play("Death")
		# Need to track completion of animation then queue_free() somewhere
		pass
	else:
		# Probably a knockback here instead of a jump of some sort
		# motion.y = -JUMP * hurt_modifier
		if animation.frames.has_animation("Hit"):
			animation.play("Hit")
		# audiostream.stream = load("res://Sound/Hurt.wav")
		# audiostream.play()
	
	connect_animation_signal()
