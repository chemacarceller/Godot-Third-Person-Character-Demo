class_name PlayerController extends PlayerControllerBase

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		MyLogger.info(" PlayerController Exiting : " + name + " ..." , 'PlayerController.gd',5,true)
