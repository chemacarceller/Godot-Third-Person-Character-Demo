class_name Bullet extends Area3D

func _notification(what): if what == NOTIFICATION_WM_CLOSE_REQUEST : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Exiting the bullet ... " + name, 'bullet.gd',3,true)

func _enter_tree() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + str(self) + " Instantiated ... ", 'bullet.gd',5,true)

func _ready() -> void : MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " Bullet Ready ... " + str(self), 'bullet.gd',7,true)

func _destroy() -> void :
	MyLogger.info("FRAME : " + str(Engine.get_process_frames()) + " : " + " The bullet is eliminated ... " + str(self), 'bullet.gd',10,true)
	queue_free()
