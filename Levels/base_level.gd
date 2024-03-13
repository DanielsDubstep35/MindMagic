extends Node3D

# Level Objective: kill skeletons
var skeletons_killed = 0
var skeleton_goal = 30

@onready
var player = $"../XROrigin3D"

@onready
var wave_number = $"../WaveNumber"

@onready
var wave_text = $"../WaveText"

@onready
var wave_audio = $"../LevelTextAudio"

@export
var wave_audio_pitch_min = 0.2

@export
var wave_audio_pitch_max = 0.4

@export
var level_character_type_speed = 0.1

@export
var wait_before_next_sentence_time = 2

signal wave1_complete

var wave1_completed = false

signal wave2_complete

var wave2_completed = false

signal wave3_complete

var wave3_completed = false

# Declare your spawners here:

# Spawners to trigger when an action happens
var spawners = []

func _ready():
	for spawner in get_tree().get_nodes_in_group("Skeleton_Spawner"):
		spawners.append(spawner)
	level_progression()

func _process(delta):
	if (skeletons_killed == 5) && !wave1_completed:
		wave1_completed = true
		_on_wave1_complete()

	if (skeletons_killed == 15) && !wave2_completed:
		_on_wave2_complete()

	if (skeletons_killed == 30) && !wave3_completed:
		_on_wave3_complete()
	pass

func skeleton_spawner():
	for spawner in spawners:
		spawner.spawn_wave()

func level_progression():

	await get_tree().create_timer(3).timeout

	wave_text.text = ""
	for i in "Welcome to Mind Magic":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	await get_tree().create_timer(wait_before_next_sentence_time).timeout

	wave_text.text = ""
	for i in "Complete Objectives to climb the tower":
		wave_text.text = wave_text.text + i
		#wave_audio.pitch_scale = randf_range(wave_audio_pitch_min, wave_audio_pitch_max)
		#wave_audio.play()
		await get_tree().create_timer(level_character_type_speed).timeout
		#wave_audio.stop()
	await get_tree().create_timer(wait_before_next_sentence_time).timeout

	wave_text.text = ""
	for i in "Level 1: Skeletal Slaughter":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	await get_tree().create_timer(wait_before_next_sentence_time).timeout

	wave_text.text = ""
	for i in "Survive 5 Waves":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	await get_tree().create_timer(wait_before_next_sentence_time).timeout

	wave_text.text = ""
	for i in "Wave":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	wave_number.text = "1"
	await get_tree().create_timer(1).timeout

	for spawner in spawners:
		spawner.set_difficulty(0)
		spawner.spawn_wave()

	await wave1_complete

	wave_number.text = ""
	wave_text.text = ""
	for i in "Wave":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	wave_number.text = "2"
	await get_tree().create_timer(1).timeout

	for spawner in spawners:
		spawner.set_difficulty(1)
		spawner.spawn_wave()

	await wave2_complete

	wave_number.text = ""
	wave_text.text = ""
	for i in "Wave":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	wave_number.text = "3"
	await get_tree().create_timer(1).timeout

	for spawner in spawners:
		spawner.set_difficulty(2)
		spawner.spawn_wave()

	await wave3_complete

	wave_number.text = ""
	wave_text.text = ""
	for i in "The portal beckons...":
		wave_text.text = wave_text.text + i
		await get_tree().create_timer(level_character_type_speed).timeout

func track_player():
	get_tree().call_group("enemies", "update_target_location", player.basis)

func _on_wave1_complete():
	wave1_complete.emit()

func _on_wave2_complete():
	wave2_complete.emit()

func _on_wave3_complete():
	wave3_complete.emit()
	
func skeletonKilled():
	skeletons_killed += 1
