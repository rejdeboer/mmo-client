extends Control

@onready var name_input: LineEdit = $CreationPanelContainer/VBoxContainer/NameInput
@onready var status_label: Label = $CreationPanelContainer/VBoxContainer/StatusLabel
@onready var create_button: Button = $CreationPanelContainer/VBoxContainer/CreateButton
@onready var http_request: HTTPRequest = $HTTPRequest


func _ready() -> void:
	name_input.grab_focus()

func _on_create_button_pressed() -> void:
	var char_name = name_input.text
	
	if char_name.length() < 3:
		status_label.text = "Name must be at least 3 characters long."
		return
	if char_name.length() > 16:
		status_label.text = "Name cannot be longer than 16 characters."
		return

	status_label.text = "Creating character..."
	create_button.disabled = true # Prevent spamming the button

	var base_url = ConfigManager.web_server.base_url
	var url = base_url + "/character" 
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + PlayerSession.jwt 
	]
	
	var body = {
		"name": char_name,
	}
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

# func _on_back_button_pressed() -> void:
# 	get_tree().change_scene_to_file("res://screens/character_select/character_select.tscn")

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	create_button.disabled = false

	if response_code == 201 || response_code == 200:
		print("Character created successfully!")
		get_tree().change_scene_to_file("res://screens/character_select/character_select.tscn")
		return

	var error_message = "An unknown error occurred."
	# TODO: Error handling
	# if not body.is_empty():
	# 	var json = JSON.new()
	# 	if json.parse(body.get_string_from_utf8()) == OK:
	# 		error_message = json.data.get("error", "Creation failed.")
	
	status_label.text = error_message
	print("Character creation failed. Server responded with code: ", response_code)
