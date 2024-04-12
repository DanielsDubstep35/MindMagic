extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var animation_Player = $AnimSkele/AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var audio_Player = $AudioStreamPlayer3D
@onready var health = $Health
var player = null
var state_machine : AnimationNodeStateMachinePlayback

@onready
var wizard_muzzle = $AnimSkele/Wand/SpellShoot

@export var player_path : NodePath

var root_node

@export
var root_node_path : NodePath

var ATTACK_RANGE = 15.0
var SEEK_RANGE = 500.0
var SPEED = 5.0
var ACCELERATION = 4.0
var gravity = -(ProjectSettings.get_setting("physics/3d/default_gravity"))

@export
var healthbar = 100

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
	root_node = get_tree().root.find_child("Base", true, false)
	player = root_node.get_node("XROrigin3D")
	state_machine = anim_tree["parameters/playback"]
	state_machine.start("Base", true)

func _physics_process(delta):

	# If the player is in range, attack
	# else follow the player
	if _target_in_attack_range():
		state_machine.travel("CastFSpell")
		state_machine.start("CastFSpell")
		animation_Player.play("CastFSpell", -1, 1.0)
		set_velocity(Vector3(0, gravity, 0))
		await animation_Player.animation_finished
		#if !run_sound.playing:
			#run_sound.playing = true
		attackPlayer()
		
	elif !_target_in_attack_range() && _target_in_seek_range():
		state_machine.travel("Walk")
		state_machine.start("Walk")
		animation_Player.play("Walk", -1, 2.5)
		#if !run_sound.playing:
			#run_sound.playing = true
		# follow the player
		update_target_location(player.global_position, delta)
	elif !_target_in_seek_range():
		state_machine.travel("Base")
		state_machine.start("Base")
		animation_Player.play("Base", -1, 1.0)
		#if audio_Player != null:
			#audio_Player.stop()
		#else:
			#pass

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
	if player != null:
		return global_position.distance_to(player.global_position) < ATTACK_RANGE
	else:
		return false

func _target_in_seek_range():
	if player != null:
		return global_position.distance_to(player.global_position) < SEEK_RANGE
	else:
		return false

#func _on_skeleton_area_body_entered(body):
	##print(body.name)
	
	# Add new spells to this if statement

func attackPlayer():
	var fireball = preload("res://CreatedAssets/Wand/WizardFireball.tscn")
	var spell = fireball.instantiate()
	get_tree().root.add_child(spell)
	spell.global_transform = wizard_muzzle.global_transform
	spell.FireAtPlayer(player.global_transform.origin)
	
func level_cleanup():
	queue_free()


func _on_hit_box_body_entered(body):
	if (body.is_in_group("Fireball") || body.is_in_group("LightningBlast")):
		#var new_blood : GPUParticles3D = blood.instantiate()
		#get_tree().root.add_child(new_blood)
		#new_blood.transform = transform
		# new_blood.position.y = new_blood.position.y + -0.2
		healthbar -= 1
		health.text = str(healthbar)
		
		if healthbar <= 0:
			queue_free()
			get_tree().call_group("Goal", "_on_target_2_increment_goal_progress")
			get_tree().call_group("Objective", "skeletonKilled")
