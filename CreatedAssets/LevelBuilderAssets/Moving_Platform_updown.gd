extends Node3D

@onready
var anim_player: AnimationPlayer = $AnimationPlayer

@export 
var time_to_deactivate = 5

var triggered = false

var ran_process = false

signal platform_deactivated

func _process(delta):
	if triggered && !ran_process:
		ran_process = true
		print("triggered:" + str(triggered))
		await get_tree().create_timer(time_to_deactivate).timeout
		anim_player.play("platform_deactivate")
		await get_tree().create_timer(3).timeout
		anim_player.play("RESET")
		platform_deactivated.emit()
		triggered = false
		ran_process = false

#func _on_switch_trigger():
	#if !triggered:
		#anim_player.play("platform_activate")
		#await get_tree().create_timer(3).timeout
		#triggered = true


