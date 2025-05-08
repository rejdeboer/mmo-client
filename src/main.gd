extends Control

@onready var ip_address_edit: LineEdit = $IPAddressEdit
@onready var port_edit: LineEdit = $PortEdit
@onready var connect_button: Button = $ConnectButton
@onready var message_edit: LineEdit = $MessageEdit
@onready var send_button: Button = $SendButton
@onready var status_label: Label = $StatusLabel

var client: StreamPeerTCP = StreamPeerTCP.new()
var is_connected: bool = false

func _ready() -> void:
	connect_button.pressed.connect(_on_connect_button_pressed)
	send_button.pressed.connect(_on_send_button_pressed)
	send_button.disabled = true # Start with send button disabled

func _on_connect_button_pressed() -> void:
	if is_connected:
		# Disconnect logic (optional for this simple test, or add a disconnect button)
		client.disconnect_from_host()
		is_connected = false
		status_label.text = "Status: Disconnected"
		connect_button.text = "Connect"
		send_button.disabled = true
		printerr("Disconnected.")
		return

	var ip: String = ip_address_edit.text
	var port: int = port_edit.text.to_int()

	if ip.is_empty() or port <= 0 or port > 65535:
		status_label.text = "Status: Invalid IP or Port"
		printerr("Invalid IP or Port.")
		return

	status_label.text = "Status: Connecting..."
	var err: Error = client.connect_to_host(ip, port)

	if err != OK:
		status_label.text = "Status: Connection failed. Error: " + str(err)
		printerr("Connection failed. Error: " + str(err))
		is_connected = false
		return

	# Connection attempt started. We need to poll status in _process
	# For simplicity here, we'll assume it connects quickly or fails.
	# A more robust solution would poll client.get_status() in _process
	# until STATUS_CONNECTED or STATUS_ERROR.

	# Let's give it a moment, then check status (simplified for this example)
	# In a real app, you'd use a timer or check in _process
	await get_tree().create_timer(0.1).timeout # Short delay to allow connection
	
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		is_connected = true
		status_label.text = "Status: Connected to " + ip + ":" + str(port)
		connect_button.text = "Disconnect"
		send_button.disabled = false
		print("Successfully connected!")
	else:
		status_label.text = "Status: Failed to connect (check server and details)."
		printerr("Failed to connect. Status: " + str(client.get_status()))
		client.disconnect_from_host() # Clean up
		is_connected = false


func _on_send_button_pressed() -> void:
	if not is_connected:
		status_label.text = "Status: Not connected. Cannot send."
		printerr("Not connected. Cannot send.")
		return

	var message_to_send: String = message_edit.text
	if message_to_send.is_empty():
		status_label.text = "Status: Message is empty."
		return

	var data_to_send: PackedByteArray = message_to_send.to_utf8_buffer()
	var err: Error = client.put_data(data_to_send)

	if err != OK:
		status_label.text = "Status: Error sending data: " + str(err)
		printerr("Error sending data: " + str(err))
	else:
		status_label.text = "Status: Sent: '" + message_to_send + "'"
		print("Sent: '", message_to_send, "'")

func _process(_delta: float) -> void:
	if not is_connected:
		return

	# Check connection status
	var status = client.get_status()
	if status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
		if is_connected: # Was previously connected
			is_connected = false
			status_label.text = "Status: Disconnected (Connection lost)"
			connect_button.text = "Connect"
			send_button.disabled = true
			printerr("Connection lost or error. Status: " + str(status))
			client.disconnect_from_host() # Ensure cleanup
		return

	# Try to receive data
	var available_bytes: int = client.get_available_bytes()
	if available_bytes > 0:
		var received_data: PackedByteArray = client.get_data(available_bytes)[1] # get_data returns [error_code, data_array]
		if received_data.size() > 0:
			var received_string: String = received_data.get_string_from_utf8()
			status_label.text = "Status: Received: '" + received_string + "'"
			print("Received: '", received_string, "'")
		else:
			# This might happen if get_data failed internally after available_bytes > 0
			# or if the server sent an empty payload that still registered bytes.
			print("Received 0 bytes despite available_bytes > 0, or error in get_data.")
