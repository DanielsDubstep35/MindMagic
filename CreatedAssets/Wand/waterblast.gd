extends RigidBody3D

@onready
var anim_player: AnimationPlayer = $AnimationPlayer

@export
var water_sound : AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_as_top_level(true)
	pass

func Water_spawn():
	anim_player.play("water_appear")
	if !water_sound.playing:
		water_sound.playing = true
	pass
	
func Dissolve_water():
	anim_player.play("water_dissappear")
	await get_tree().create_timer(2).timeout
	if water_sound.playing:
		water_sound.playing = false
	queue_free()
	
	
func _on_spell_area_body_entered(body):
	pass
