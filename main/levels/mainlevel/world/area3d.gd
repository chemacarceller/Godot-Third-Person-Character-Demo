extends Area3D

@onready var weapon : Weapon = get_node("WeaponAreaCollisionShape/AssaultRifle1")

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
			queue_free()

var is_doing : bool = false
func _on_body_entered(body: Node3D) -> void :
	
	if not is_doing : is_doing = true
	else : return
	
	# If the character enters the area
	if body is CharactersController :

		if body.get_movementComponent().get_isRuning():
			EventBus.emit(_on_body_entered, EventBus.EVENT.Movement_Changed,["Runing",""])
		elif body.get_movementComponent().get_isWalking():
			EventBus.emit(_on_body_entered, EventBus.EVENT.Movement_Changed,["Walking",""])

		body.attach_weapon(weapon)

		is_doing = false

		# Deleting the Area3D, the weapon is already reparent and is no more there
		queue_free()
