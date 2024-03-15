extends RigidBody3D

@onready
var anim_player: AnimationPlayer = $AnimationPlayer

@export
var Lightning_Speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_as_top_level(true)
	await get_tree().create_timer(3).timeout
	queue_free()
	pass

func Lightning_shot():
	linear_velocity = -(transform.basis.z * Lightning_Speed)
	anim_player.play("LightningBlast")
	pass
	
func _on_spell_area_body_entered(body):
	pass
