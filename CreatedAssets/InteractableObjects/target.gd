extends Node3D

signal incrementGoalProgress

func _on_area_3d_body_entered(body):
	if body.is_in_group("Fireball"):
		emit_signal("incrementGoalProgress")
		get_tree().call_group("BridgeSection", "_on_target_2_increment_goal_progress")
		queue_free()
