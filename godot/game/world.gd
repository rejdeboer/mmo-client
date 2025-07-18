extends Node3D

@onready var player: CharacterBody3D = $Player

var EntityScene = preload("res://game/entity.tscn")

const TICK_RATE = 20.0
const SECONDS_PER_TICK = 1.0 / TICK_RATE

var player_entity_id: int
var accumulator = 0.0
var entities = {}

enum ServerEventType {
	ENTITY_MOVE = 1,
	ENTITY_SPAWN = 2,
	ENTITY_DESPAWN = 3,
}

func initialize_world(character_data: Character) -> void:
	print("WorldScene: Initializing with data: ", character_data)
	
	if player and character_data:
		player_entity_id = character_data.entity_id
		player.transform = character_data.transform
		# player.level = character_data.level
		# player.character_name = character_data.name
		
	# 	# You could also set up the camera, UI elements, etc.
	# 	$HUD/LevelLabel.text = "Lv. " + str(player.level)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	accumulator += delta
	while accumulator >= SECONDS_PER_TICK:
		accumulator -= SECONDS_PER_TICK
		run_network_tick(delta)

func run_network_tick(delta):
	var buffer = StreamPeerBuffer.new()

	if player.is_transform_dirty:
		player.is_transform_dirty = false
		var pos = player.position
		buffer.put_float(pos.x)
		buffer.put_float(pos.y)
		buffer.put_float(pos.z)
		buffer.put_float(player.rotation.y)

	var events = NetworkManager.sync(buffer.data_array, delta)
	handle_server_events(events)

func handle_server_events(events: Array[Dictionary]):
	for event in events:
		match event["type"]:
			ServerEventType.ENTITY_MOVE:
				var entity_id = event["entity_id"]
				if player_entity_id == entity_id:
					# TODO: Proper interpolation
					#player.transform = event["transform"]
					pass
				elif entities.has(entity_id):
					entities[entity_id].target_transform = event["transform"]
				else:
					push_warning("movement event refers to unknown entity")
			ServerEventType.ENTITY_SPAWN:
				print("spawning entity")
				var entity_instance = EntityScene.instantiate()
				entity_instance.transform = event["transform"]
				entities[event["entity_id"]] = entity_instance
				add_child(entity_instance)
			ServerEventType.ENTITY_DESPAWN:
				print("despawning entity")
				var entity_id = event["entity_id"]
				if entities.has(entity_id):
					var entity_node = entities[entity_id]
					if is_instance_valid(entity_node):
						entity_node.queue_free()
					entities.erase(entity_id)
				else:
					push_warning("tried to despawn entity but it was already gone")
