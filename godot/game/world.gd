extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var chat: Control = $Chat

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
	CHAT = 4,
}

func initialize_world(player_entity: Entity) -> void:
	print("WorldScene: Initializing with data: ", player_entity)
	
	if player and player_entity:
		player_entity_id = player_entity.id
		player.transform = player_entity.transform
		player.level = player_entity.level
		player.character_name = player_entity.name

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
		buffer.put_float(player.rotation.y)
		buffer.put_float(player.input_vector.y)
		buffer.put_float(player.input_vector.x)

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
				var entity: Entity = event["entity"]
				entity_instance.transform = entity.transform
				entities[entity.id] = entity_instance
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
			ServerEventType.CHAT:
				chat.receive_game_message(event["message_type"], event["sender_name"], event["text"])
