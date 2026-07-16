class_name LoadingData extends Resource

# Variable that contains the scene that will be loaded once the loading process is complete
@export var main_scene_path: String = "res://main/levels/mainlevel.tscn"

# Array containing the scenes (prefabs) that we will load into memory and reference from GameInstance._prefabs
@export var prefabs_to_load: Array[PackedScene] = []

# Array containing the scenes (prefabs) that, once loaded into memory, are added to the scene and removed to execute the scripts, and then released from memory and GameInstance
@export var prefabs_to_script_execution: Array[PackedScene] = []

# Dictionary containing the prefab's meshes to load. In general, it doesn't make sense to put them here since they will be loaded by default.
# But if a prefab has more than one mesh that changes dynamically at runtime, those meshes other than the default mesh could be loaded.
# Meshes will be referenced in GameInstance._meshes
@export var meshes_to_store: Dictionary = {}

# Array containing the materials to be compiled
@export var materials_to_compile: Array[Material] = []
