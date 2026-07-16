extends Label

func _enter_tree() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'hour.gd',4,true) 
	if not EventBus.is_subscribed(EventBus.EVENT.Time_TicToc, _showHour) :
		EventBus.subscribe(EventBus.EVENT.Time_TicToc, _showHour)
func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'hour.gd',7,true)
func _showHour(_count) -> void :
	var current_time = Time.get_time_dict_from_system()
	text = "%02d : %02d : %02d" % [current_time.hour, current_time.minute, current_time.second]
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'hour.gd',11,true)
