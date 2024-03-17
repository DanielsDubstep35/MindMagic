extends Node3D

@export
var title_instruction: Label3D

@export
var level_character_type_speed = 0.1

@export
var wait_before_next_sentence_time = 2

func _ready():
	level_progression()

func level_progression():
	
	await get_tree().create_timer(3).timeout

	title_instruction.text = ""
	for i in "Welcome to Mind Magic":
		title_instruction.text = title_instruction.text + i
		await get_tree().create_timer(level_character_type_speed).timeout
	await get_tree().create_timer(wait_before_next_sentence_time).timeout

	title_instruction.text = ""
	for i in "Complete Objectives to climb the tower":
		title_instruction.text = title_instruction.text + i
		#wave_audio.pitch_scale = randf_range(wave_audio_pitch_min, wave_audio_pitch_max)
		#wave_audio.play()
		await get_tree().create_timer(level_character_type_speed).timeout
		#wave_audio.stop()
	await get_tree().create_timer(wait_before_next_sentence_time).timeout
	
	title_instruction.text = ""
	for i in "Use a fire spell to trigger the bridge!":
		title_instruction.text = title_instruction.text + i
		#wave_audio.pitch_scale = randf_range(wave_audio_pitch_min, wave_audio_pitch_max)
		#wave_audio.play()
		await get_tree().create_timer(level_character_type_speed).timeout
		#wave_audio.stop()
	await get_tree().create_timer(wait_before_next_sentence_time).timeout
