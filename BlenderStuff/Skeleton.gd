extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var animation_Player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var audio_Player = $AudioStreamPlayer3D

var player = null
var state_machine : AnimationNodeStateMachinePlayback

@export var player_path : NodePath

var root_node

@export
var root_node_path : NodePath

var ATTACK_RANGE = 2.0
var SEEK_RANGE = 500.0
var SPEED = 10.0
var ACCELERATION = 4.0
var gravity = -(ProjectSettings.get_setting("physics/3d/default_gravity"))

@onready
var blood = preload("res://Particles/blood_particle.tscn")

#var run_soundfile = FileAccess.open("res://Audio/Footsteps.mp3", FileAccess.READ)
#var run_sound = AudioStreamMP3.new()
#var attack_soundfile = FileAccess.open("res://Audio/Footsteps.mp3", FileAccess.READ)
#var attack_sound = AudioStreamMP3.new()

@export
var run_sound : AudioStreamPlayer3D

@export
var particle : GPUParticles3D

signal incrementGoalProgress()

func _ready():
	root_node = get_tree().get_root().get_node("Staging").get_node("Scene").get_node("BaseLevel")
	player = get_tree().get_root().get_node("Staging").get_node("Scene").get_node("BaseLevel").get_node("XROrigin3D")
	state_machine = anim_tree["parameters/playback"]
	state_machine.start("Idle", true)

func _physics_process(delta):

	# If the player is in range, attack
	# else follow the player
	if _target_in_attack_range():
		state_machine.travel("Attack")
		state_machine.start("Attack")
		animation_Player.play("Attack", -1, 1.0)
		set_velocity(Vector3(0, gravity, 0))
		if !run_sound.playing:
			run_sound.playing = true
	elif !_target_in_attack_range() && _target_in_seek_range():
		state_machine.travel("Run")
		state_machine.start("Run")
		animation_Player.play("Run", -1, 2.5)
		if !run_sound.playing:
			run_sound.playing = true
		# follow the player
		update_target_location(player.global_position, delta)
	elif !_target_in_seek_range():
		state_machine.travel("Idle")
		state_machine.start("Idle")
		animation_Player.play("Idle", -1, 1.0)
		audio_Player.stop()

func update_target_location(target_location, delta):
	nav_agent.set_path_max_distance(10)
	nav_agent.set_target_position(target_location)
	var direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	direction.y = 0 # Ensure the skeleton does not tilt up or down
	look_at(global_position + direction, Vector3.UP)
	set_velocity(velocity.lerp(direction * SPEED, ACCELERATION * delta))
	set_velocity(Vector3(velocity.x, gravity, velocity.z))
	move_and_slide()

func _target_in_attack_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _target_in_seek_range():
	return global_position.distance_to(player.global_position) < SEEK_RANGE

func _on_skeleton_area_body_entered(body):
	#print(body.name)
	if (body.is_in_group("Fireball")):
		var new_blood : GPUParticles3D = blood.instantiate()
		get_tree().root.add_child(new_blood)
		new_blood.transform = transform
		# new_blood.position.y = new_blood.position.y + -0.2
		get_tree().call_group("Goal", "_on_target_2_increment_goal_progress")
		queue_free()
