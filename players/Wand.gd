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

@export
var fireSpell: Node3D

@export
var waterSpell: Node3D

@export
var lightningSpell: Node3D

# Spell Variables
var spell_selected = 0

var AlphaMetric = "0"
var BetaMetric = "0"
var Theta = "0"
var Delta = "0"
var Emotion = "Neutral"

# FROM EEG NODE SCRIPT
# has to be the same  as the pico ip address
const UDP_IP = "192.168.1.103"
const UDP_PORT = 3342

var server := UDPServer.new()

var listening = true

func _ready():
	firerate_timer.one_shot = true
	firerate_timer.wait_time = 0.75
	set_process(false)
	start_listening()

func _process(delta):
	
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
					AlphaMetric = str(packet[1])
					BetaMetric = str(packet[2])
					Theta = str(packet[3])
					Delta = str(packet[4])	
					Emotion = str(packet[5])	
				
		else:
			listening
	
	print(eeg_eye_artifact)
	
	#if there is no controller
	if !_controller.get_is_active():
		print("Error from Wand.gd: There is no controller present")
		return
	
	# Controllers not needed to check for eye blinks
	if _controller.get_is_active(): 
		print(firerate_timer.time_left)
		if _controller.get_float("trigger") > 0.8 && firerate_timer.is_stopped():
			shoot_fireball()
		print("BY BUTTON IS: " + str(_controller.get_input("by_button")))
		if _controller.get_input("by_button") && lightning_timer.is_stopped():
			print("LIGHTNINGBLAST!")
			shoot_lightningblast()
	
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
	var spell_ui: MeshInstance3D = null
	spell = fireball_load.instantiate()
	spell_ui = fireSpell.get_node("MeshInstance3D")
	get_tree().root.add_child(spell)
	spell.global_transform = wand_muzzle.global_transform
	spell.Fire_shot()
	firerate_timer.start(0.1)
	#spell_ui.mesh.surface_get_material()
	
	#print("firebolt shot")

func shoot_lightningblast():
	var lightningblast_load = preload("res://CreatedAssets/Wand/lightningbolt.tscn")
	var spell = null
	var spell_ui: MeshInstance3D = null
	spell = lightningblast_load.instantiate()
	spell_ui = lightningSpell.get_node("MeshInstance3D")
	get_tree().root.add_child(spell)
	spell.global_transform = wand_muzzle.global_transform
	spell.Lightning_shot()
	lightning_timer.start(3)
