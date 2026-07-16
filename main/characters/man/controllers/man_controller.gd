@tool
class_name ManController extends CharactersController

@export var running_rotation : Vector3 = Vector3(200, -5, -90)
@export var walking_rotation : Vector3 = Vector3(200, -15, -100)
@export var idle_rotation : Vector3 = Vector3(170, -5, -90)

func _ready() -> void:
	super()

func update_skeleton():
	super()

func update_animationplayer():
	super()
