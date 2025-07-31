# NOTE: Fast way to start the game with a connect token
# Some arguments are available via command line
# 1: Account email
# 2: Account password
# 3: Character name
# These can be set up in "Debug" -> "Customize run instances..."
# WARNING: Only use for testing
extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

enum Step {
	LOGIN = 0,
	CHARACTER_SELECT = 1,
}

var current_step = Step.LOGIN

func _ready() -> void:
	var args = OS.get_cmdline_args()
	var email = args.get(1)
	var password = args.get(2)

	var body = {
		"email": email,
		"password": password
	}
	
	_make_http_request("token", body)


func _on_http_request_completed(result, response_code, headers, body):
	if response_code >= 400:
		printerr("received error from server; STEP: %d; STATUS: %d" % [current_step, response_code])
		return;
		
	var response = JSON.parse_string(body.get_string_from_utf8())
		
	match current_step:
		Step.LOGIN:
			PlayerSession.store_session(response["jwt"])
			var auth_headers = ["Authorization: Bearer " + response["jwt"]]
			var select_character_body = {
				"character_id": int(OS.get_cmdline_args().get(3)),
			}
			_make_http_request("game/request-entry", select_character_body, auth_headers)
		Step.CHARACTER_SELECT:
			NetworkManager.connect_to_server(response["connect_token"])
			SocialManager.connect_to_server(ConfigManager.web_server.base_url, PlayerSession.jwt)
	
	current_step += 1

func _make_http_request(endpoint: String, body: Dictionary, extra_headers: Array = []) -> void:
	var url = ConfigManager.web_server.base_url + endpoint
	var headers = ["Content-Type: application/json"]
	headers.append_array(extra_headers)
	var body_json = JSON.stringify(body)

	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if error != OK:
		printerr("An error occurred. Could not make request.")

func _process(delta: float) -> void:
	NetworkManager.poll_connection(delta)
