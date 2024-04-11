extends GutTest

var staging = preload("res://addons/godot-xr-tools/staging/staging.tscn")
var main_menu = preload("res://Levels/MainMenu.tscn")
var tutorial = preload("res://Levels/TestLevel.tscn")
var begin_game = preload("res://Levels/BeginGame.tscn")
var level_1 = preload("res://Levels/base_level.tscn")
var level_2 = preload("res://Levels/SecondLevel.tscn")
var level_3 = preload("res://Levels/ThirdLevel.tscn")

var array_of_levels = [main_menu, tutorial, begin_game, level_1, level_2, level_3]

var staging_instance 

func before_each():
	staging_instance = get_level_instance(staging)
	add_child(staging_instance)

# Test if a player exists to play a level
func test_CheckPlayerExists():
	for level in array_of_levels:
		var level_instance : Node = get_level_instance(level)
		staging_instance.find_child('Scene').add_child(level_instance)
		add_child_autoqfree(level_instance)
		var player = level_instance.find_child('XROrigin3D')
		assert_not_null(player, "There is a player missing!")
		await get_tree().create_timer(0.2).timeout
		staging_instance.find_child('Scene').remove_child(level_instance)
		
# Test if the player is able to move on to the next level
func test_CheckGoalExists():
	for level in array_of_levels:
		var level_instance = get_level_instance(level)
		staging_instance.find_child('Scene').add_child(level_instance)
		add_child_autoqfree(level_instance)
		var goals = level_instance.find_children('Goal')
		assert_gt(goals.size(), 0, "There is a goal missing!")
		await get_tree().create_timer(0.2).timeout
		staging_instance.find_child('Scene').remove_child(level_instance)
		
# Test if at least one skeleton spawns in relevant levels
func test_CheckSkeletonsSpawn():
	var relevant_levels = [level_1, level_3]
	for level in relevant_levels:
		var level_instance = get_level_instance(level)
		staging_instance.find_child('Scene').add_child(level_instance)
		add_child_autoqfree(level_instance)
		var player = level_instance.find_child('XROrigin3D')
		await get_tree().create_timer(0.2).timeout
		get_tree().call_group("Skeleton_Spawner", "spawn_wave")
		var skeletons = get_tree().get_nodes_in_group("enemies")
		print(skeletons)
		assert_gt(skeletons.size(), 0, "No Skeletons spawned!")
		if skeletons.size() > 0:
			for skele in skeletons:
				skele.queue_free()
		staging_instance.find_child('Scene').remove_child(level_instance)

func get_level_instance(level):
	#var game_instance = level.instantiate()
	var scene_double = double(level).instantiate()
	return scene_double
