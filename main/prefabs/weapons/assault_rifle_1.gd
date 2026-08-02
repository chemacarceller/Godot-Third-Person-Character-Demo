class_name AssaultRifle extends Weapon

func get_mesh() -> MeshInstance3D : return get_node("Mesh")
func get_collisionShape() -> CollisionShape3D : return get_node("CollisionShape")
func get_remoteTransform() -> RemoteTransform3D : return get_node("CollisionShape/RemoteTransform")
