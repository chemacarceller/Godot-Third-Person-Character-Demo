class_name Bullet extends Area3D

# We will use the RayCast3D to detect collision
@onready var ray_cast: RayCast3D = $RayCast3D

 # Configurable from the Inspector
@export var damage_value: int = 10

func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting the bullet ... " + name, 'bullet.gd',9,true)

func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(self) + " Instantiated ... ", 'bullet.gd',11,true)

func _ready() -> void :

	# The bullet has RayCast collision for doing a continuos collision simulation
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Bullet Ready ... " + str(self), 'bullet.gd',16,true)

	# The bullet is queue_free after 2.5 seconds if the doesnt collision with something else
	get_tree().create_timer(2.5).timeout.connect( func(): if is_instance_valid(self): _destroy())

# Collision detection by RayCast precise
func _physics_process(delta: float) -> void:

	# We launch a beam to the position where the bullet will be in the next frame
	var distance_this_frame : float = get_movementComponent().speed * delta
	ray_cast.target_position.z = -distance_this_frame * 1.2   # 1.2 security margin
	
	# If any collidable object is detected
	if ray_cast.is_colliding() :
		
		var collider = ray_cast.get_collider()
		
		# Disable ray_cast processing to save CPU
		set_physics_process(false)
		
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + "RayCast detected collision: " + collider.name, 'bullet.gd', 36, true)
		_on_body_entered.call_deferred(collider)

# The bullet is eliminated
func _destroy() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " The bullet is eliminated ... " + str(self), 'bullet.gd',41,true)
	queue_free()

# Getting the projectile movement
func get_movementComponent() -> ProjectileMovementComponent : return get_node("ProjectileMovementComponent")

# Function that resolves when a collision is detected, also called by the RayCast collision
func _on_body_entered(body: Node3D) -> void :

	# We deactivated RayCast so that it no longer detects anything
	ray_cast.enabled = false 

	# If it's already being destroyed, we're out
	if not is_inside_tree(): return 

	# Not shooting ourselves, we use the metadata of the person who took the shot
	if body == get_meta("shooter", null) :
		# To allow the bullet to continue, since it was deactivated upon detecting a collision to save CPU
		set_physics_process(true)
		return

	# Place the bullet exactly on the impact surface before calling _destroy()
	if ray_cast.is_colliding() : 

		# We obtain the impact position to position the bullet before it destroys and the normal to the collision point for a future particle system using that normal to orient them would be coded here
		var impact_pos = ray_cast.get_collision_point()
		var _impact_normal = ray_cast.get_collision_normal()
		global_position = impact_pos

	# Stop movement through the component
	get_movementComponent().set_IsEnabled(false)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(self) + " Collision detected with: " + str(body), 'bullet.gd', 73, true)

	# We prepare the code to be called when another object is hit.
	# The other object must have a `take_damage` method that would execute the code indicating what would happen to it.
	if body.has_method("take_damage") : body.take_damage(damage_value, get_meta("shooter", null))

	_destroy()
