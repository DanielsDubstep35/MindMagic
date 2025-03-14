extends Node3D

@onready var fireball = preload("res://CreatedAssets/Wand/fireball.tscn")
@export var wand_muzzle : Node3D
@onready var wand = $"."

@onready var _controller := XRHelpers.get_xr_controller(self)

var spell_boolean = true

# how long until the user can fire another fireball
@onready
var firerate_timer: Timer = $spell_time

@onready
var lightning_timer: Timer = $lightning_time

@onready var eeg_node = preload("res://Miscellaneous/EegNode.tscn")

@export
var eeg_eye_artifact = "Nothing"

var eeg_relaxed = false

@export
var fireSpell: MeshInstance3D

@export
var waterSpell: MeshInstance3D

@export
var RelaxPercent: Label3D

@export
var lightningSpell: MeshInstance3D

@export
var BlinkChecker: Label3D

var water_spell_effect = null

# Spell Variables
var spell_selected = 0

var Emotion = ""
#var BetaMetric = "0"
#var Theta = "0"
#var Delta = "0"
#var Emotion = "Neutral"

# FROM EEG NODE SCRIPT
# has to be the same  as the pico ip address
const UDP_IP = "192.168.1.103"
const UDP_PORT = 3342

var server := UDPServer.new()

var listening = true

signal eeg_relaxed_sig

signal eeg_not_relaxed_sig

func _ready():
	firerate_timer.one_shot = true
	firerate_timer.wait_time = 0.1
	set_process(false)
	start_listening()

func _process(delta):
	
	fireSpell.get_surface_override_material(0).albedo_color = Color(1.0, 1.0, 1.0, 1 - normalize_data(0.1, 0.0, firerate_timer.time_left))
	lightningSpell.get_surface_override_material(0).albedo_color = Color(1.0, 1.0, 1.0, 1 - normalize_data(3.0, 0.0, lightning_timer.time_left))
	
	if eeg_relaxed:
		waterSpell.get_surface_override_material(0).emission_enabled = true
	else:
		waterSpell.get_surface_override_material(0).emission_enabled = false

	if water_spell_effect != null:
		water_spell_effect.global_transform = wand_muzzle.global_transform

	server.poll()
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet().get_string_from_utf8()
		peer.put_packet(packet.to_utf8_buffer())
		var jsonStuff = JSON.new()
		packet = jsonStuff.parse_string(packet)

		if packet is Array:
			var py_type = packet.pop_front()

			match py_type:
				"PYTHON":
					eeg_eye_artifact = str(packet[0])
					
					Emotion = str(packet[1])
					
					RelaxPercent.text = str(packet[2])
					BlinkChecker.text = eeg_eye_artifact
					
					if str(packet[1]) == "Relaxed":
						trigger_waterblast()
						eeg_relaxed_sig.emit()
						get_tree().call_group("switchWater", "playerRelaxed")
					else:
						untrigger_waterblast()
						eeg_not_relaxed_sig.emit()
						get_tree().call_group("switchWater", "playerNotRelaxed")
						print(str(packet[1]))
					
					#BetaMetric = str(packet[2])
					#Theta = str(packet[3])
					#Delta = str(packet[4])
					#Emotion = str(packet[5])

		else:
			listening

	print(eeg_eye_artifact)

	#if there is no controller
	if !_controller.get_is_active():
		print("Error from Wand.gd: There is no controller present")
		return

	# Controllers not needed to check for eye blinks
	if _controller.get_is_active():
		#print(firerate_timer.time_left)
		if _controller.get_float("trigger") > 0.8 && firerate_timer.is_stopped():
			shoot_fireball()
		#print("BY BUTTON IS: " + str(_controller.get_input("by_button")))
		
		#if _controller.get_input("by_button") && lightning_timer.is_stopped():
			##print("LIGHTNINGBLAST!")
			#shoot_lightningbolt()
			#
		#if _controller.get_input("secondary_touch") && eeg_relaxed == false:
			#trigger_waterblast()
			#eeg_relaxed_sig.emit()
			#get_tree().call_group("switchWater", "playerRelaxed")
		#else:
			##untrigger_waterblast()
			##eeg_not_relaxed_sig.emit()
			##get_tree().call_group("switchWater", "playerNotRelaxed")
			#pass
			
		if eeg_eye_artifact == "Blink" && lightning_timer.is_stopped():
			shoot_lightningbolt()
			
	# if Blink, shoot something
	#if eeg_eye_artifact == "Blink" && spell_boolean:
		#shoot()
	#elif eeg_eye_artifact == "Neutral":
		#print("Not currently blinking!")
	#else:
		#pass
		##print(eeg_eye_artifact)

func start_listening():
# warning-ignore:return_value_discarded
	server.listen(UDP_PORT)
	set_process(true)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		listening = false
		stop_listening()
	elif what == NOTIFICATION_EXIT_TREE:
		listening = false
		#for pid in process_pids:
			#print("Closing PID: " + str(pid))
		#print("Process Done")
		#print("Running KILLCODE")
		stop_listening()

func stop_listening():
	server.stop()
	set_process(false)

func _on_timer_timeout():
	spell_boolean = true
	pass # Replace with function body.

func shoot_fireball():
	var fireball_load = preload("res://CreatedAssets/Wand/fireball.tscn")
	var spell = null
	var spell_anim: AnimationPlayer = null
	spell = fireball_load.instantiate()
	spell_anim = fireSpell.get_node("MeshInstance3D")
	get_tree().root.add_child(spell)
	spell.global_transform = wand_muzzle.global_transform
	spell.Fire_shot()
	firerate_timer.start(0.1)
	#spell_ui.mesh.surface_get_material()

	#print("firebolt shot")

func shoot_lightningbolt():
	var lightningblast_load = preload("res://CreatedAssets/Wand/lightningbolt.tscn")
	var spell = null
	var spell_anim: AnimationPlayer = null
	spell = lightningblast_load.instantiate()
	spell_anim = lightningSpell.get_node("MeshInstance3D")
	get_tree().root.add_child(spell)
	spell.global_transform = wand_muzzle.global_transform
	spell.Lightning_shot()
	lightning_timer.start(3)

func trigger_waterblast():
	if eeg_relaxed == false:
		eeg_relaxed = true
		var waterblast_load = preload("res://CreatedAssets/Wand/waterblast.tscn")
		water_spell_effect = waterblast_load.instantiate()
		get_tree().root.add_child(water_spell_effect)
		water_spell_effect.global_transform = wand_muzzle.global_transform
		water_spell_effect.Water_spawn()
		await get_tree().create_timer(2).timeout
		untrigger_waterblast()

func untrigger_waterblast():
	if eeg_relaxed == true:
		eeg_relaxed = false
		water_spell_effect.Dissolve_water()
		water_spell_effect = null

func normalize_data(max_data: float, min_data: float, data: float):
	var normalized_number = (data - min_data) / (max_data - min_data)
	return normalized_number
