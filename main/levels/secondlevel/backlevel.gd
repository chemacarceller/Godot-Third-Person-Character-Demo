extends Area3D

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'back_level.gd',5,true)

var back_level_entered : bool = false

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D  and not back_level_entered :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Entered ... " + name, 'back_level.gd',11,true)
		back_level_entered = true
		await LevelManager.load_new_level("res://main/levels/mainlevel.tscn")
		back_level_entered = false

func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + name + " Ready ... ","backlevel.gd",16, true)
func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + name + " Instantiated ... ","backlevel.gd",17, true)
