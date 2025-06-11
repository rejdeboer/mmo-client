extends Node

var config = ConfigFile.new()

func _ready() -> void:
	var err = config.load("res://config.cfg")
	if err != OK:
		# TODO: Load default config
		print("error loading config file: " + err)

func get_value(section: String, key: String):
	return config.get_value(section, key)
