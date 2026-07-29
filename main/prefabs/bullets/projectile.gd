class_name Projectile extends Bullet

# The projectile is configured to have a maximum lifespan of 2.5 seconds.
func _ready() -> void : get_tree().create_timer(2.5).timeout.connect( func(): if is_instance_valid(self): _destroy())

# Getting the projectile components : MovementComponent and CountinuousCollisionDetector
func get_movementComponent() -> ProjectileMovementComponent : return get_node("ProjectileMovementComponent")
func get_collisionDetector() -> ProjectileContinuousCollisionDetectorRayCast3D : return get_node("ProjectileContinuousCollisionDetectorRayCast3D")

# Function that resolves when a collision is detected, also called by the Projectile Continuous Collision Detector RayCast3D node
func _on_body_entered(body: Node3D) -> void :

	# We deactivated RayCast so that it no longer detects anything
	get_collisionDetector().enabled = false 

	# If it's already being destroyed, we're out
	if not is_inside_tree(): return 

	# Not shooting ourselves, we use the metadata of the person who took the shot
	if body == get_meta("shooter", null) :
		# To allow the bullet to continue, since it was deactivated upon detecting a collision to save CPU
		set_physics_process(true)
		return

	# Place the bullet exactly on the impact surface before calling _destroy()
	if get_collisionDetector().is_colliding() : 
		# We obtain the impact position to position the bullet before it destroys and the normal to the collision point for a future particle system using that normal to orient them would be coded here
		var impact_pos = get_collisionDetector().get_collision_point()
		var _impact_normal = get_collisionDetector().get_collision_normal()
		global_position = impact_pos

	# Stop movement through the component
	get_movementComponent().set_enabled(false)

	# Message informing
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(self) + " Collision detected with: " + str(body), 'projectile.gd', 36, true)

	_destroy()
