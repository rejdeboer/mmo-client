# NOTE: THIS IS A PROTOTYPE, the final launcher will be implemented in Tauri
extends Control

@onready var login_panel: PanelContainer = $LoginPanel
@onready var register_panel: PanelContainer = $RegisterPanel

# Login Panel UI
@onready var login_email_input: LineEdit = $LoginPanel/VBoxContainer/EmailInput
@onready var login_password_input: LineEdit = $LoginPanel/VBoxContainer/PasswordInput
@onready var login_status_label: Label = $LoginPanel/VBoxContainer/StatusLabel

# Register Panel UI
@onready var register_username_input: LineEdit = $RegisterPanel/VBoxContainer/UsernameInput
@onready var register_email_input: LineEdit = $RegisterPanel/VBoxContainer/EmailInput
@onready var register_password_input: LineEdit = $RegisterPanel/VBoxContainer/PasswordInput
@onready var register_status_label: Label = $RegisterPanel/VBoxContainer/StatusLabel

@onready var http_request: HTTPRequest = $HTTPRequest


func _ready() -> void:
	_show_login_view(true)


func _show_login_view(show_view: bool) -> void:
	if show_view:
		login_panel.show()
		register_panel.hide()
		login_email_input.grab_focus()
	else:
		login_panel.hide()
		register_panel.show()
		register_username_input.grab_focus()
	
	login_status_label.text = ""
	register_status_label.text = ""

func _on_login_button_pressed() -> void:
	var email = login_email_input.text
	var password = login_password_input.text

	if email.is_empty() or password.is_empty():
		login_status_label.text = "Email and password cannot be empty."
		return

	var body = {
		"email": email,
		"password": password
	}
	
	login_status_label.text = "Logging in..."
	_make_http_request("token", body)


func _on_register_button_pressed() -> void:
	var username = register_username_input.text
	var email = register_email_input.text
	var password = register_password_input.text

	if username.is_empty() or email.is_empty() or password.is_empty():
		register_status_label.text = "All fields are required."
		return

	var body = {
		"username": username,
		"email": email,
		"password": password
	}
	
	register_status_label.text = "Creating account..."
	_make_http_request("account", body)


func _on_go_to_register_button_pressed() -> void:
	_show_login_view(false)


func _on_go_to_login_button_pressed() -> void:
	_show_login_view(true)


func _make_http_request(endpoint: String, body: Dictionary) -> void:
	var url = ConfigManager.web_server.base_url + endpoint
	var headers = ["Content-Type: application/json"]
	var body_json = JSON.stringify(body)
	
	# Disable buttons to prevent spamming requests
	$LoginPanel/VBoxContainer/HBoxContainer/LoginButton.disabled = true
	$RegisterPanel/VBoxContainer/HBoxContainer/RegisterButton.disabled = true

	# The request is asynchronous. The result will be handled in _on_http_request_completed.
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if error != OK:
		login_status_label.text = "An error occurred. Could not make request."
		register_status_label.text = "An error occurred. Could not make request."


func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	$LoginPanel/VBoxContainer/HBoxContainer/LoginButton.disabled = false
	$RegisterPanel/VBoxContainer/HBoxContainer/RegisterButton.disabled = false

	var response_body = {}
	if body.size() > 0:
		response_body = JSON.parse_string(body.get_string_from_utf8())
	
	match response_code:
		200, 201: 
			handle_success(response_body)
		400, 401, 403, 409: 
			handle_client_error(response_body)
		500: 
			handle_server_error()
		_:
			login_status_label.text = "Unexpected error: %d" % response_code
			register_status_label.text = "Unexpected error: %d" % response_code


func handle_success(response: Dictionary) -> void:
	if response.has("jwt"):
		print("Login successful! JWT: ", response["jwt"])
		login_status_label.text = "Login Successful!"
		PlayerSession.store_session(response["jwt"])
		get_tree().change_scene_to_file("res://screens/character_select/character_select.tscn")
		
	else: # For registration
		_show_login_view(true)
		login_status_label.text = "Account created! Please log in."
	
func handle_client_error(response: Dictionary) -> void:
	var error_message = "An error occurred."
	if response and response.has("error"):
		error_message = response["error"]
	
	login_status_label.text = error_message
	register_status_label.text = error_message

func handle_server_error() -> void:
	var error_message = "Server error. Please try again later."
	login_status_label.text = error_message
	register_status_label.text = error_message
