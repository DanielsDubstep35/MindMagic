extends Node3D

# use this to set the range in which the skeletons will spawn
@export
var spawn_range = 8

var player = null

@onready
var playerChecker : Area3D = get_node("playerChecker")

@export
var player_path : NodePath

@export_range(0, 2)
var difficulty_selector = 0

var difficulty_value = null

@export var skeleton_path = preload("res://Scenes/Enemies/skeleton.tscn")

# Depending on the difficulty level, spawn more skeletons
enum difficulty {
	EASY = 5,
	MEDIUM = 10,
	HARD = 15
}

func _ready():
	set_difficulty(difficulty_selector)
	player = get_node(player_path)

	#if difficulty_selector == 0:
		#difficulty = difficulty.EASY
	pass

func spawn_wave():
	for numbers in difficulty_value:
		var randomized_pos_x = randf_range(0, spawn_range)
		var randomized_pos_z = randf_range(0, spawn_range)

		var new_skeleton = skeleton_path.instantiate()
		
		if new_skeleton != null:
			new_skeleton.show()

		# add the new skeleton to the scene
		get_tree().root.add_child(new_skeleton)
		new_skeleton.global_transform.origin = global_transform.origin + Vector3(randomized_pos_x, 0, randomized_pos_z)
		
func set_difficulty(difficulty_level):
	if difficulty_level <= 0:
		difficulty_value = difficulty.EASY
	elif difficulty_level == 1:
		difficulty_value = difficulty.MEDIUM
	elif  difficulty_level >= 2:
		difficulty_value = difficulty.HARD

func _on_player_checker_body_entered(body):
	print("the player checker detected:" + str(body.name))
	if (body.is_in_group("Player") || body.is_in_group("player_body")):
		print("Player entered")
		spawn_wave()
		# disable the player checker
		queue_free()

