extends CharacterBody3D

# TODO: Add descriptions for each value

@export_category("Character")
@export var base_speed : float = 9.0
@export var sprint_speed : float = 18.0
@export var crouch_speed : float = 6.0
@export var shoot_power : float = 10.0

@onready
var firerate_timer : Timer = $firerate_timer

@export var acceleration : float = 50.0
@export var jump_velocity : float = 9.0
@export var mouse_sensitivity : float = 0.25

@export var initial_facing_direction : Vector3 = Vector3.ZERO

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var HEADBOB_ANIMATION : AnimationPlayer
@export var JUMP_ANIMATION : AnimationPlayer
@export var CROUCH_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "ui_accept"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_back"
@export var PAUSE : String = "ui_cancel"
@export var CROUCH : String
@export var SPRINT : String

# Uncomment if you want full controller support
#@export var LOOK_LEFT : String
#@export var LOOK_RIGHT : String
#@export var LOOK_UP : String
#@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var immobile : bool = false
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true
@export var jump_animation : bool = true

# Member variables
var speed : float = base_speed
var current_speed : float = 0.0
# States: normal, crouching, sprinting
var spell_array = ["Fireball", "Waterblast", "Lightiningbolt"]
var spell_selected = 0
var spell_name = "Fireball"
var state : String = "normal"
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.
var was_on_floor : bool = true

# UI variables
@export
var firebox : StyleBoxFlat

@export
var firepanel : Panel

@export
var firetexture : TextureRect

@export
var waterbox : StyleBoxFlat

@export
var waterpanel : Panel

@export
var watertexture : TextureRect

@export
var lightningbox : StyleBoxFlat

@export
var lightningpanel : Panel

@export
var lightningtexture : TextureRect

var original_firebox = null
var original_waterbox = null
var original_lightningbox = null

var original_firetexture = null
var original_watertexture = null
var original_lightningtexture = null

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process


func _ready():
	original_firebox = firebox.duplicate()
	original_firebox.bg_color = Color8(255, 0, 0)
	original_waterbox = waterbox.duplicate()
	original_waterbox.bg_color = Color8(0, 151, 190)
	original_lightningbox = lightningbox.duplicate()
	original_lightningbox.bg_color = Color8(247, 210, 44)

	original_firetexture = firetexture.duplicate()
	original_watertexture = watertexture.duplicate()
	original_lightningtexture = lightningtexture.duplicate()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Set the camera rotation to whatever initial_facing_direction is
	if initial_facing_direction:
		HEAD.set_rotation_degrees(initial_facing_direction) # I don't want to be calling this function if the vector is zero

	# Reset the camera position
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	handle_spell_availability(firerate_timer, 0)
	handle_spell_availability(firerate_timer, 1)
	handle_spell_availability(firerate_timer, 2)
	handle_spell_availability(firerate_timer, 0)


func _physics_process(delta):
	current_speed = Vector3.ZERO.distance_to(get_real_velocity())
	$UserInterface/DebugPanel.add_property("Speed", snappedf(current_speed, 0.001), 1)
	$UserInterface/DebugPanel.add_property("Target speed", speed, 2)
	var cv : Vector3 = get_real_velocity()
	var vd : Array[float] = [
		snappedf(cv.x, 0.001),
		snappedf(cv.y, 0.001),
		snappedf(cv.z, 0.001)
	]
	var readable_velocity : String = "X: " + str(vd[0]) + " Y: " + str(vd[1]) + " Z: " + str(vd[2])
	$UserInterface/DebugPanel.add_property("Velocity", readable_velocity, 3)

	# Gravity
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor():
		velocity.y -= gravity * delta

	handle_jumping()

	var input_dir = Vector2.ZERO
	if !immobile:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)

	low_ceiling = $CrouchCeilingDetection.is_colliding()

	handle_state(input_dir)
	if dynamic_fov:
		update_camera_fov()

	if view_bobbing:
		headbob_animation(input_dir)

	if jump_animation:
		if !was_on_floor and is_on_floor(): # Just landed
			JUMP_ANIMATION.play("land")

		was_on_floor = is_on_floor() # This must always be at the end of physics_process


func handle_jumping():
	if jumping_enabled:
		if continuous_jumping:
			if Input.is_action_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump")
				velocity.y += jump_velocity
		else:
			if Input.is_action_just_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump")
				velocity.y += jump_velocity


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()

	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed


func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(SPRINT) and state != "crouching":
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				# If the player is holding sprint before moving, handle that cenerio
				if Input.is_action_pressed(SPRINT) and state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()

	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(CROUCH) and state != "sprinting":
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()

# Any enter state function should only be called once when you want to enter that state, not every frame.

func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = "crouching"
	speed = crouch_speed
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed


func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)


func headbob_animation(moving):
	if moving and is_on_floor():
		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == "headbob":
			was_playing = true
		HEADBOB_ANIMATION.play("headbob", 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.75
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.

	else:
		HEADBOB_ANIMATION.play("RESET", 0.25)
		HEADBOB_ANIMATION.speed_scale = 1


func shoot():
	var fireball_load = preload("res://CreatedAssets/Wand/fireball.tscn")
	var waterball_load = preload("res://CreatedAssets/Wand/fireball.tscn")
	var lightningbolt_load = preload("res://CreatedAssets/Wand/fireball.tscn")
	var spell = null
	match spell_selected:
		0:
			spell = fireball_load.instantiate()
		1:
			spell = waterball_load.instantiate()
		2:
			spell = lightningbolt_load.instantiate()

	get_tree().root.add_child(spell)
	spell.global_transform = HEAD.global_transform
	spell.Fire_shot()
	firerate_timer.start(0.25)
	#print("firebolt shot")

func handle_spell_state():
	if Input.is_action_just_pressed("next_spell"):
		spell_selected = spell_selected + 1
		if (spell_selected > spell_array.size() - 1):
			spell_selected = 0
		spell_name = spell_array[spell_selected]
	elif Input.is_action_just_pressed("previous_spell"):
		spell_selected = spell_selected - 1
		if (spell_selected < 0):
			spell_selected = spell_array.size() - 1
		spell_name = spell_array[spell_selected]


func _process(delta):
	handle_spell_state()
	handle_spell_availability(firerate_timer, spell_selected)
	$UserInterface/DebugPanel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
	var status : String = state
	if !is_on_floor():
		status += " in the air"
	$UserInterface/DebugPanel.add_property("State", status, 4)

	if Input.is_action_just_pressed("shoot") && firerate_timer.is_stopped():
		shoot()

	if Input.is_action_just_pressed(PAUSE):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	# Uncomment if you want full controller support
	#var controller_view_rotation = Input.get_vector(LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN)
	#HEAD.rotation_degrees.y -= controller_view_rotation.x * 1.5
	#HEAD.rotation_degrees.x -= controller_view_rotation.y * 1.5


func handle_spell_availability(firerate_timer, spell_selected):

	if firerate_timer.is_stopped():
		firebox.bg_color.a = 0.1
		waterbox.bg_color.a = 0.1
		lightningbox.bg_color.a = 0.1

		# change texture alpha
		firetexture.modulate.a = 0.1
		watertexture.modulate.a = 0.1
		lightningtexture.modulate.a = 0.1

		match spell_selected:
			0:
				firebox.bg_color = original_firebox.bg_color
				firebox.bg_color.a = 1
				firetexture.modulate = original_firetexture.modulate
			1:
				waterbox.bg_color = original_waterbox.bg_color
				waterbox.bg_color.a = 1
				watertexture.modulate = original_watertexture.modulate
			2:
				lightningbox.bg_color = original_lightningbox.bg_color
				lightningbox.bg_color.a = 1
				lightningtexture.modulate = original_lightningtexture.modulate
	else:
		match spell_selected:
			0:
				firebox.bg_color = original_firebox.bg_color.lightened(1)
				firebox.bg_color.a = 1 - lerpf(0, 1, firerate_timer.time_left)
				firetexture.modulate.a = 1 - lerpf(0, 1, firerate_timer.time_left)
				waterbox.bg_color = Color(0.1, 0.1, 0.1, 0.1)
				lightningbox.bg_color = Color(0.1, 0.1, 0.1, 0.1)
			1:
				waterbox.bg_color = original_waterbox.bg_color.lightened(1)
				waterbox.bg_color.a = 1 - lerpf(0, 1, firerate_timer.time_left)
				watertexture.modulate.a = 1 - lerpf(0, 1, firerate_timer.time_left)
				firebox.bg_color = Color(0.1, 0.1, 0.1, 0.1)
				lightningbox.bg_color = Color(0.1, 0.1, 0.1, 0.1)
			2:
				lightningbox.bg_color = original_lightningbox.bg_color.lightened(1)
				lightningbox.bg_color.a = 1 - lerpf(0, 1, firerate_timer.time_left)
				lightningtexture.modulate.a = 1 - lerpf(0, 1, firerate_timer.time_left)
				firebox.bg_color = Color(0.1, 0.1, 0.1, 0.1)
				waterbox.bg_color = Color(0.1, 0.1, 0.1, 0.1)

func next_spell():
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity
