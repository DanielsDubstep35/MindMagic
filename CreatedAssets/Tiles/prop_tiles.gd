extends Node3D

func _ready():
	print("ready")
	for i in get_child_count():
		print(get_child(i))
