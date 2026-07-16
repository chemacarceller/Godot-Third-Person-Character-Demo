extends Label

func _enter_tree() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'graphic_profile.gd',4,true)  
	if not EventBus.is_subscribed(EventBus.EVENT.GraphicProfile_Changed, on_graphicProfileChanged) :
		EventBus.subscribe(EventBus.EVENT.GraphicProfile_Changed, on_graphicProfileChanged)
func _ready() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'graphic_profile.gd',8,true)
	set_text("GRAPHIC PROFILE : ")
func on_graphicProfileChanged(value : String) -> void : set_text("GRAPHIC PROFILE : " + value)
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST: MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'camera_mode_label3d.gd',11,true)
