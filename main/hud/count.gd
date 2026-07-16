extends Label

func _enter_tree() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'count.gd',4,true)  
	if not EventBus.is_subscribed(EventBus.EVENT.Time_TicToc, _showCount) :
		EventBus.subscribe(EventBus.EVENT.Time_TicToc, _showCount)
func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'count.gd',7,true)
func _showCount(count) -> void : text = str(count)
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'count.gd',9,true)
