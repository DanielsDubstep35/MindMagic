extends Node

@export
var Wand : String = "../XROrigin3D/Right/Wand:eeg_eye_artifact"

@export
var Channel1 : String

@export
var Channel2 : String

@export
var Channel3 : String

@export
var Channel4 : String

# has to be the same  as the pico ip address
const UDP_IP = "127.0.0.1"
const UDP_PORT = 4244

var server := UDPServer.new()
var process_pids := []

var interpreter_path = ""
var script_path = ""
var script_output = []

var listening = true

var connections = []

func _ready():

	set_process(false)
	if !OS.has_feature("standalone"):
		print("NOT NATIVE")
		interpreter_path = ProjectSettings.globalize_path("res://Python/venv/bin/python3")
		script_path = ProjectSettings.globalize_path("res://Psython/main.py")

	#interpreter_path = "/Users/danielmendes/Desktop/FYPGame/InterimDemo/EEG_Scripts/fyp_eeg_scripting/bin/python"
	#script_path = "/Users/danielmendes/Desktop/FYPGame/InterimDemo/EEG_Scripts/src/EEG_DummyData.py"
	
	start_PythonListening()

func _process(_delta):
	# warning-ignore:return_value_discarded
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
				"PIDs":
					process_pids.append_array(packet)
				"PYTHON":
					
					Wand = str(packet[0])
					Channel1 = str(packet[1])
					Channel2 = str(packet[2])
					Channel3 = str(packet[3])
					Channel4 = str(packet[4])
				
		else:
			listening

func start_listening():
# warning-ignore:return_value_discarded
	server.listen(UDP_PORT)
	set_process(true)

func stop_listening():
	server.stop()
	set_process(false)
	
func start_PythonListening():
	start_listening()
	# run_Python("GODOT", "IS", "COOL")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		listening = false
		kill_processes()
		stop_listening()
	elif what == NOTIFICATION_EXIT_TREE:
		listening = false
		for pid in process_pids:
			print("Closing PID: " + str(pid))
		print("Process Done")
		print("Running KILLCODE")
		kill_processes()
		stop_listening()

# function no longer needed
func run_Python(title, subtitle, body):
	var PID = OS.create_process(interpreter_path, [script_path, title, subtitle, body])
	process_pids.append(float(PID))

func kill_processes():
	for pid in process_pids:
		OS.kill(pid)
		
func exportCH0():
	return Wand
	
func exportCH1():
	return Channel1
	
func exportCH2():
	return Channel2
	
func exportCH3():
	return Channel3

func exportCH4():
	return Channel4
