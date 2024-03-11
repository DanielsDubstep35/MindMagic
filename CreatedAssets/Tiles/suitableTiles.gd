extends Node3D

# edit tree structure in Godot to remove node3d, so that each tile is a mesh instance

func _on_child_entered_tree(node):
	print("Function Triggered :D")
	if node is Node3D:
		node.queue_free()
	else:
		print("Nothing has happened")
