extends RigidBody3D

@export
var Fire_Speed = 2

@export
var bullet_penetration : bool = false

@export
var explosiveness : bool = false

@export
var homing_bullets : bool = false

#@onready
#var BloodParticle : GPUParticles3D = $BloodParticle

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_as_top_level(true)
	await get_tree().create_timer(2).timeout
	queue_free()
	pass

func Fire_shot():
	linear_velocity = -(transform.basis.z * Fire_Speed * 10)
	
func _on_spell_area_body_entered(body):
	if bullet_penetration == false:
		queue_free()
	# if (body.is_in_group("enemies")):
		#BloodParticle.emitting = true
		#print("This enemy just died")
		#body.queue_free()
