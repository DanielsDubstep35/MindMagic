extends Node3D

@onready
var candleMesh:MeshInstance3D = $target

signal incrementGoalProgress

func _on_area_3d_body_entered(body):
	if body.name == "Fireball":
		candleMesh.mesh = load("res://UsedAssets/KayKit/KayKit_DungeonRemastered_1.0_FREE/Assets/obj/candle_lit.obj")
		var light = OmniLight3D.new()
		light.transform = transform
		emit_signal("incrementGoalProgress")
		queue_free()
