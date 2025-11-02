# NOTE: Allows to start the game without a connect token
# Some arguments are available via command line
# 1: Account email
# 2: Account password
# 3: Character name
# These can be set up in "Debug" -> "Customize run instances..."
# WARNING: Only use for testing
extends Control

func _ready() -> void:
	var ip: String = "127.0.0.1"
	var port: int = 8000

	if ip.is_empty() or port <= 0 or port > 65535:
		printerr("Invalid IP or Port.")
		return

	var character_id = OS.get_cmdline_args().get(4)

	NetworkManager.connect_unsecure(ip, port, int(character_id))

func _process(delta: float) -> void:
	NetworkManager.poll_connection(delta)
