extends Node
# NOTA: Se eliminó la línea "class_name MyLogger" de forma intencionada.

# --- ESCUDO PARA EL ANALIZADOR (TIEMPO DE EDICIÓN) ---
# Al no ser funciones estáticas, el motor las compila como métodos de objeto normal,
# permitiendo que la llamada a .free() sea perfectamente legal para el analizador.

func info(a=null, b=null, c=null, d=null) -> void:
	_route_call("info", [a, b, c, d])

func error(a=null, b=null, c=null, d=null) -> void:
	_route_call("error", [a, b, c, d])

func warn(a=null, b=null, c=null, d=null) -> void:
	_route_call("warn", [a, b, c, d])

func resetLogFile(a=null, b=null, c=null, d=null) -> void:
	_route_call("resetLogFile", [a, b, c, d])

# --- INTERCEPTOR DE AUTODESTRUCCIÓN ---
# Si GameInstance llama a MyLogger.free(), se ejecutará esta función de forma nativa.
# Evitamos que el nodo de GDScript se borre si C++ no ha reclamado el Singleton.
func free() -> void:
	if Engine.has_singleton("MyLogger"):
		# Si C++ está activo, dejamos que C++ maneje su propia memoria
		pass
	else:
		# Si ocurre antes de tiempo, simplemente evitamos que rompa el juego
		pass

# --- ENRUTADOR DINÁMICO (TIEMPO DE JUEGO) ---
func _route_call(method_name: String, args: Array) -> void:
	if Engine.has_singleton("MyLogger"):
		var singleton = Engine.get_singleton("MyLogger")
		var clean_args = args.filter(func(element): return element != null)
		singleton.callv(method_name, clean_args)
	else:
		print("[Early Object " + method_name.to_upper() + "]: ", args)
