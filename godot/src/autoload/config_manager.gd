extends Node

var config = ConfigFile.new()

# TODO: Do we need this?
func _ready() -> void:
	var _err = config.load("res://config.cfg")
