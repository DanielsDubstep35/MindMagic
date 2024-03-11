extends Node3D

var activationGoal = 1
var activationCount = 0

@onready
var BlockL_Collision : CollisionShape3D = $BlockL/StaticBody3D/CollisionShape3D

@onready
var BlockR_Collision : CollisionShape3D = $BlockR/StaticBody3D/CollisionShape3D

@onready
var EdgeL_Collision : CollisionShape3D = $EdgeL/StaticBody3D/CollisionShape3D

@onready
var EdgeR_Collision : CollisionShape3D = $EdgeR/StaticBody3D/CollisionShape3D

@onready
var BlockL : MeshInstance3D = $BlockL

@onready
var BlockR : MeshInstance3D = $BlockR

@onready
var EdgeL : MeshInstance3D = $EdgeL

@onready
var EdgeR : MeshInstance3D = $EdgeR

@onready
var anim_player : AnimationPlayer = $AnimationPlayer

@onready
var BridgeSectionRiseTime : float = ($".".name.replace("BridgeSection", "").to_float()) / 5.0

func AddProgress():
	if activationCount == activationGoal:
		await get_tree().create_timer(BridgeSectionRiseTime).timeout
		BridgeRaised()
	else:
		activationCount += 1

func BridgeRaised():
	BlockL_Collision.disabled = false
	BlockR_Collision.disabled = false
	EdgeL_Collision.disabled = false
	EdgeR_Collision.disabled = false
	anim_player.play("raised_bridge", -1, 1)

func _on_target_2_increment_goal_progress():
	AddProgress()
