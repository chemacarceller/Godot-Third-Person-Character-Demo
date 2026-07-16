# GameMode class
extends GameModeBase

# PlayerPawn
@export var playerPawn: PackedScene = null


func _notification(what) :

	if what == NOTIFICATION_WM_CLOSE_REQUEST :

		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " GameMode Exiting : " + name + " ... ", 'GameMode.gd',11,true)

		var allNodes : Array = _get_all_tree_nodes()

		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Sending CLOSE_REQUEST NOTIFICATION TO ALL NODES : " + str(allNodes), 'GameMode.gd', 15, true)

		# I send the closure notification to all nodes in the scene
		for child in allNodes : child.notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + name + " Instantiated ... ","GameMode.gd",21, true)

func _ready() -> void :

	# Calling the parent _ready() function
	super()

	# Lets get the player position in the scene
	var defaultPosition : Vector3 = Vector3.ZERO
	var defaultRotation : Vector3 = Vector3.ZERO
	if get_playerStart() != null :
		defaultPosition = get_playerStart().position
		defaultRotation = get_playerStart().rotation
	else :
		MyLogger.error("FRAME : " + str(Engine.get_process_frames()) + " : " + "GameModeBase : Not able to instantate the Player. There is no PlayerStart position in the project",'GameMode.gd',36, true)
		if is_instance_valid(GameInstance) and GameInstance.has("_quit_gracefully") : GameInstance._quit_gracefully()
		else : get_tree().quit()

	# Simply verifying so we don't have to call the _setCharacter function
	if GameInstance._character == null and playerPawn == null :
		MyLogger.error("FRAME : " + str(Engine.get_process_frames()) + " : " + "GameMode : Not able to instantate the Player. playerPawn is null",'GameMode.gd',42, true)
		if is_instance_valid(GameInstance) and GameInstance.has("_quit_gracefully") : GameInstance._quit_gracefully()
		else : get_tree().quit()

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Setting Character ... ","GameMode.gd",46, true)
	await _setCharacter(defaultPosition, defaultRotation)
	
	# We execute the game start events just before changing scenes
	if GameInstance.start_game_timer and GameInstance._timer.is_stopped() : GameInstance.start_game_timer()

	# In the initial scene, it  sets the counter to zero initially.
	# In a change scene, it simply shows the seconds without incrementing
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Emitting TicToc event from GameMode ... ","GameMode.gd",54, true)
	GameInstance._on_timer_timeout(false)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + name + " Ready ... ","GameMode.gd",57, true)



# PRIVATE API of the GameMode class

# Private function to be able to instantiate the character and add it to the scene
func _setCharacter(defaultPosition : Vector3, defaultRotation : Vector3) :

	# If _character is not yet setted
	if GameInstance._character == null  :

		# We haven't specified a playerPawn, we can't instantiate the character, we never actually got here
		if playerPawn == null :
			MyLogger.error("FRAME : " + str(Engine.get_process_frames()) + " : " + "The playerPawn PackedScene is not defined", 'GameMode.gd',71, true)
			if is_instance_valid(GameInstance) and GameInstance.has("_quit_gracefully") : GameInstance._quit_gracefully()
			else : get_tree().quit()

		else :

			var pawn_name = playerPawn.resource_path.get_file().get_basename()
			if not GameInstance._prefabs.has(pawn_name):
				MyLogger.error("FRAME : " + str(Engine.get_process_frames()) + " : " + "The playerPawn is not in the preloaded dictionary : " + pawn_name, 'GameMode.gd', 79, true)
				if is_instance_valid(GameInstance) and GameInstance.has("_quit_gracefully") : GameInstance._quit_gracefully()
				else : get_tree().quit()

			else :
				# The GameInstance._character points to the character as do GameInstance._prefabs[pawn_name]
				# Same object, two pointers
				# But GameInstance._character changes in run-time
				GameInstance._character = GameInstance._prefabs[pawn_name]
				MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "Character assigned from preloaded prefabs: " + pawn_name, 'GameMode.gd', 88, true)

	# We already have GameInstance._character pointing to the character, now we add it to the scene
	# LevelManager añade todos los personajes a la escena, pero los elimina
	if not GameInstance._character.is_inside_tree() : add_child(GameInstance._character)
	else : GameInstance._character.reparent(self)
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(GameInstance._character) + " Added to the scene ... ","GameMode.gd",94, true)

	# Up here we already have the _character, by changing level we already have the character
	# We need to say in which position in the level will be and eneble it
	GameInstance._character.position = defaultPosition
	GameInstance._character.rotation = defaultRotation
	GameInstance._character.isEnabled = true
	
	#_character.platform_on_leave = CharacterBody3D.PLATFORM_ON_LEAVE_DO_NOTHING
	GameInstance._character.platform_on_leave = CharacterBody3D.PLATFORM_ON_LEAVE_DO_NOTHING

	# Capture the mouse and keyboard inside the game window
	DisplayServer.window_move_to_foreground()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Function that collects absolutely all the nodes that exist in the current scene tree
# and return them to you within a single list
func _get_all_tree_nodes(node: Node = self, node_list: Array[Node] = []):
	if node != self : node_list.append(node)
	for child_node in node.get_children() : _get_all_tree_nodes(child_node, node_list)
	return node_list


# PUBLIC API of the GameMode class
func get_playerStart() -> Node3D : return get_node("PlayerStart")
