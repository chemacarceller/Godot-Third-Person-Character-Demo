class_name Projectile extends Bullet

# Flag to prevent double collisions in the same frame
var _has_collided : bool = false

@onready var collision_detector: ProjectileContinuousCollisionDetectorRayCast3D = get_collisionDetector()
@onready var movement_component: ProjectileMovementComponent = get_movementComponent()

# The projectile is configured to have a maximum lifespan of 2.5 seconds.
func _ready() -> void : 
	super()
	get_tree().create_timer(2.5).timeout.connect( func(): if is_instance_valid(self): _destroy())

# Getting the projectile components : MovementComponent and CountinuousCollisionDetector
func get_movementComponent() -> ProjectileMovementComponent : return get_node("ProjectileMovementComponent")
func get_collisionDetector() -> ProjectileContinuousCollisionDetectorRayCast3D : return get_node("ProjectileContinuousCollisionDetectorRayCast3D")
func get_mesh() -> MeshInstance3D : return get_node("Mesh")
func get_collisionShape() -> CollisionShape3D : return get_node("CollisionShape")


func _on_body_entered(body: Node3D) -> void :
	
	if _has_collided or not is_inside_tree() : return  

	# Ignore collision with the shooter
	if body == get_meta("shooter", null) :
		set_physics_process(true)
		return

	# If the Area3D detects something, we check if the RayCast has more precise information about the exact point.
	var impact_pos = global_position
	var impact_normal = Vector3.ZERO
	if collision_detector :
		collision_detector.force_raycast_update()
		if collision_detector.is_colliding():
			impact_pos = collision_detector.get_collision_point()
			impact_normal = collision_detector.get_collision_normal()

	_resolve_collision(body, impact_pos, impact_normal)

# Centralized function to handle the impact only once
# For the time being, we will not use the _impact_normal argument.
func _resolve_collision(body: Node3D, impact_pos: Vector3, _impact_normal : Vector3) -> void:

	if _has_collided : return
	else : _has_collided = true

	# Position at the exact point of impact
	global_position = impact_pos

	# Disable detectors and motion
	if collision_detector : collision_detector.set_enabled(false)        
	if movement_component and movement_component.has_method("set_enabled") : movement_component.set_enabled(false)

	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(self) + " Collision detected with: " + str(body), 'projectile.gd', 54, true)

	_destroy()

func _destroy() -> void : queue_free()
