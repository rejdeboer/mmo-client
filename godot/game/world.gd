extends Node3D

@onready var player: CharacterBody3D = $Player

func initialize_world(character_data: Character) -> void:
	print("WorldScene: Initializing with data: ", character_data)
	
	# TODO: Initialize player
	# if player and character_data:
	# 	player.position.x = character_data.
	# 	player.level = character_data.get("level", 1)
	# 	player.character_name = character_data.get("character_name", "Player")
	# 	
	# 	# You could also set up the camera, UI elements, etc.
	# 	$HUD/LevelLabel.text = "Lv. " + str(player.level)
