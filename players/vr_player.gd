extends XROrigin3D

@export_file("*.tscn")
var current_scene : String

func playerDie():
	get_tree().call_group("enemies", "level_cleanup")
	get_tree().call_group("switch", "level_cleanup")
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		print("No scene_base.gd script Found")
		return
		#
	## Start loading the current scene
	scene_base.load_scene(current_scene)
	
	
