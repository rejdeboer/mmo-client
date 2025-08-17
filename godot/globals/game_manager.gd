extends Node

var _pending_character_data: Entity

func _ready() -> void:
	NetworkManager.connection_success.connect(_on_connection_success)
	NetworkManager.enter_game_success.connect(_on_enter_game_success)

func _on_connection_success() -> void:
	print("GameManager: Received connection success signal")

func _on_enter_game_success(player_entity: Entity) -> void:
	print("GameManager: Received game entry data: ", player_entity)
	_pending_character_data = player_entity
	get_tree().change_scene_to_file("res://screens/loading/loading_screen.tscn")
	

# This function will be called by the loading screen when it's done.
func finish_world_load(world_scene_instance: Node) -> void:
	var loading_screen = get_tree().current_scene
	get_tree().root.add_child(world_scene_instance)
	world_scene_instance.initialize_world(_pending_character_data)
	get_tree().current_scene = world_scene_instance
	loading_screen.queue_free()
	_pending_character_data = null
