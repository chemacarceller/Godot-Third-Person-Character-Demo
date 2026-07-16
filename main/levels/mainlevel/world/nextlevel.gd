extends Area3D

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'next_level.gd',5,true)

var next_level_entered : bool = false

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not next_level_entered :
		MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Entered ... " + name, 'next_level.gd',11,true)
		next_level_entered = true
		await LevelManager.load_new_level("res://main/levels/secondlevel.tscn")
		next_level_entered = false

func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ","nextlevel.gd",16, true)
func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ","nextlevel.gd",17, true)
