extends GPUParticles3D

@export
var particle_time = 2.5

func _ready():
	emitting = true
	await get_tree().create_timer(particle_time).timeout
	queue_free()
	pass
