extends Label

func _enter_tree() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'movement_mode_label3d.gd',4,true) 
	if not EventBus.is_subscribed(EventBus.EVENT.Movement_Changed, on_MovementChanged) :
		EventBus.subscribe(EventBus.EVENT.Movement_Changed, on_MovementChanged)
func _ready() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'movement_mode_label3d.gd',8,true)
	set_text("You are : ")
func on_MovementChanged(value) -> void : if value[0] != "" : set_text("You are : " + value[0])
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST: MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'movement_mode_label3d.gd',11,true)
