extends Node

class GameServerConfig:
	var _host: String
	var _port: int

	var host: String:
		get: return _host
	var port: int:
		get: return _port

	func _init(config: ConfigFile):
		var section = "game_server"
		_host = config.get_value(section, "host", "127.0.0.1")
		_port = config.get_value(section, "port", 8000)

class WebServerConfig:
	var _base_url: String

	var base_url: String:
		get: return _base_url

	func _init(config: ConfigFile):
		var section = "web_server"
		_base_url = config.get_value(section, "base_url", "http://127.0.0.1:8000/")


var _game_server_config: GameServerConfig
var _web_server_config: WebServerConfig

var game_server: GameServerConfig:
	get: return _game_server_config
var web_server: WebServerConfig:
	get: return _web_server_config

const CONFIG_FILE_PATH = "res://config.cfg"

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://config.cfg")
	if err != OK:
		print("error loading config file: " + err)

	_game_server_config = GameServerConfig.new(config)
	_web_server_config = WebServerConfig.new(config)
	
