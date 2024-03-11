extends Node3D

@onready var player = $VR_Player

func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)
	#if player.global_transform < -10:
		#print("Player is too far gone :o")
		#player.position = Vector3(0, 2.351, 3.609)
