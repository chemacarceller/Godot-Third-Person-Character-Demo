extends Label

func _enter_tree() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Instantiated ... ", 'camera_mode_label3d.gd',4,true)   
	if not EventBus.is_subscribed(EventBus.EVENT.CameraMode_Changed, on_cameraChanged) :
		EventBus.subscribe(EventBus.EVENT.CameraMode_Changed, on_cameraChanged)
func _ready() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(get_path()) + " Ready ... ", 'camera_mode_label3d.gd',8,true)
	set_text("CAMERA MODE : ")
func on_cameraChanged(value : String) -> void: set_text("CAMERA MODE : " + value)
func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST: MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting... " + name, 'camera_mode_label3d.gd',11,true)
