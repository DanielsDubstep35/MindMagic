extends Node3D

signal trigger

@onready
var mesh: MeshInstance3D = $target

var switch_on = false

func _on_area_3d_body_entered(body):
	print("Object that entered the switch is:" + body.name)
	if body.is_in_group("LightningBlast") && !switch_on:
		trigger.emit()
		mesh.get_surface_override_material(0).albedo_color = Color(0.867, 0.875, 0)
		mesh.get_surface_override_material(0).emission = Color(0.867, 0.875, 0)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 16
		
func switch_off():
	mesh.get_surface_override_material(0).albedo_color = Color(0.49, 0.49, 0.49)
	mesh.get_surface_override_material(0).emission = Color(0.49, 0.49, 0.49)
	mesh.get_surface_override_material(0).emission_enabled = false
	mesh.get_surface_override_material(0).emission_energy_multiplier = 1

func level_cleanup():
	queue_free()
