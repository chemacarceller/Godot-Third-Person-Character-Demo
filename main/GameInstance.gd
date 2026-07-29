extends GameInstanceBase

# Timer for counting global seconds
# In _ready it will be added to the scenetree
var _timer := Timer.new()

# It stores the count of seconds of running game time
var _count : int = 0

# The game character
var _character : CharacterBody3D = null

# GameInstance variables that store materials, meshes
# They do not need to be released since what they store inherits from RefCounted
var _materials: Array[Material] = []
var _meshes : Array[Mesh] = []

# Prefabs would be those objects that are not physically in the scene,
# susceptible to being spawned, saving an instantiated copy for performance
# Memory needs to be freed when closing the game to avoid memory leaks
var _prefabs : Dictionary = {}

# Flag variables for the world_environment,
# to avoid applying the Renderer settings multiple times to a scene
# One variable per scene
var main_environment : bool = false
var second_environment : bool = false

# Unified Data Structure for Hardware and Video Status
var gpu_data : Dictionary = {
	"vp_detected": false,          # Checks if the Viewport/Hardware has already been processed
	"vram": 512.0 / 1024.0,        # Secure default value in Gigabytes
	"type": 0                      # Device Type (Dedicated, Integrated, etc.)
}

# Graphics profile applied to the game; if it's DEFAULT, it means it has been automatically selected based on VRAM
var graphicsProfile : ConfigRender.Profile = ConfigRender.Profile.DEFAULT

# Mapping dictionaries to avoid giant match/if blocks
@onready var CHARACTER_MAP := {
	KEY_F1: "manequin1",
	KEY_F2: "manequin2",
	KEY_F3: "man",
	KEY_F4: "remi",
	KEY_F5: "brian"
}

var _is_quitting : bool = false

# How to handle a save quiting in the GameInstance
func _notification(what):

	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN : Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if what == NOTIFICATION_WM_CLOSE_REQUEST :

		if _is_quitting : return 
		else : _is_quitting = true

		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Exiting...",str(self), 60, true)

		# Removing all the content of the _prefabs diccionary
		for key in _prefabs :
			if is_instance_valid(_prefabs[key]) :
				MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Active prefab released with queue_free: " + str(_prefabs[key]),str(self), 65, true)
				_prefabs[key].queue_free()
		_prefabs.clear()
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "The prefabs dictionary is cleared...",str(self), 68, true)

		## Removing _timer and queue_free the memory
		if _timer != null :
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "The GameInstance Timer is queue_free and set to null for avoiding memory leak : ",str(self), 71, true)			
			_timer.stop()
			_timer.queue_free()
			_timer = null
		
		# We empty the _materials and _meshes arrays
		_materials.clear()
		_meshes.clear()
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "The _materials and _meshes dictionaries are cleared...",str(self), 80, true)

		# The close message is sent to all the first-level nodes of the scenetree except this one
		for child in get_tree().root.get_children() :
			if child != self :
				MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Notification sent to :" + child.name,str(self), 85, true)
				child.notification(NOTIFICATION_WM_CLOSE_REQUEST)

# When the GameInstance is created
func _enter_tree() -> void : 		
	if has_node("/root/MyLogger") or is_instance_valid(Engine.get_singleton("MyLogger")):
		var _target = get_node("/root/MyLogger") if has_node("/root/MyLogger") else Engine.get_singleton("MyLogger")
		if _target.has_method("info") and _target.has_method("warn") and _target.has_method("error") :
			# We create the log file and add the first message
			# Since GameInstance is the first Global instance, I understand it will be the first one to load.
			MyLogger.resetLogFile()
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Checked the success of MyLogger existence ... ",str(self),96, true)
		else : 
			print("FRAME : " + str(Engine.get_process_frames()) + " : " + "Error: The C++ class MyLogger does not have the appropriate methods")
			# Close the game completely and make sure the script stops running immediately at that point.
			_quit_gracefully(false)
	else:
		print("FRAME : " + str(Engine.get_process_frames()) + " : " + "Error: The C++ class MyLogger is not registered")
		# Close the game completely and make sure the script stops running immediately at that point.
		_quit_gracefully(false)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Instantiated ... ",str(self),106, true)

# When GameInstance is added to the system
func _ready() -> void :

	# Calling the parent _ready() function
	super()

	# We preload the available characters of our game in memory
	_prefabs['brian'] = preload('res://main/characters/brian.tscn').instantiate()
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Character brian loaded in memory ... ",str(self),116, true)
	_prefabs['man'] = preload('res://main/characters/man.tscn').instantiate()
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Character man loaded in memory ... ",str(self),118, true)
	_prefabs['manequin1'] = preload('res://main/characters/manequin1.tscn').instantiate()
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Character manequin1 loaded in memory ... ",str(self),120, true)
	_prefabs['manequin2'] = preload('res://main/characters/manequin2.tscn').instantiate()
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Character manequin2 loaded in memory ... ",str(self),122, true)
	_prefabs['remi'] = preload('res://main/characters/remi.tscn').instantiate()
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Character remi loaded in memory ... ",str(self),124, true)
	
	# List of required singletons to be checked
	var required_globals = ["EventBus", "LevelManager"]
	var missing_globals = []

	for global_name in required_globals:
		if not is_instance_valid(get_node_or_null("/root/" + global_name)):
			missing_globals.append(global_name)

	# If anyone is missing, we abort the mission
	if missing_globals.size() > 0 :

		var error_msg = "CRITICAL ERROR: Missing Autoloads : " + str(missing_globals)
		
		MyLogger.error("FRAME : " + str(Engine.get_process_frames()) + " : " + error_msg,str(self), 139, true)

		# We disable the main loop
		set_process(false) 

		# Exiting the game
		_quit_gracefully()

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(required_globals) + "  available ... ",str(self),147, true)

	# Set that the mouse is Captured by the Game also included in GameModes
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# We set up the second counter, add to the scene_tree, but not starting
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = 1.0
	add_child(_timer)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Ready ... ",str(self),157, true)


# Function that starts the timer if it is off
func start_game_timer() -> void:
	if _timer.is_stopped() :
		_timer.start()
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "GameInstance Global timer started",str(self), 164, true)

# Function that runs every second, can be called from outside at any time
# indicating whether or not we want to increment the counter
func _on_timer_timeout(should_increment : bool = true) :
	if should_increment : _count += 1
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Emiting GameInstance Global timer event",str(self), 170, true)
	EventBus.emit(_on_timer_timeout, EventBus.EVENT.Time_TicToc, _count)


# Code to replace a Character in the Game
func _replaceCharacter(new_char_key: String) -> void:

	var newCharacter = _prefabs.get(new_char_key)

	if not is_instance_valid(newCharacter) or newCharacter == _character :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "The new Character is the same as the old one : " + str(newCharacter),str(self), 180, true) 
		return

	# Get context if it exists
	var context : CharactersData = null
	if is_instance_valid(_character) :
		if _character.has_method("get_context") : context = _character.get_context()
		if _character.get_parent() : _character.get_parent().remove_child(_character)
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Got the context of the previous character",str(self), 188, true) 
		
	if newCharacter.get_parent() : 
		newCharacter.get_parent().remove_child(newCharacter)
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Removed the previous character",str(self), 192, true) 

	_character = newCharacter
	_character.platform_on_leave = CharacterBody3D.PLATFORM_ON_LEAVE_DO_NOTHING
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Set the new character",str(self), 196, true) 

	# Adding the actual level
	if LevelManager.actual_level :
		LevelManager.actual_level.add_child(_character)
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Added the new character to the scene",str(self), 201, true) 
		if context and _character.has_method("set_context") : 
			_character.set_context(context)
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Set the context of the old character to the new one",str(self), 204, true) 

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Changed Character to: " + new_char_key,str(self), 196, true)

# Flag that allows unhandled_input or not
var is_ready_to_unhandled_input = false

func _unhandled_input(event: InputEvent) -> void:

	if not event is InputEventKey or not event.pressed : return

	if not is_ready_to_unhandled_input : return

	# To switch characters
	if CHARACTER_MAP.has(event.keycode) : 
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Pressed a key to change the character",str(self), 219, true) 
		_replaceCharacter(CHARACTER_MAP[event.keycode])

	# To change the camera mode
	var cam_controller = _character.get_cameraController() if _character else null
	if cam_controller :
		match event.keycode :
			KEY_1: _update_camera(cam_controller, cam_controller.CAMERA_MODE.STATIC, "STATIC")
			KEY_2: _update_camera(cam_controller, cam_controller.CAMERA_MODE.THIRD_PERSON, "THIRD_PERSON")
			KEY_3: _update_camera(cam_controller, cam_controller.CAMERA_MODE.THIRD_PERSON_ZOOM, "THIRD_PERSON_ZOOMED")
			KEY_0: _update_camera(cam_controller, cam_controller.CAMERA_MODE.FULL, "FULL")

	# Change graphics quality using keyboard shortcuts
	var vp : Viewport = get_viewport()
	var environment : Environment = get_tree().current_scene.find_child("WorldEnvironment", true, false).environment
	match event.keycode :
		KEY_L : 
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Pressed L key",str(self), 236, true) 
			# We disable vp_detected to be able to apply the Viewport configuration
			# Environment configuration is always performed if we have switched to manual mode
			gpu_data["vp_detected"] = false
			if graphicsProfile != ConfigRender.Profile.LOW :
				graphicsProfile = ConfigRender.Profile.LOW
				ConfigRender.apply_graphics_profile(ConfigRender.Profile.LOW, vp, environment)
				EventBus.emit(_unhandled_input, EventBus.EVENT.GraphicProfile_Changed, "LOW")
			# We activate vp_detected to prevent the Viewport configuration from being re-executed when the scene changes
			gpu_data["vp_detected"] = true
		KEY_M : 
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Pressed M key",str(self), 247, true) 
			gpu_data["vp_detected"] = false
			if graphicsProfile != ConfigRender.Profile.MEDIUM :
				graphicsProfile = ConfigRender.Profile.MEDIUM
				ConfigRender.apply_graphics_profile(ConfigRender.Profile.MEDIUM, vp, environment)
				EventBus.emit(_unhandled_input, EventBus.EVENT.GraphicProfile_Changed, "MEDIUM")
			gpu_data["vp_detected"] = true
		KEY_H : 
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Pressed H key",str(self), 255, true) 
			gpu_data["vp_detected"] = false
			if graphicsProfile != ConfigRender.Profile.HIGH :
				graphicsProfile = ConfigRender.Profile.HIGH
				ConfigRender.apply_graphics_profile(ConfigRender.Profile.HIGH, vp, environment)
				EventBus.emit(_unhandled_input, EventBus.EVENT.GraphicProfile_Changed, "HIGH")
			gpu_data["vp_detected"] = true
		KEY_U : 
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Pressed U key",str(self), 263, true) 
			gpu_data["vp_detected"] = false
			if graphicsProfile != ConfigRender.Profile.ULTRA :
				graphicsProfile = ConfigRender.Profile.ULTRA
				ConfigRender.apply_graphics_profile(ConfigRender.Profile.ULTRA, vp, environment)
				EventBus.emit(_unhandled_input, EventBus.EVENT.GraphicProfile_Changed, "ULTRA")
			gpu_data["vp_detected"] = true

	# To exit the game
	if event.keycode == KEY_ESCAPE : 
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Pressed ESC key",str(self), 273, true) 
		_quit_gracefully()

# Function called when the camera mode is to be changed
func _update_camera(controller, mode, mode_name: String) -> void :
	if controller.cameraMode != mode :
		controller.change_cameraMode(mode)
		EventBus.emit(_update_camera, EventBus.EVENT.CameraMode_Changed, mode_name)
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Camera changed to: " + mode_name,str(self), 281, true)

# Function used for a controlled game exit; if false is passed, Mylogger should be ignored
func _quit_gracefully( existMyLogger : bool = true) -> void :

	if existMyLogger : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Safe quitting...",str(self), 286, true)

	# Notify GameInstance of the controlled shutdown
	GameInstance.notification(NOTIFICATION_WM_CLOSE_REQUEST)

	if existMyLogger :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Last log: Freeing C++ Singleton memory",str(self), 292, true)
		MyLogger.free()

	# Definitive game exit
	get_tree().quit()
