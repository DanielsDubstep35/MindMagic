extends XROrigin3D

func playerDie():
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		print("No scene_base.gd script Found")
		return
		#
	## Start loading the current scene
	scene_base.load_scene(get_tree().current_scene.get_path())
	
