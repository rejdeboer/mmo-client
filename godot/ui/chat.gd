extends Control

@onready var chat_display = $Panel/VBoxContainer/Display
@onready var message_input = $Panel/VBoxContainer/ChatInput

var current_whisper_recipient_name: String
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

	match current_channel:
		MessageType.SAY, MessageType.YELL, MessageType.ZONE:
			NetworkManager.queue_chat(current_channel, text)
		MessageType.GUILD, MessageType.PARTY:
			SocialManager.send_chat(current_channel, text)
		MessageType.WHISPER:
			SocialManager.send_whisper(current_whisper_recipient_name, text)

	message_input.grab_focus()

func receive_message(message_type: int, sender: String, text: String):
	add_message(sender, text)

func add_message(username, message):
	chat_display.append_text("[b]" + username + ":[/b] " + message + "\n")


func _on_input_text_changed(new_text):
	if new_text.begins_with("/") and new_text.contains(" "):
		var parts = new_text.split(" ")
		match parts[0]:
			"/s", "/say":
				message_input.text = new_text.trim_prefix(parts[0] + " ")
				current_channel = MessageType.SAY
			"/y", "/yell":
				message_input.text = new_text.trim_prefix(parts[0] + " ")
				current_channel = MessageType.YELL
			"/w", "/whisper":
				if parts.size() < 3:
					return
				current_whisper_recipient_name = parts[1]
				current_channel = MessageType.WHISPER
				message_input.text = new_text.trim_prefix(parts[0] + " " + parts[1])
