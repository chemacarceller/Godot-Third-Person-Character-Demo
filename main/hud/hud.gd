extends Control

func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'hud.gd',3,true)
func _ready() -> void: MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'hud.gd',4,true)
func get_finalText() -> Label : return get_node("FinalText")
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST: MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'hud.gd',6,true)
