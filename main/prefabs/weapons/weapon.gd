class_name Weapon extends Area3D

# Which bullet the weapon fires can be changed at run-time
# All weapons must have a bullet to be fired
@export var bullet: PackedScene 

# Takes the count of the bullets fired
var bullet_count : int = 0

func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... " + str(self), 'weapon.gd',12,true)

func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'weapon.gd',14,true)

# If it is notificated to close
func _notification(what) : 
	if what == NOTIFICATION_WM_CLOSE_REQUEST : 
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting the weapon ... " + str(self), 'weapon.gd',17,true)

# Method to fire a bullet
func fire() -> void :

	# Stores the bullet object
	var _bullet : Area3D = null

	if bullet == null :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Error: No bullet scene assigned to " + name, 'weapon.gd', 26, true)
		return

	bullet_count += 1

	_bullet = bullet.instantiate()
	_bullet.name = "Bullet" + str(bullet_count)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " A bullet is instantiated ... " + str(_bullet), 'weapon.gd',34,true)

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
	_bullet.get_movementComponent().set_direction(direction_vector)
