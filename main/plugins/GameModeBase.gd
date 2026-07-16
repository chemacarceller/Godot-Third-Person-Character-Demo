# GameModeBase : Abstract class to inherit all the GameMode classes
#
# A GameMode class is a class that implements the code refering to one unique level
# It must be attached to the root node of the Level
# 
# In the level shoud be incorporated a node called PlayerStart to indicate the start position of the PlayerPawn
# Only one GameMode class active

class_name GameModeBase extends Node3D

func _ready() :
	pass
