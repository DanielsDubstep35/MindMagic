extends Node3D

signal trigger

@export
var activation_goal = 100

var activation_count = 0

@onready
var mesh: MeshInstance3D = $target

@onready
var area_3d: Area3D = $target/Area3D

var switch_on = false

var player_relaxed = false

var wait = false

var in_body = false

var switch_disabled = false

func _process(delta):
		
	if player_relaxed && in_body && !switch_disabled:
		mesh.get_surface_override_material(0).albedo_color = Color(0, 0.557, 1, activation_count)
		mesh.get_surface_override_material(0).emission = Color(0, 0.557, 1, activation_count)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
		switch_on = true
	elif !player_relaxed && in_body && !switch_disabled:
		mesh.get_surface_override_material(0).albedo_color = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission_enabled = false
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
		switch_on = false
		
	if !wait && switch_on && !switch_disabled:
		wait = true
		increment_activation_count()
		await get_tree().create_timer(0.05).timeout
		wait = false
		
	if activation_count >= activation_goal && !switch_disabled:
		switch_disabled = true
		trigger.emit()
		area_3d.monitorable = false
		area_3d.monitoring = false
		mesh.get_surface_override_material(0).albedo_color = Color(0, 0.557, 1)
		mesh.get_surface_override_material(0).emission = Color(0, 0.557, 1)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
		get_tree().call_group("Objective", "switchTriggered")
		get_tree().call_group("Goal", "Progress")
		queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("player_body") && player_relaxed && !in_body && !switch_disabled:
		in_body = true
		mesh.get_surface_override_material(0).albedo_color = Color(0, 0.557, 1, activation_count)
		mesh.get_surface_override_material(0).emission = Color(0, 0.557, 1, activation_count)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
		switch_on = true
	elif body.is_in_group("player_body") && !player_relaxed && !in_body && !switch_disabled:
		in_body = true
		mesh.get_surface_override_material(0).albedo_color = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission_enabled = false
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
		switch_on = false

func level_cleanup():
	queue_free()
	
func increment_activation_count():
	activation_count += 1

func _on_area_3d_body_exited(body):
	if body.is_in_group("player_body") && player_relaxed && in_body && !switch_disabled:
		in_body = false
		mesh.get_surface_override_material(0).albedo_color = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
	elif body.is_in_group("player_body") && !player_relaxed && in_body && !switch_disabled:
		in_body = false
		mesh.get_surface_override_material(0).albedo_color = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission = Color(0.49, 0.49, 0.49, activation_count)
		mesh.get_surface_override_material(0).emission_enabled = true
		mesh.get_surface_override_material(0).emission_energy_multiplier = 20
	switch_on = false

func playerRelaxed():
	player_relaxed = true
	
func playerNotRelaxed():
	player_relaxed = false
