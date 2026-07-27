class_name Weapon extends Area3D

# Which bullet the weapon fires can be changed at run-time
@export var bullet: PackedScene 

# Indicates if it is the weapon is allowed to fire
var _isFireEnabled : bool = true

# If it is notificated to close
func _notification(what) : 
	if what == NOTIFICATION_WM_CLOSE_REQUEST : 
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting the weapon ... " + str(self), 'weapon.gd',12,true)

func _enter_tree() -> void : 
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... " + str(self), 'weapon.gd',14,true)

	# When the weapon is created, it subscribes to the event system for weapon settings on the character.
	if not EventBus.is_subscribed(EventBus.EVENT.Movement_Changed, onWeaponPositionAdjusting) :
		EventBus.subscribe(EventBus.EVENT.Movement_Changed, onWeaponPositionAdjusting)

func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'weapon.gd',16,true)

var bullet_count : int = 0

# Method to fire a bullet
func fire() -> void :

	# Stores the bullet object
	var _bullet : Area3D = null

	if bullet == null :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Error: No bullet scene assigned to " + name, 'weapon.gd', 27, true)
		return

	bullet_count += 1

	_bullet = bullet.instantiate()
	_bullet.name = "Bullet" + str(bullet_count)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " A bullet is instantiated ... " + str(_bullet), 'weapon.gd',35,true)

	# to put an invisible "sticker" on the bullet with extra information that was not defined in its original script
	# which character is shooting
	_bullet.set_meta("shooter", owner)

	# Putting the bullet in the game, remember the LevelManager,actual_level stores the level we are playing
	LevelManager.actual_level.add_child(_bullet)

	# Establishing the bullet position it is the same as the weapon position in the world
	_bullet.global_position = global_position

	# Establishing the bullet direction, the speed is configured in the movement component
	# The firing direction is the direction in which the character moves forward.
	# It doesnt change the high position
	var direction_vector : Vector3 = owner.get_movementComponent().get_direction()
	direction_vector.y = 0
	direction_vector = direction_vector.normalized()
	
	print("OWNER : ====================> ", str(direction_vector))

	# We establish the direction of the bullet
	_bullet.get_movementComponent().set_direction(direction_vector)


# For doing smooth movement
var tween : Tween = null

# This function adjusts the weapon rotation based on the character and the type of movement they are making
func onWeaponPositionAdjusting(value) -> void :

	# If the weapon is not owned by a character, it exits
	# When the weapon is created, it subscribes, but it only takes effect if the character is holding the weapon.
	if not (owner is CharacterBody3D): return

	# Weapon rotation
	var target_rotation: Vector3 = Vector3.ZERO

	# Depending on the type of movement, the rotation defined for each character is applied.
	if value[0] == "Runing" : target_rotation = GameInstance._character.running_rotation
	elif value[0] == "Walking" : target_rotation = GameInstance._character.walking_rotation
	elif value[0] == "Idle" : target_rotation = GameInstance._character.idle_rotation
	else : return

	# We convert the degrees of the configuration to radians
	var target_rad = Vector3(
		deg_to_rad(target_rotation.x), 
		deg_to_rad(target_rotation.y), 
		deg_to_rad(target_rotation.z)
	)

	# Option A: Instantaneous movement
	# rotation = target_rad

	# Option B: Smooth movement (Much better visually)
	# We kill the previous Tween before creating a new one:
	if tween : tween.kill() 
	tween = create_tween()
	tween.tween_property(self, "rotation", target_rad, 0.1).set_trans(Tween.TRANS_SINE)



# Input capture
func _input(_event) -> void:

	# If the character is moving and not jumping nor falling is allowed to shoot (by walking or running), otherwise not
	if owner is CharacterBody3D :

		var move_comp = owner.get_movementComponent()

		if move_comp != null :

			if move_comp.get_isMoving() and not move_comp.get_isJumping() and not move_comp.get_isFalling() :

				# I wanted to use is_action_just_pressed but it doesnt work perfectly, instead i use is_action_pressed and make my own code to convert
				if _event.is_action_pressed("fire") and _isFireEnabled:

					# Firing an semi-automatic weapon need to release the button to fire again
					fire()

					# Disable the fire system until the button is released
					_isFireEnabled = false

				# When the button is released we can fire again
				if Input.is_action_just_released("fire") and not _isFireEnabled : _isFireEnabled = true
