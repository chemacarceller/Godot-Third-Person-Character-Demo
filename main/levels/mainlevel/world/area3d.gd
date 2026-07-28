extends Area3D

@onready var weapon : Weapon = get_node("Weapon")

func _notification(what) :
	if what == NOTIFICATION_WM_CLOSE_REQUEST :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting ... " + name, 'area_3d.gd',5,true)

func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ","area3d.gd",7, true)

func _ready() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... " + str(self),"area3d.gd",10, true)

	# Remove the weapon's Area3D from the scene, inside there is no weapon
	if is_instance_valid(GameInstance._character) and not GameInstance._character.is_queued_for_deletion() :
		if GameInstance._character.get_isArmed() : 
			MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Destroyed ... " + str(self),"area3d.gd",15, true)
			for child in get_children() :
				MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(child.get_path()) + " Destroyed ... " + str(child),"area3d.gd",17, true)

			# Before removing the weapon, I unsubscribe it from the event system; it subscribed automatically upon creation.
			if EventBus.is_subscribed(EventBus.EVENT.Movement_Changed, weapon.onWeaponPositionAdjusting) :
				EventBus.unsubscribe(EventBus.EVENT.Movement_Changed, weapon.onWeaponPositionAdjusting)

			queue_free()

var is_doing : bool = false
func _on_body_entered(body: Node3D) -> void :
	
	if not is_doing : is_doing = true
	else : return
	
	# If the character enters the area
	if body is CharactersController :

		# Getting the bone we want attach the weapon
		var bone : BoneAttachment3D = body.get_bone()

		# Attaching the weapon
		weapon.reparent(bone)

		# Indicating that the owner of the weapon is the character
		weapon.owner = body

		# Indicating the character is armed
		body.set_isArmed(true)

		# Adjusting position and rotation of the weapon depending on walking or runing
		weapon.position = Vector3(0,0,0)
		weapon.rotation = Vector3(0,90,90)
		
		if body.get_movementComponent().get_isRuning():
			EventBus.emit(_on_body_entered, EventBus.EVENT.Movement_Changed,["Runing",""])
		elif body.get_movementComponent().get_isWalking():
			EventBus.emit(_on_body_entered, EventBus.EVENT.Movement_Changed,["Walking",""])

		# Enabling the Hull designed for the weapon in the character
		body.get_weaponHull().call_deferred("set", "disabled", false)
		body.get_weaponHull().global_position = weapon.get_collisionShape().global_position
		body.get_weaponHull().global_rotation = weapon.get_collisionShape().global_rotation

		is_doing = false

		# Deleting the Area3D, the weapon is already reparent and is no more there
		queue_free()
