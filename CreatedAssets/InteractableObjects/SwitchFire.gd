extends Node3D

signal trigger

@onready
var mesh: MeshInstance3D = $target

var switch_on = false

func _on_area_3d_body_entered(body):
	print("Object that entered the switch is:" + body.name)
	if body.is_in_group("Fireball") && !switch_on:
		trigger.emit()
		mesh.get_surface_override_material(0).albedo_color = Color(1, 0, 0)
		mesh.get_surface_override_material(0).emission = Color(1, 0, 0)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 16
	switch_on = true

func level_cleanup():
	queue_free()
