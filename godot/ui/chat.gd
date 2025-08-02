extends Control

@onready var chat_display = $Panel/VBoxContainer/Display
@onready var message_input = $Panel/VBoxContainer/ChatInput

const CHANNEL_COLORS = {
	MessageType.SAY: Color.WHITE,
	MessageType.YELL: Color.DARK_RED,
	MessageType.WHISPER: Color.MEDIUM_PURPLE,
	MessageType.GUILD: Color.PALE_GREEN,
	MessageType.PARTY: Color.DARK_BLUE,
}

const CHANNEL_NAMES = {
	MessageType.SAY: "Say",
	MessageType.YELL: "Yell",
	MessageType.GUILD: "Guild",
	MessageType.PARTY: "Party",
}

var current_whisper_recipient_name: String
var current_channel: int = MessageType.SAY

func _ready():
	message_input.text_submitted.connect(_on_text_submitted)
	SocialManager.chat_received.connect(_on_social_chat_received)
	SocialManager.whisper_received.connect(_on_whisper_received)
	SocialManager.whisper_confirmed.connect(_on_whisper_confirmed)
	
func _process(delta):
	if Input.is_action_pressed("enter"):
		if !message_input.has_focus():
			message_input.grab_focus()


func _on_social_chat_received(sender_name: String, text: String, message_type: int) -> void:
	var color = CHANNEL_COLORS.get(message_type, Color.WHITE)
	var channel = CHANNEL_NAMES.get(message_type)

	var format = "[color={color}][b][{channel}][url={sender}][{sender}]:[/url][/b] {text}[/color]\n"
	chat_display.append_text(format.format({
		"color": color.to_html(),
		"channel": channel.to_lower(),
		"sender": sender_name,
		"text": text,
	}))

func _on_whisper_received(sender_name: String, text: String) -> void:
	chat_display.append_text("[color=purple][b][" + sender_name + "] whispers:[/b] " + text + "[/color]\n")

func _on_whisper_confirmed(recipient_name: String, text: String) -> void:
	chat_display.append_text("[color=purple][b]To [" + recipient_name + "]:[/b] " + text + "[/color]\n")

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

func receive_game_message(message_type: int, sender_name: String, text: String):
	var color = CHANNEL_COLORS.get(message_type, Color.WHITE)
	var channel = CHANNEL_NAMES.get(message_type)

	# TODO: Format won't work for zone chat
	var format = "[color={color}][b][url={sender}][{sender}] {channel}s:[/url][/b] {text}[/color]\n"
	chat_display.append_text(format.format({
		"color": color.to_html(),
		"channel": channel.to_lower(),
		"sender": sender_name,
		"text": text,
	}))


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
