extends RigidBody3D

@export
var Fire_Speed = 2

@export
var bullet_penetration : bool = true

@export
var explosiveness : bool = false

@export
var homing_bullets : bool = false

@export
var fire_sound : AudioStreamPlayer3D

#@onready
#var BloodParticle : GPUParticles3D = $BloodParticle

# Called when the node enters the scene tree for the first time.
func _ready():
	fire_sound.playing = true
	#set_as_top_level(true)
	await get_tree().create_timer(2).timeout
	fire_sound.playing = false
	queue_free()
	pass

func Fire_shot():
	linear_velocity = -(transform.basis.z * Fire_Speed * 10)

func FireAtPlayer(playerPosition):
	var direction = playerPosition - global_transform.origin
	direction = direction.normalized()
	linear_velocity = direction * Fire_Speed * 1

func _on_spell_area_body_entered(body):
	
	if bullet_penetration == false:
		queue_free()
	# if (body.is_in_group("enemies")):
		#BloodParticle.emitting = true
		#print("This enemy just died")
		#body.queue_free()
