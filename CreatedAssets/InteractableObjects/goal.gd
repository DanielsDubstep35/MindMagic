extends Area3D

@export
var activationGoal = 1

@export
var activationCount = 0

@onready
var progressGrown = $FlowersGrown

@onready
var progressAmount = $FlowerAmount

@export_file("*.tscn")
var target_scene : String

@export
var particles : GPUParticles3D

@export
var goalAudio : AudioStreamPlayer3D

#@onready
#var Activated_Bridge = $"../ActivatedBridge"

@onready
var goal = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	goal.monitorable = false
	goal.monitoring = false
	progressGrown.modulate = Color.RED
	progressAmount.modulate = Color.RED
	progressAmount.text = str(activationCount) + " / " + str(activationGoal)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progressAmount.text = str(activationCount) + " / " + str(activationGoal)

func _on_body_entered(body):
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		print("No scene_base.gd script Found")
		return
		#
	## Start loading the target scene
	scene_base.load_scene(target_scene)
	
	#get_tree().change_scene_to_file("res://Levels/base_level.tscn")

func AddProgress():
	activationCount += 1

func Progress():
	AddProgress()
	if activationCount >= activationGoal:
		goalOpen()
		#Activated_Bridge.hide()
		#Activated_Bridge.show()

func goalOpen():
	goal.monitorable = true
	goal.monitoring = true
	progressGrown.modulate = Color.GREEN
	progressAmount.modulate = Color.GREEN
	particles.emitting = true
	goalAudio.playing = true

func _on_target_2_increment_goal_progress():
	Progress()
