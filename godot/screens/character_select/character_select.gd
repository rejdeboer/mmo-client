extends Control

const CharacterListItem = preload("res://screens/character_select/character_list_item.tscn")

@onready var list_container: VBoxContainer = $CharacterSelectPanel/VBoxContainer/CharacterListContainer
@onready var play_button: Button = $CharacterSelectPanel/VBoxContainer/HBoxContainer/PlayButton
@onready var status_label: Label = $CharacterSelectPanel/VBoxContainer/StatusLabel
@onready var http_request: HTTPRequest = $HTTPRequest

var selected_character_data: Dictionary

func _ready() -> void:
	fetch_character_list()

func fetch_character_list() -> void:
	status_label.text = "Loading characters..."
	play_button.disabled = true
	
	var base_url = ConfigManager.web_server.base_url
	var url = base_url + "character" 
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + PlayerSession.jwt 
	]
	
	http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_body = {}
	if body.size() > 0:
		response_body = JSON.parse_string(body.get_string_from_utf8())

	if response_code == 200:
		handle_request_success(response_body)
	else:
		status_label.text = "Error fetching characters (Code: %d)" % response_code

func handle_request_success(response: Variant):
	if response.has("token"):
		NetworkManager.connect_to_server(response["token"])
		# TODO: Transition to game
		
	else: # For character list
		populate_character_list(response)
		status_label.text = "Please select a character."
	

func populate_character_list(characters: Array) -> void:
	for child in list_container.get_children():
		child.queue_free()
		
	if characters.is_empty():
		status_label.text = "You have no characters. Please create one!"
		return
		
	for char_data in characters:
		var list_item = CharacterListItem.instantiate()
		list_container.add_child(list_item)
		
		list_item.set_character_data(char_data)
		list_item.selected.connect(_on_character_item_selected)

func _on_character_item_selected(character_data: Dictionary) -> void:
	self.selected_character_data = character_data
	play_button.disabled = false
	status_label.text = "'%s' selected." % character_data.name
	
	# Deselect all other items for clear visual feedback.
	for item in list_container.get_children():
		if item.character_data.id != character_data.id:
			item.deselect()

func _on_play_button_pressed() -> void:
	if selected_character_data:
		print("Entering world with: ", selected_character_data.name)
		var base_url = ConfigManager.web_server.base_url
		var url = base_url + "game/request-entry" 
		
		var headers = [
			"Content-Type: application/json",
			"Authorization: Bearer " + PlayerSession.jwt 
		]
		var body = {
			"character_id": int(selected_character_data.id),
		}
		
		http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

		
func _on_create_character_button_pressed() -> void:
	get_tree().change_scene_to_file("res://screens/character_creation/character_creation.tscn")
