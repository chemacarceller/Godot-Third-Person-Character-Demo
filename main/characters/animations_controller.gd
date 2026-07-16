class_name  AnimationsController extends AnimationTree

# Indicating during how many frames must be detected the fall movement happens continuosly 
# until the animation takes place. To avoid short animations changes
@export_range(1,30) var FALLING_FRAMES_DETECTION : int = 5

# Variables to control the falling offset initialization 
var _fallingOffset : int = 0

# We get the state machine of the AnimationTree
@onready var state_machine := get("parameters/playback") as AnimationNodeStateMachinePlayback
var prev_node : StringName = ""
var prev_direction : int = -1

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		MyLogger.info("Saliendo del animation controller",'animations_controller.gd',17, true)

func _ready() -> void :  MyLogger.info(" AnimationController Ready " + name + " ...", 'animations_controller.gd', 19, true)

func _enter_tree() -> void : MyLogger.info(" AnimationController instantiated " + name + " ...", 'animations_controller.gd', 21, true)

func _physics_process(_delta: float) -> void:

	var current_node : StringName = ""
	var movementComponent = get_parent().get_movementComponent()
	var state = movementComponent.get_state()
	var isArmed = get_parent().get_isArmed()
	var direction = movementComponent.get_directionstate()

	# Current node's name executing
	if state_machine != null : current_node = state_machine.get_current_node()

	var node_changed = (current_node != prev_node)
	var direction_changed = (direction != prev_direction)

	# Setting the animations transitions
	var is_idle : bool = true if state == movementComponent.MOVEMENT_STATE.IDLE else false
	var is_walking : bool = true if state == movementComponent.MOVEMENT_STATE.WALKING and not isArmed  else false
	var is_walkingArmed : bool = true if state == movementComponent.MOVEMENT_STATE.WALKING and isArmed else false
	var is_runing : bool = true if state == movementComponent.MOVEMENT_STATE.RUNING and not isArmed  else false
	var is_runingArmed : bool = true if state == movementComponent.MOVEMENT_STATE.RUNING and isArmed  else false
	var is_falling_state : bool = true if state == movementComponent.MOVEMENT_STATE.FALLING else false
	var is_falling : bool = true if state == movementComponent.MOVEMENT_STATE.FALLING and _fallingOffset > FALLING_FRAMES_DETECTION else false
	var is_jumping : bool = true if state == movementComponent.MOVEMENT_STATE.JUMPING else false
	
	if is_falling_state: _fallingOffset += 1
	else : _fallingOffset = 0

	# Doing the transitions
	if get("parameters/conditions/idle") != is_idle : set("parameters/conditions/idle",  is_idle)
	if get("parameters/conditions/walk") != is_walking : set("parameters/conditions/walk",  is_walking)
	if get("parameters/conditions/walkArmed") != is_walkingArmed : set("parameters/conditions/walkArmed",  is_walkingArmed)
	if get("parameters/conditions/run") != is_runing: set("parameters/conditions/run", is_runing)
	if get("parameters/conditions/runArmed") != is_runingArmed: set("parameters/conditions/runArmed", is_runingArmed)
	if get("parameters/conditions/fall") != is_falling : set("parameters/conditions/fall", is_falling)
	if get("parameters/conditions/jump") != is_jumping: set("parameters/conditions/jump", is_jumping)
	
	
	
	
	# The second condition is added for changing scenes but the direction doesnt change but the state does
	if direction_changed or node_changed :

		prev_direction = direction

		if direction == movementComponent.DIRECTION_MODE.NONE :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","None"])
		elif direction == movementComponent.DIRECTION_MODE.STRAIFLEFT :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Straif Left"])
		elif direction == movementComponent.DIRECTION_MODE.LEFTFOR :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Straif Left and Forward"])
		elif direction == movementComponent.DIRECTION_MODE.LEFTBACK :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Straif Left and Backward"])
		elif direction == movementComponent.DIRECTION_MODE.STRAIFRIGHT :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Straif Right"])
		elif direction == movementComponent.DIRECTION_MODE.RIGHTFOR :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Straif Right and Forward"])
		elif direction == movementComponent.DIRECTION_MODE.RIGHTBACK :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Straif Right and Backward"])
		elif direction == movementComponent.DIRECTION_MODE.FORWARD :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Forward"])
		elif direction == movementComponent.DIRECTION_MODE.BACKWARD :
			EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["","Backward"])

		# If the new state is diferent from previous
		if node_changed :

			prev_node = current_node

			#Emiting the corresponding signal, used plugin EventBus
			match current_node :
				"Idle": EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Idle",""])
				"Walk": EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Walking",""])
				"WalkArmed": EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Walking",""])
				"Run":  EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Runing",""])
				"RunArmed":  EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Runing",""])
				"Jump": EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Jumping",""])
				"Fall": EventBus.emit(self._physics_process, EventBus.EVENT.Movement_Changed,["Falling",""])
