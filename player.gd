extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 900)
const STOMP_VEC = Vector2(0, 5000)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2
const MAX_JUMPS = 2
const MAX_HIT_POINTS = 3
const INVULNERABLE_TIME = 1.5
const DAMAGED_PUSHBACK = 250

var hit_points = MAX_HIT_POINTS
var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var shoot_time=99999 #time since last shot
var jumps = 0
var stomping = false
var is_invulnerable = false
var has_been_invulnerable = INVULNERABLE_TIME
var anim=""

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $sprite
onready var camera = $camera

func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta
	
	if is_invulnerable:
		has_been_invulnerable += delta
		is_invulnerable = has_been_invulnerable < INVULNERABLE_TIME
		if not is_invulnerable:
			$color_anim.stop(true)
			$color_anim.play("normal")


	### MOVEMENT ###

	# Apply Gravity
	if stomping:
		linear_vel += delta * STOMP_VEC
	else:
		linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	var slide_count = get_slide_count()
	for i in range(slide_count):
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.has_method("hit_by_stomp") and stomping:
			collider.call("hit_by_stomp")
			collider.add_collision_exception_with(self)
			stomp_land()
		elif collider.has_method("deal_damage"):
			linear_vel += collision.normal * DAMAGED_PUSHBACK
			hit_by_damage(collider.call("deal_damage"))

	# Detect Floor
	if is_on_floor():
		jumps = 0
		if stomping:
			stomp_land()

		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME
	var target_speed = 0
	### CONTROL ###
	if stomping:
		linear_vel.x = target_speed
	else:
		# Horizontal Movement
		if Input.is_action_pressed("move_left"):
			target_speed += -1
		if Input.is_action_pressed("move_right"):
			target_speed +=  1
	
		target_speed *= WALK_SPEED
		linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

		# Jumping
		if (on_floor or jumps < MAX_JUMPS) and Input.is_action_just_pressed("jump"):
			linear_vel.y = -JUMP_SPEED
			jumps += 1
			$sound_jump.play()

		# Shooting
		if Input.is_action_just_pressed("shoot"):
			var bullet = preload("res://bullet.tscn").instance()
			bullet.position = $sprite/bullet_shoot.global_position #use node for shoot position
			bullet.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
			bullet.add_collision_exception_with(self) # don't want player to collide with bullet
			get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
			$sound_shoot.play()
			shoot_time = 0
		
		if not on_floor and Input.is_action_just_pressed("move_down"):
			stomping = true

		

	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if shoot_time < SHOOT_TIME_SHOW_WEAPON:
		new_anim += "_weapon"

	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)

func hit_by_damage(damage):
	if damage <= 0:
		return
	if not is_invulnerable:
		hit_points -= damage
		$sound_hurt.play()
		turn_invulnerable()
	if hit_points <= 0:
		get_node("/root/global").setScene("res://main_menu.tscn")

func stomp_land():
	$sound_stomp.play()
	camera.shake(0.2, 15, 16)
	stomping = false

func turn_invulnerable():
	$color_anim.play("invulnerable")

	has_been_invulnerable = 0
	is_invulnerable = true