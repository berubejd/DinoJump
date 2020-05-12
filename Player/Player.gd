extends KinematicBody2D

const UP = Vector2(0, -1)

# Determine if player should be kept from extending beyond edge of level bounding box
export(float) var stop_left
export(float) var stop_top
export(float) var stop_right
export(float) var stop_bottom

# Modify jump when on jump pad
export var boost_modifier = 1.5

# Modify gravity when pressing down while in the air or in water
export var gravity_modifier = 2

# Modify forced jump height when hit
export var hurt_modifier = 0.5

export var GRAVITY = 30
export var GRAVITY_UNDER_WATER = 20
export var JUMP = 600
export var SPEED = 100

onready var animatedSprite = $Animations
onready var audiostream = $AudioStreamPlayer
onready var tilemap = get_tree().get_root().find_node("Platforms", true, false)

var motion = Vector2.ZERO


func _physics_process(_delta):
	process_movement()
	animate()
	motion = move_and_slide(motion, UP)
	process_limits()


func animate():
	# Let 'Hit' animation complete
	if animatedSprite.get_animation() == 'Hit':
		return

	# Set animation to play based on movement
	if not is_on_floor():
		if is_in_water():
			animatedSprite.play("Sprint")
		else:
			if motion.y < 0:
				animatedSprite.play("Jump")
			else:
				animatedSprite.play("Fall")
	elif motion.x != 0:
		animatedSprite.play("Run")	
	else:
		animatedSprite.play("Idle")

	# Determine facing of player
	# - This would be better sorted out as part of above rather than a second check?
	if motion.x != 0:
		if motion.x < 0:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false


# Player activated jump pad
func boost():
	motion.y = -JUMP * boost_modifier


func finished_animation():
	if animatedSprite.is_connected("animation_finished", self, "finished_animation"):
		animatedSprite.disconnect("animation_finished", self, "finished_animation")
	animatedSprite.play("Idle")


# Player has taken damage of some sort
func hurt():
	motion.y = -JUMP * hurt_modifier
	animatedSprite.play("Hit")
	audiostream.stream = load("res://Sound/Hurt.wav")
	audiostream.play()
	
	if not animatedSprite.is_connected("animation_finished", self, "finished_animation"):
		var _ret = animatedSprite.connect("animation_finished", self, "finished_animation")


func is_in_water():
	if tilemap:
		var tile_pos = tilemap.world_to_map(position)
		var tile_id = tilemap.get_cellv(tile_pos)

		# tile_id 2 seems to be water tiles in the current tilemap
		if tile_id == 2:
			return true
			
	return false


func process_movement():
	# Store result to avoid finding position multiple times per frame
	var in_water = is_in_water()
	
	# Modify movement if in water, set default to keep original values
	var movement_modifier = 1
	
	if in_water:
		movement_modifier = 0.6
	
	# Apply gravity
	if in_water and motion.y > 0:
		motion.y = GRAVITY_UNDER_WATER
	else:
		motion.y += GRAVITY

	
	if is_on_floor() or in_water:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP * movement_modifier
			audiostream.stream = load("res://Sound/sfx_movement_jump11.wav")
			audiostream.play()
	
	if Input.get_action_strength("ui_down") and motion.y > 0:
		motion.y *= gravity_modifier

	motion.x = ( -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right") ) * SPEED * movement_modifier


# Ensure player is within the bounding Node
# Clamp is cleaner but we need to check each stop_* individually to allow for unbounded sides
func process_limits():
	if stop_left:
		position.x = max(position.x, stop_left + tilemap.cell_size[0])

	if stop_right:
		position.x = min(position.x, stop_right - tilemap.cell_size[0])

	if stop_top:
		position.y = max(position.y, stop_top + tilemap.cell_size[1])

	if stop_bottom:
		position.y = min(position.y, stop_bottom - tilemap.cell_size[1])


# Keep player in place by removing movement
# This is currently in use to keep the player within the bounds of a triggered bomb
func immobilize():
	SPEED = 0
	JUMP = 0
