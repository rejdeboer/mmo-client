extends Control

@onready var chat_display = $Panel/VBoxContainer/Display
@onready var message_input = $Panel/VBoxContainer/ChatInput

enum ChannelType {
	SAY = 0,
	YELL = 1,
	GUILD = 2,
	PARTY = 3,
	WHISPER = 4,
	TRADE = 5,
}

func _ready():
	message_input.text_submitted.connect(_on_text_submitted)
	SocialManager.social_chat_received.connect(_on_social_chat_received)
	
func _process(delta):
	if Input.is_action_pressed("enter"):
		if message_input.has_focus():
			send_message()
		else:
			message_input.grab_focus()


func _on_social_chat_received(name: String, text: String, message_type: MessageType) -> void:
	print("received social message: " + text)

func _on_text_submitted(text):
	pass
	#send_message()

func send_message():
	var text = message_input.text
	if text.strip_edges().is_empty():
		message_input.text = ""
		return

	NetworkManager.queue_chat(ChannelType.SAY, message_input.text)

	message_input.text = ""
	message_input.grab_focus()

func receive_message(channel: ChannelType, sender: String, text: String):
	add_message(sender, text)

func add_message(username, message):
	chat_display.append_text("[b]" + username + ":[/b] " + message + "\n")
