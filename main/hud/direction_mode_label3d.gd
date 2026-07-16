extends Label

func _enter_tree() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'direction_mode_label3d.gd',4,true)  
	if not EventBus.is_subscribed(EventBus.EVENT.Movement_Changed, on_MovementChanged) :
		EventBus.subscribe(EventBus.EVENT.Movement_Changed, on_MovementChanged)
func _ready() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'direction_mode_label3d.gd',8,true)
	set_text("Direction : ")
func on_MovementChanged(value) -> void: if value[1] != "" : set_text("Direction : " + value[1])
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST: MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name + " FRAME : " + str(Engine.get_process_frames()), 'direction_mode_label3d.gd',11,true)
