extends Control

@onready var chat_display = $Panel/VBoxContainer/Display
@onready var message_input = $Panel/VBoxContainer/ChatInput

var last_whisper: String
var current_channel: int = MessageType.SAY

func _ready():
	message_input.text_submitted.connect(_on_text_submitted)
	SocialManager.social_chat_received.connect(_on_social_chat_received)
	
func _process(delta):
	if Input.is_action_pressed("enter"):
		if !message_input.has_focus():
			message_input.grab_focus()


func _on_social_chat_received(name: String, text: String, message_type: int) -> void:
	print("received social message: " + text)

func _on_text_submitted(text):
	send_message()

func send_message():
	var text = message_input.text.strip_edges()
	message_input.text = ""
	if text.is_empty():
		return

	NetworkManager.queue_chat(MessageType.SAY, message_input.text)

	message_input.grab_focus()

func receive_message(channel: MessageType, sender: String, text: String):
	add_message(sender, text)

func add_message(username, message):
	chat_display.append_text("[b]" + username + ":[/b] " + message + "\n")
