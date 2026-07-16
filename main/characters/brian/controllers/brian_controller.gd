@tool
class_name BrianController extends CharactersController

@export var running_rotation : Vector3 = Vector3(195, -5, -90)
@export var walking_rotation : Vector3 = Vector3(195, -5, -90)
@export var idle_rotation : Vector3 = Vector3(190, -5, -90)

func _ready() -> void:
	super()

func update_skeleton():
	super()

func update_animationplayer():
	super()
