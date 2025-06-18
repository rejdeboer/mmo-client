extends Control

const WORLD_SCENE_PATH = "res://game/world.tscn"

@onready var progress_bar: ProgressBar = $PanelContainer/VBoxContainer/ProgressBar
@onready var progress_label: Label = $PanelContainer/VBoxContainer/ProgressLabel

func _ready() -> void:
	ResourceLoader.load_threaded_request(WORLD_SCENE_PATH)
	progress_label.text = "Loading world..."

func _process(delta: float) -> void:
	var progress_array = []
	var status = ResourceLoader.load_threaded_get_status(WORLD_SCENE_PATH, progress_array)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress_array[0] * 100
			
		ResourceLoader.THREAD_LOAD_LOADED:
			var world_packed_scene = ResourceLoader.load_threaded_get(WORLD_SCENE_PATH)
			var world_instance = world_packed_scene.instantiate()

			set_process(false)
			GameManager.finish_world_load(world_instance)
			
		ResourceLoader.THREAD_LOAD_FAILED:
			progress_label.text = "ERROR: Failed to load world."
			set_process(false)
