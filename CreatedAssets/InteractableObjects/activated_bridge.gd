extends Node3D

var activationGoal = 1
var activationCount = 0

@onready 
var Block : CollisionShape3D = $Block/StaticBody3D/CollisionShape3D

@onready 
var Block2 : CollisionShape3D = $Block2/StaticBody3D/CollisionShape3D

@onready 
var EdgeL : CollisionShape3D = $EdgeL/StaticBody3D/CollisionShape3D

@onready 
var EdgeL2 : CollisionShape3D = $EdgeL2/StaticBody3D/CollisionShape3D

func _ready():
	pass
	
func AddProgress():
	activationCount += 1
	
func BridgeRaised():
	Block.disabled = false
	Block2.disabled = false
	EdgeL.disabled = false
	EdgeL2.disabled = false
	pass

func _on_target_2_increment_goal_progress():
	BridgeRaised()
