extends Node

class WebServerConfig:
	var _base_url: String

	var base_url: String:
		get: return _base_url

	func _init(config: ConfigFile):
		var section = "web_server"
		_base_url = config.get_value(section, "base_url", "http://127.0.0.1:8000/")


var _web_server_config: WebServerConfig

var web_server: WebServerConfig:
	get: return _web_server_config

const CONFIG_FILE_PATH = "res://config.cfg"

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://config.cfg")
	if err != OK:
		print("error loading config file: " + err)

	_web_server_config = WebServerConfig.new(config)
	
