@tool
class_name RemyController extends CharactersController

@export var running_rotation : Vector3 = Vector3(185, -5, -97)
@export var walking_rotation : Vector3 = Vector3(180, -5, -112)
@export var idle_rotation : Vector3 = Vector3(185, -5, -97)

func _ready() -> void:
	super()

func update_skeleton():
	super()

func update_animationplayer():
	super()
