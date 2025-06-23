# NOTE: Allows to start the game without a connect token
# WARNING: Only use for testing
extends Control

@onready var ip_address_edit: LineEdit = $IPAddressEdit
@onready var port_edit: LineEdit = $PortEdit
@onready var connect_button: Button = $ConnectButton
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	connect_button.pressed.connect(_on_connect_button_pressed)

func _on_connect_button_pressed() -> void:
	var ip: String = ConfigManager.game_server.host
	var port: int = ConfigManager.game_server.port

	if ip.is_empty() or port <= 0 or port > 65535:
		status_label.text = "Status: Invalid IP or Port"
		printerr("Invalid IP or Port.")
		return

	status_label.text = "Status: Connecting..."
	NetworkManager.connect_unsecure(ip, port, 0)


func _on_send_button_pressed() -> void:
	print("send button pressed")


func _on_connection_success() -> void:
	print("CONNECTED")
	pass # Replace with function body.
