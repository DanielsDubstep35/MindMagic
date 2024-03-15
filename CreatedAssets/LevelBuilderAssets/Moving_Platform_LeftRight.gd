extends Node3D

@onready
var anim_player: AnimationPlayer = $AnimationPlayer

@export 
var time_to_deactivate = 2

var ran_process = false

var finished = false

func _process(delta):
	if !ran_process && !finished:
		ran_process = true
		anim_player.play("platform_activate")
		await get_tree().create_timer(3).timeout
		await get_tree().create_timer(time_to_deactivate).timeout
		anim_player.play("platform_activate_2")
		await get_tree().create_timer(3).timeout
		await get_tree().create_timer(time_to_deactivate).timeout
		finished = true
		
	if ran_process && finished:
		ran_process = false
		anim_player.play("platform_deactivate")
		await get_tree().create_timer(3).timeout
		await get_tree().create_timer(time_to_deactivate).timeout
		anim_player.play("platform_deactivate_2")
		await get_tree().create_timer(3).timeout
		await get_tree().create_timer(time_to_deactivate).timeout
		anim_player.play("RESET")
		finished = false

